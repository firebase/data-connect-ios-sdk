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

@preconcurrency import FirebaseAppCheckInterop
@preconcurrency import FirebaseAuth
import FirebaseCore
@preconcurrency import FirebaseCoreExtension
import Foundation
import GRPC
import Logging
import NIOCore
import NIOHPACK
import NIOPosix
import SwiftProtobuf

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectUnaryClient =
  Google_Firebase_Dataconnect_V1_ConnectorServiceAsyncClient
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectExecuteMutationRequest =
  Google_Firebase_Dataconnect_V1_ExecuteMutationRequest
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectExecuteQueryRequest =
  Google_Firebase_Dataconnect_V1_ExecuteQueryRequest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectGraphqlError = Google_Firebase_Dataconnect_V1_GraphqlError

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectStreamingClient =
  Google_Firebase_Dataconnect_V1_ConnectorStreamServiceAsyncClient
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectStreamingCall = GRPCAsyncBidirectionalStreamingCall<
  Google_Firebase_Dataconnect_V1_StreamRequest, Google_Firebase_Dataconnect_V1_StreamResponse
>
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectStreamRequest = Google_Firebase_Dataconnect_V1_StreamRequest
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectStreamResponse = Google_Firebase_Dataconnect_V1_StreamResponse

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum GrpcClientRequestHeaders {
  static let googRequestParams = "x-goog-request-params"
  static let firebaseAuthToken = "x-firebase-auth-token"
  static let firebaseAppCheckToken = "x-firebase-appcheck"
  static let firebaseAppId = "x-firebase-gmpid"
  static let googApiClient = "x-goog-api-client"
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
protocol GrpcClient: Sendable {
  func executeQuery<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> ServerResponse

  func executeMutation<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: MutationRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> OperationResult<ResultType>

  func subscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws -> AsyncStream<ServerResponse>

  func createCallOptions() async -> CallOptions
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor DataConnectGrpcClient: GrpcClient, CustomStringConvertible {
  nonisolated let description: String

  private let unaryClient: UnaryGrpcClient
  private let streamingClient: StreamingGrpcClient

  static let threadPoolSize = 1

  init(app: FirebaseApp,
       settings: DataConnectSettings,
       connectorConfig: ConnectorConfig,
       callerSDKType: CallerSDKType) {
    guard let projectId = app.options.projectID else {
      fatalError("Data Connect requires a Firebase project ID to be specified.")
    }

    let connectorName =
      "projects/\(projectId)/locations/\(connectorConfig.location)/services/\(connectorConfig.serviceId)/connectors/\(connectorConfig.connector)"

    let googRequestHeaderValue = "location=\(connectorConfig.location)&frontend=data"

    let header =
      "gl-swift/\(Version.swiftVersion()) fire/\(Version.sdkVersion) \(Version.platformVersionHeader()) grpc-swift/"
    let googApiClientHeaderValue: String
    switch callerSDKType {
    case .base:
      googApiClientHeaderValue = header
    case .generated:
      googApiClientHeaderValue = "\(header) swift/gen"
    }

    let auth = Auth.auth(app: app)
    let appCheck = ComponentType<AppCheckInterop>.instance(
      for: AppCheckInterop.self,
      in: app.container
    )

    description = """
        projectId=\(projectId) \
        connector=\(connectorConfig.connector) \
        host=\(settings.host) \
        port=\(settings.port) \
        ssl=\(settings.sslEnabled)
    """

    unaryClient = UnaryGrpcClient(
      app: app,
      connectorName: connectorName,
      serverSettings: settings,
      auth: auth,
      appCheck: appCheck,
      callerSDKType: callerSDKType,
      googRequestHeaderValue: googRequestHeaderValue,
      googApiClientHeaderValue: googApiClientHeaderValue
    )

    streamingClient = StreamingGrpcClient(
      app: app,
      connectorName: connectorName,
      serverSettings: settings,
      auth: auth,
      appCheck: appCheck,
      callerSDKType: callerSDKType,
      googRequestHeaderValue: googRequestHeaderValue,
      googApiClientHeaderValue: googApiClientHeaderValue
    )
  }

  func executeQuery<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> ServerResponse {
    if await streamingClient.hasActiveSubscriptions() {
      do {
        return try await streamingClient.executeQuery(request: request, resultType: resultType)
      } catch let operationErr as DataConnectOperationError {
        throw operationErr
      } catch {
        DataConnectLogger
          .error("Error executing query with streaming gRPC, falling back to non-streaming.")
      }
    }
    return try await unaryClient.executeQuery(request: request, resultType: resultType)
  }

  func executeMutation<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: MutationRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> OperationResult<ResultType> {
    if await streamingClient.hasActiveSubscriptions() {
      do {
        return try await streamingClient.executeMutation(request: request, resultType: resultType)
      } catch let operationErr as DataConnectOperationError {
        throw operationErr
      } catch let internalErr as DataConnectInternalError {
        DataConnectLogger
          .error("Error executing mutation with streaming gRPC, falling back to non-streaming.")
        return try await unaryClient.executeMutation(request: request, resultType: resultType)
      } catch {
        DataConnectLogger.error("Unexpected error executing mutation.")
        throw error
      }
    }
    return try await unaryClient.executeMutation(request: request, resultType: resultType)
  }

  func subscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws -> AsyncStream<ServerResponse> {
    return try await streamingClient.subscribe(request: request, resultType: resultType)
  }

  func createCallOptions() async -> CallOptions {
    // unaryClient.createCallOptions and streamingClient.createCallOptions both just call through to
    // DataConnectGrpcClient.createCallOptions.
    return await unaryClient.createCallOptions()
  }

  // MARK: Shared Helpers

  static func grpcChannel(serverSettings: DataConnectSettings) throws -> any GRPCChannel {
    let group = PlatformSupport.makeEventLoopGroup(loopCount: threadPoolSize)
    let channel = try GRPCChannelPool.with(
      target: .host(serverSettings.host, port: serverSettings.port),
      transportSecurity: serverSettings
        .sslEnabled
        ? .tls(GRPCTLSConfiguration.makeClientDefault(compatibleWith: group)) : .plaintext,
      eventLoopGroup: group
    )
    return channel
  }

  static func createErrorInfoList(errors: [FirebaseDataConnectGraphqlError])
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

  static func createCallOptions(app: FirebaseApp,
                                auth: Auth,
                                appCheck: AppCheckInterop?,
                                googRequestHeaderValue: String,
                                googApiClientHeaderValue: String) async -> CallOptions {
    var headers = HPACKHeaders()

    if app.isDataCollectionDefaultEnabled {
      headers.add(
        name: GrpcClientRequestHeaders.googRequestParams,
        value: googRequestHeaderValue
      )
      headers.add(name: GrpcClientRequestHeaders.firebaseAppId, value: app.options.googleAppID)
      headers.add(name: GrpcClientRequestHeaders.googApiClient, value: googApiClientHeaderValue)
    }

    // Add Auth token if available
    do {
      if let token = try await auth.currentUser?.getIDToken() {
        headers.add(name: GrpcClientRequestHeaders.firebaseAuthToken, value: "\(token)")
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
      headers.add(name: GrpcClientRequestHeaders.firebaseAppCheckToken, value: token.token)
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
