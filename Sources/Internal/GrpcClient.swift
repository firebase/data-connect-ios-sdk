// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import Foundation

@preconcurrency import FirebaseAppCheckInterop
@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseCoreExtension
import GRPC
import Logging
import NIOCore
import NIOHPACK
import NIOPosix
import SwiftProtobuf

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectUnaryClient =
  Google_Firebase_Dataconnect_V1_ConnectorServiceAsyncClient
typealias FirebaseDataConnectExecuteMutationRequest =
  Google_Firebase_Dataconnect_V1_ExecuteMutationRequest
typealias FirebaseDataConnectExecuteQueryRequest =
  Google_Firebase_Dataconnect_V1_ExecuteQueryRequest


typealias FirebaseDataConnectGraphqlError = Google_Firebase_Dataconnect_V1_GraphqlError

typealias FirebaseDataConnectStreamingClient = Google_Firebase_Dataconnect_V1_ConnectorStreamServiceAsyncClient
typealias FirebaseDataConnectStreamingCall = GRPCAsyncBidirectionalStreamingCall<Google_Firebase_Dataconnect_V1_StreamRequest, Google_Firebase_Dataconnect_V1_StreamResponse>
typealias FirebaseDataConnectStreamResponse = Google_Firebase_Dataconnect_V1_StreamResponse
typealias FirebaseDataConnectStreamRequest = Google_Firebase_Dataconnect_V1_StreamRequest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor GrpcClient: CustomStringConvertible {
  nonisolated let description: String

  private let app: FirebaseApp

  private let projectId: String

  private let threadPoolSize = 1

  private let serverSettings: DataConnectSettings

  private let connectorConfig: ConnectorConfig

  private let connectorName: String // Fully qualified connector name

  private let auth: Auth

  private let appCheck: AppCheckInterop?

  private let callerSDKType: CallerSDKType
  
  private var streamingCall: FirebaseDataConnectStreamingCall?
  
  private var responseDemuxer = ResponseDemuxer()
  
  enum RequestHeaders {
    static let googRequestParamsHeader = "x-goog-request-params"
    static let authorizationHeader = "x-firebase-auth-token"
    static let appCheckHeader = "X-Firebase-AppCheck"
    static let firebaseAppId = "x-firebase-gmpid"
    static let googApiClient = "x-goog-api-client"
  }

  private let googRequestHeaderValue: String
  
  private func grpcChannel() throws -> any GRPCChannel {
    let group = PlatformSupport.makeEventLoopGroup(loopCount: threadPoolSize)
    let channel = try GRPCChannelPool.with(
      target: .host(serverSettings.host, port: serverSettings.port),
      transportSecurity: serverSettings
        .sslEnabled ? .tls(GRPCTLSConfiguration.makeClientDefault(compatibleWith: group)) :
        .plaintext,
      eventLoopGroup: group
    )
    return channel
  }

  private lazy var unaryClient: FirebaseDataConnectUnaryClient? = {
    do {
      DataConnectLogger
        .debug("GrpcClient: \(self.description, privacy: .private) initialization starts.")
      let channel = try grpcChannel()
      DataConnectLogger
        .debug("GrpcClient: \(self.description, privacy: .private) has been created.")
      return FirebaseDataConnectUnaryClient(channel: channel)
    } catch {
      DataConnectLogger
        .debug("Error:\(error) when creating GrpcClient: \(self.description, privacy: .private).")
      return nil
    }
  }()

  private lazy var streamingClient: FirebaseDataConnectStreamingClient? = {
    do {
      DataConnectLogger.debug("GrpcClient: \(self.description, privacy: .private) streaming initialization starts")
      let channel = try grpcChannel()
      DataConnectLogger.debug("GrpcClient: \(self.description, privacy: .private) streaming has been created.")
      return FirebaseDataConnectStreamingClient(channel: channel)
    } catch {
      DataConnectLogger
        .debug("Error: \(error) when creating streaming GrpcClient: \(self.description, privacy: .private)")
      return nil
    }
  }()

  private lazy var googApiClientHeaderValue: String = {
    let header =
      "gl-swift/\(Version.swiftVersion()) fire/\(Version.sdkVersion) \(Version.platformVersionHeader()) grpc-swift/"

    switch self.callerSDKType {
    case .base:
      return header
    case .generated:
      return "\(header) swift/gen"
    }

  }()

  init(app: FirebaseApp, settings: DataConnectSettings, connectorConfig: ConnectorConfig,
       callerSDKType: CallerSDKType) {
    self.app = app

    guard let projectId = app.options.projectID else {
      fatalError("Data Connect requires a Firebase project ID to be specified.")
    }
    self.projectId = projectId

    serverSettings = settings
    self.connectorConfig = connectorConfig
    auth = Auth.auth(app: app)
    appCheck = ComponentType<AppCheckInterop>.instance(for: AppCheckInterop.self, in: app.container)
    self.callerSDKType = callerSDKType

    connectorName =
      "projects/\(projectId)/locations/\(connectorConfig.location)/services/\(connectorConfig.serviceId)/connectors/\(connectorConfig.connector)"

    googRequestHeaderValue = "location=\(self.connectorConfig.location)&frontend=data"

    description = """
        projectId=\(projectId) \
        connector=\(connectorConfig.connector) \
        host=\(serverSettings.host) \
        port=\(serverSettings.port) \
        ssl=\(serverSettings.sslEnabled)
    """
    
    Task {
      await connectStream()
    }
  }
  
  // setup stream
  func connectStream() async {
    do {
      
      guard streamingCall == nil else {
        DataConnectLogger.debug("connectStream() is called again, ignoring.")
        return
      }
      
      guard let streamingClient else {
        DataConnectLogger.error("When calling connectStream(), grpc client has not been configured.")
        return
      }
      
      let callOptions = await createCallOptions()
      print(callOptions)
      streamingCall = streamingClient.makeConnectCall(callOptions: callOptions)
      
      guard let streamingCall else {
        DataConnectLogger.error("Error: Failed to setup a streaming call")
        return
      }
      
      var firstRequest = FirebaseDataConnectStreamRequest()
      firstRequest.requestID = "1+\(UUID().uuidString)"
      firstRequest.name = connectorName
      try await streamingCall.requestStream.send(firstRequest)
      
      print("Created streaming call")
      Task {
        do {
          for try await response in streamingCall.responseStream {
            DataConnectLogger.debug("Received stream response from the server: \(response)")
            // handle response
            await responseDemuxer.handleResponse(response)
            
          }
        } catch {
          DataConnectLogger.error("Error in stream response \(error)")
        }
      }
      
    } catch {
      DataConnectLogger.error("Error setting up stream: \(error)")
      //TODO: Handle stream connect failure
      
    }
    
  }

  func executeQuery<ResultType: Decodable,
    VariableType: OperationVariable>(request: QueryRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
  async throws -> ServerResponse {
    
    do {
      return try await executeQueryStream(request: request, resultType: resultType)
    } catch {
      // TODO: Distinguish network errors from stream errors.
      DataConnectLogger.error("Error executing on stream mode, falling back to unary mode ")
      return try await executeQueryUnary(request: request, resultType: resultType)
    }
  }
  
  func executeQueryStream<ResultType: Decodable,
    VariableType: OperationVariable>(request: QueryRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
  async throws -> ServerResponse {
    guard let streamingCall else {
      DataConnectLogger.error("When calling executeQueryStream(), grpc client has not been configured.")
      throw DataConnectInternalError.internalError(message:"Streaming call not configured")
    }
    
    do {
      var streamRequest = Google_Firebase_Dataconnect_V1_StreamRequest()
      streamRequest.requestID = "\(request.operationName)+\(Int.random(in: 1...1000))"
      streamRequest.execute = Google_Firebase_Dataconnect_V1_ExecuteRequest.with({ req in
        req.operationName = request.operationName
        // TODO: Variables
      })
      
      DataConnectLogger
        .debug(
          "Making streaming call with request \(streamRequest.requestID), \(streamRequest.name), \(streamRequest.execute.operationName)"
        )
      
      let requestID = streamRequest.requestID // copy to avoid capture
      async let response = responseDemuxer.waitForResponse(for: requestID)
      DataConnectLogger.debug("Sending streaming request \(try streamRequest.jsonString())")
      try await streamingCall.requestStream.send(streamRequest)
      DataConnectLogger.debug("Done sending request")
      
      return ServerResponse(data: try await response.data.jsonUTF8Data(), extensions: nil)
    } catch {
      DataConnectLogger.error("Error sending request to the server: \(error)")
      throw error
    }
    
    //return ServerResponse(data: Data(), extensions: nil)
  }
  
  func executeQueryUnary<ResultType: Decodable,
    VariableType: OperationVariable>(request: QueryRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
    async throws -> ServerResponse {
    guard let unaryClient else {
      DataConnectLogger.error("When calling executeQuery(), grpc client has not been configured.")
      throw DataConnectInitError.grpcNotConfigured()
    }

    let codec = ProtoCodec()
    let grpcRequest = try codec.createQueryRequestProto(
      connectorName: connectorName,
      request: request
    )

    do {
      if DataConnectLogger.isDebugEnabled {
        let requestString = try grpcRequest.jsonString()
        DataConnectLogger
          .debug("executeQuery() sends grpc request: \(requestString, privacy: .private).")
      }

      let results = try await unaryClient.executeQuery(grpcRequest, callOptions: createCallOptions())
      let jsonData = try results.data.jsonUTF8Data()

      let jsonDecoder = JSONDecoder()

      var extensions: ExtensionResponse?
      do {
        let extensionsData = try results.extensions.jsonUTF8Data()
        extensions = try jsonDecoder.decode(ExtensionResponse.self, from: extensionsData)
      } catch {
        DataConnectLogger.error("Failed to decode extensions: \(error)")
      }

      if DataConnectLogger.isDebugEnabled {
        let resultsString = try results.data.jsonString()
        DataConnectLogger
          .debug("executeQuery() receives response: \(resultsString, privacy: .private).")

        let extensions = try results.extensions.jsonString()
        DataConnectLogger
          .debug("executeQuery() extensions: \(extensions, privacy: .private).")
      }

      // lets decode partial errors. We need these whether we succeed or fail
      let errorInfoList = createErrorInfoList(errors: results.errors)

      /*
       If we don't have Partial Errors, we return the result string to be decoded at query level
       If we have Partial Errors, we follow the partial error route below.
       */
      guard !errorInfoList.isEmpty else {
        // TODO: Extract ttl, server timestamp when available
        return ServerResponse(data: jsonData, extensions: extensions)
      }

      // We have partial errors returned
      /*
       - if decode succeeds, errorList isEmpty = return data
       - if decode succeeds, errorList notEmpty = throw OperationError with decodedData
       - if decode fails,
              - if errorList notEmpty -> throw OperationError with no decodedData
                else -> throw decodeFailed with the inner error.
       */
      let resultsString = try results.data.jsonString()
      do {
        let decodedResults = try codec.decode(result: results.data, asType: resultType)

        // even though decode succeeded, we may still have received partial errors
        let failureResponse = OperationFailureResponse(
          rawJsonData: resultsString, errors: errorInfoList,
          data: decodedResults
        )
        throw DataConnectOperationError.executionFailed(
          response: failureResponse
        )

      } catch let operationErr as DataConnectOperationError {
        // simply rethrow to avoid wrapping error
        throw operationErr
      } catch {
        // we failed to decode
        if !errorInfoList.isEmpty {
          let failureResponse = OperationFailureResponse(
            rawJsonData: resultsString,
            errors: errorInfoList,
            data: nil
          )
          throw DataConnectOperationError
            .executionFailed(
              cause: error,
              response: failureResponse
            )
        } else {
          throw DataConnectCodecError.decodingFailed(cause: error)
        }
      }
    } catch {
      // we failed at executing the server call itself
      let requestString = try grpcRequest.jsonString()
      DataConnectLogger.error(
        "executeQuery(): \(requestString, privacy: .private) grpc call FAILED with \(error)."
      )
      throw DataConnectOperationError.executionFailed(cause: error)
    }
  }
  
  func subscribe<ResultType: Decodable,
                 VariableType: OperationVariable>(request: QueryRequest<VariableType>, resultType: ResultType.Type) async throws -> AsyncStream<OperationResult<ResultType>> {
    
  }

  func executeMutation<ResultType: Decodable,
    VariableType: OperationVariable>(request: MutationRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
    async throws -> OperationResult<ResultType> {
    guard let unaryClient else {
      DataConnectLogger
        .error("When calling executeMutation(), grpc client has not been configured.")
      throw DataConnectInitError.grpcNotConfigured()
    }

    let codec = ProtoCodec()
    let grpcRequest = try codec.createMutationRequestProto(
      connectorName: connectorName,
      request: request
    )

    let requestString = try grpcRequest.jsonString()

    do {
      DataConnectLogger
        .debug("executeMutation() sends grpc request: \(requestString, privacy: .private).")
      let results = try await unaryClient.executeMutation(grpcRequest, callOptions: createCallOptions())
      let resultsString = try results.jsonString()
      DataConnectLogger
        .debug("executeMutation() receives response: \(resultsString, privacy: .private).")

      // lets decode partial errors. We need these whether we succeed or fail
      let errorInfoList = createErrorInfoList(errors: results.errors)

      /*
       - if decode succeeds, errorList isEmpty = return data
       - if decode succeeds, errorList notEmpty = throw OperationError with decodedData
       - if decode fails,
              - if errorList notEmpty -> throw OperationError with no decodedData
                else -> throw decodeFailed with the inner error.
       */
      do {
        let decodedResults = try codec.decode(result: results.data, asType: resultType)

        // even though decode succeeded, we may still have received partial errors
        if !errorInfoList.isEmpty {
          let failureResponse = OperationFailureResponse(
            rawJsonData: resultsString, errors: errorInfoList,
            data: decodedResults
          )
          throw DataConnectOperationError.executionFailed(
            response: failureResponse
          )
        } else {
          return OperationResult(data: decodedResults, source: .server)
        }

      } catch let operationErr as DataConnectOperationError {
        // simply rethrow to avoid wrapping error
        throw operationErr
      } catch {
        // we failed to decode
        if !errorInfoList.isEmpty {
          let failureResponse = OperationFailureResponse(
            rawJsonData: resultsString,
            errors: errorInfoList,
            data: nil
          )
          throw DataConnectOperationError
            .executionFailed(
              cause: error,
              response: failureResponse
            )
        } else {
          throw DataConnectCodecError.decodingFailed(cause: error)
        }
      }
    } catch {
      DataConnectLogger.error(
        "executeMutation(): \(requestString, privacy: .private) grpc call FAILED with \(error)."
      )
      throw error
    }
  }

  private func createErrorJson(errors: [FirebaseDataConnectGraphqlError]) -> String? {
    var errorMessages = [String]()
    for err in errors {
      errorMessages.append(err.message)
    }

    do {
      let jsonEncoder = JSONEncoder()
      let jsonData = try jsonEncoder.encode(errorMessages)
      return String(data: jsonData, encoding: .utf8)
    } catch {
      DataConnectLogger.error("Error encoding partial error list")
      return nil
    }
  }

  private func createErrorInfoList(errors: [FirebaseDataConnectGraphqlError])
    -> [OperationFailureResponse.ErrorInfo] {
    let errorList = errors.compactMap { errorProto in
      do {
        let errorJsonData = try errorProto.jsonUTF8Data()
        let jsonDecoder = JSONDecoder()
        let errorInfo = try jsonDecoder.decode(
          OperationFailureResponse.ErrorInfo.self,
          from: errorJsonData
        )
        return errorInfo
      } catch {
        DataConnectLogger.error("Error decoding GraphQLError \(error)")
        return nil
      }
    }
    return errorList
  }

  func createCallOptions() async -> CallOptions {
    var headers = HPACKHeaders()

    if app.isDataCollectionDefaultEnabled {
      headers.add(name: RequestHeaders.googRequestParamsHeader, value: googRequestHeaderValue)
      headers.add(name: RequestHeaders.firebaseAppId, value: app.options.googleAppID)
      headers.add(name: RequestHeaders.googApiClient, value: googApiClientHeaderValue)
    }

    // Add Auth token if available
    do {
      if let token = try await auth.currentUser?.getIDToken() {
        headers.add(name: RequestHeaders.authorizationHeader, value: "\(token)")
        DataConnectLogger.debug("Auth token added.")
      } else {
        DataConnectLogger.debug("No auth token available. Not adding auth header.")
      }
    } catch {
      DataConnectLogger
        .debug("Cannot get auth token successfully due to: \(error). Not adding auth header.")
    }

    // Add AppCheck token if available
    if let token = await appCheck?.getToken(forcingRefresh: false) {
      headers.add(name: RequestHeaders.appCheckHeader, value: token.token)
      DataConnectLogger.debug("App Check token added.")
    } else {
      DataConnectLogger.debug("App Check token unavailable. Not adding App Check header.")
    }

    var options = CallOptions(customMetadata: headers)

    // Enable GRPC tracing
    if DataConnectLogger.logLevel.rawValue >= FirebaseLoggerLevel.debug.rawValue,
       DataConnectLogger.privateLoggingEnabled == false {
      var logger = Logger(label: "com.google.firebase.dataconnect.grpc")
      logger.logLevel = .trace
      options.logger = logger
    }

    return options
  }
}


fileprivate actor ResponseDemuxer {
  private var pendingRequests: [String: CheckedContinuation<FirebaseDataConnectStreamResponse, Error>] = [:]
    
  func waitForResponse(for requestID: String) async throws -> FirebaseDataConnectStreamResponse {
        try await withCheckedThrowingContinuation { continuation in
            pendingRequests[requestID] = continuation
        }
    }

  
  func handleResponse(_ response: FirebaseDataConnectStreamResponse) {
    if let continuation = pendingRequests.removeValue(forKey: response.requestID) {
            continuation.resume(returning: response)
        }
    }

  // handle failure for a particular request
  func handleError(_ error: Error, for requestID: String) {
        if let continuation = pendingRequests.removeValue(forKey: requestID) {
            continuation.resume(throwing: error)
        }
    }

  // global failure. throw all
  func handleStreamFailure(_ error: Error) {
    pendingRequests.values.forEach { $0.resume(throwing: error) }
    pendingRequests.removeAll()
  }
}
