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
typealias FirebaseDataConnectAsyncClient =
  Google_Firebase_Dataconnect_V1_ConnectorServiceAsyncClient
typealias FirebaseDataConnectGraphqlError = Google_Firebase_Dataconnect_V1_GraphqlError

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

  enum RequestHeaders {
    static let googRequestParamsHeader = "x-goog-request-params"
    static let authorizationHeader = "x-firebase-auth-token"
    static let appCheckHeader = "X-Firebase-AppCheck"
    static let firebaseAppId = "x-firebase-gmpid"
    static let googApiClient = "x-goog-api-client"
  }

  private let googRequestHeaderValue: String

  private lazy var client: FirebaseDataConnectAsyncClient? = {
    do {
      DataConnectLogger
        .debug("GrpcClient: \(self.description, privacy: .private) initialization starts.")
      let group = PlatformSupport.makeEventLoopGroup(loopCount: threadPoolSize)
      let channel = try GRPCChannelPool.with(
        target: .host(serverSettings.host, port: serverSettings.port),
        transportSecurity: serverSettings
          .sslEnabled ? .tls(GRPCTLSConfiguration.makeClientDefault(compatibleWith: group)) :
          .plaintext,
        eventLoopGroup: group
      )
      DataConnectLogger
        .debug("GrpcClient: \(self.description, privacy: .private) has been created.")
      return FirebaseDataConnectAsyncClient(channel: channel)
    } catch {
      DataConnectLogger
        .debug("Error:\(error) when creating GrpcClient: \(self.description, privacy: .private).")
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
  }

  func executeQuery<ResultType: Decodable,
    VariableType: OperationVariable>(request: QueryRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
    async throws -> OperationResult<ResultType> {
    guard let client else {
      DataConnectLogger.error("When calling executeQuery(), grpc client has not been configured.")
      throw DataConnectInitError.grpcNotConfigured()
    }

    let codec = Codec()
    let grpcRequest = try codec.createQueryRequestProto(
      connectorName: connectorName,
      request: request
    )
    let requestString = try grpcRequest.jsonString()

    do {
      DataConnectLogger
        .debug("executeQuery() sends grpc request: \(requestString, privacy: .private).")
      let results = try await client.executeQuery(grpcRequest, callOptions: createCallOptions())
      let resultsString = try results.jsonString()
      DataConnectLogger
        .debug("executeQuery() receives response: \(resultsString, privacy: .private).")

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
          return OperationResult(data: decodedResults)
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
      // we failed at executing the call
      DataConnectLogger.error(
        "executeQuery(): \(requestString, privacy: .private) grpc call FAILED with \(error)."
      )
      throw DataConnectOperationError.executionFailed(cause: error)
    }
  }

  func executeMutation<ResultType: Decodable,
    VariableType: OperationVariable>(request: MutationRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
    async throws -> OperationResult<ResultType> {
    guard let client else {
      DataConnectLogger
        .error("When calling executeMutation(), grpc client has not been configured.")
      throw DataConnectInitError.grpcNotConfigured()
    }

    let codec = Codec()
    let grpcRequest = try codec.createMutationRequestProto(
      connectorName: connectorName,
      request: request
    )

    let requestString = try grpcRequest.jsonString()

    do {
      DataConnectLogger
        .debug("executeMutation() sends grpc request: \(requestString, privacy: .private).")
      let results = try await client.executeMutation(grpcRequest, callOptions: createCallOptions())
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
          return OperationResult(data: decodedResults)
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
