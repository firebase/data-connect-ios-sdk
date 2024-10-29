// Copyright 2024 Google LLC
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

@preconcurrency import FirebaseAppCheck
@preconcurrency import FirebaseAuth
import FirebaseCore
import GRPC
import NIOCore
import NIOHPACK
import NIOPosix
import OSLog
import SwiftProtobuf

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectAsyncClient =
  Google_Firebase_Dataconnect_V1beta_ConnectorServiceAsyncClient

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

  private let appCheck: AppCheck?

  private let callerSDKType: CallerSDKType

  // Remove debug flag when logging privacy is properly handled.
  private let debugEnable = false

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
      if debugEnable == true {
        FirebaseLogger.dataConnect.debug("\(self.description) initialization starts.")
      } else {
        FirebaseLogger.dataConnect.debug("GrpcClient initialization starts.")
      }
      let group = PlatformSupport.makeEventLoopGroup(loopCount: threadPoolSize)
      let channel = try GRPCChannelPool.with(
        target: .host(serverSettings.host, port: serverSettings.port),
        transportSecurity: serverSettings
          .sslEnabled ? .tls(GRPCTLSConfiguration.makeClientDefault(compatibleWith: group)) :
          .plaintext,
        eventLoopGroup: group
      )
      if debugEnable == true {
        FirebaseLogger.dataConnect.debug("\(self.description) has been created.")
      } else {
        FirebaseLogger.dataConnect.debug("GrpcClient has been created.")
      }
      return FirebaseDataConnectAsyncClient(channel: channel)
    } catch {
      if debugEnable == true {
        FirebaseLogger.dataConnect.error("Error:\(error) when creating \(self.description).")
      } else {
        FirebaseLogger.dataConnect.debug("Error:\(error) when creating GrpcClient.")
      }
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
    appCheck = AppCheck.appCheck(app: app)
    self.callerSDKType = callerSDKType

    connectorName =
      "projects/\(projectId)/locations/\(connectorConfig.location)/services/\(connectorConfig.serviceId)/connectors/\(connectorConfig.connector)"

    googRequestHeaderValue = "location=\(self.connectorConfig.location)&frontend=data"

    description = """
        GrpcClient: \
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
      FirebaseLogger.dataConnect
        .error("When calling executeQuery(), grpc client has not been configured.")
      throw DataConnectError.grpcNotConfigured
    }

    let codec = Codec()
    let grpcRequest = try codec.createQueryRequestProto(
      connectorName: connectorName,
      request: request
    )

    do {
      if debugEnable == true {
        try FirebaseLogger.dataConnect
          .debug("executeQuery() sends grpc request: \(grpcRequest.jsonString()).")
      } else {
        try FirebaseLogger.dataConnect
          .debug("executeQuery() sends grpc request.")
      }
      let results = try await client.executeQuery(grpcRequest, callOptions: createCallOptions())
      if debugEnable == true {
        try FirebaseLogger.dataConnect
          .debug("executeQuery() receives response: \(results.jsonString()).")
      } else {
        try FirebaseLogger.dataConnect
          .debug("executeQuery() receives response.")
      }
      // Not doing error decoding here
      if let decodedResults = try codec.decode(result: results.data, asType: resultType) {
        return OperationResult(data: decodedResults)
      } else {
        // In future, set this as error in OperationResult
        if debugEnable == true {
          try FirebaseLogger.dataConnect
            .error("executeQuery() response: \(results.jsonString()) decode failed.")
        } else {
          try FirebaseLogger.dataConnect
            .error("executeQuery() response decode failed.")
        }
        throw DataConnectError.decodeFailed
      }
    } catch {
      if debugEnable == true {
        try FirebaseLogger.dataConnect
          .error(
            "executeQuery() with request: \(grpcRequest.jsonString()) grpc call FAILED with \(error)."
          )
      } else {
        try FirebaseLogger.dataConnect
          .error(
            "executeQuery() grpc call FAILED with \(error)."
          )
      }
      throw error
    }
  }

  func executeMutation<ResultType: Decodable,
    VariableType: OperationVariable>(request: MutationRequest<VariableType>,
                                     resultType: ResultType
                                       .Type)
    async throws -> OperationResult<ResultType> {
    guard let client else {
      FirebaseLogger.dataConnect
        .error("When calling executeMutation(), grpc client has not been configured.")
      throw DataConnectError.grpcNotConfigured
    }

    let codec = Codec()
    let grpcRequest = try codec.createMutationRequestProto(
      connectorName: connectorName,
      request: request
    )

    do {
      if debugEnable == true {
        try FirebaseLogger.dataConnect
          .debug("executeMutation() sends grpc request: \(grpcRequest.jsonString()).")
      } else {
        try FirebaseLogger.dataConnect
          .debug("executeMutation() sends grpc request.")
      }
      let results = try await client.executeMutation(grpcRequest, callOptions: createCallOptions())
      if debugEnable == true {
        try FirebaseLogger.dataConnect
          .debug("executeMutation() receives response: \(results.jsonString()).")
      } else {
        try FirebaseLogger.dataConnect
          .debug("executeMutation() receives response.")
      }
      if let decodedResults = try codec.decode(result: results.data, asType: resultType) {
        return OperationResult(data: decodedResults)
      } else {
        if debugEnable == true {
          try FirebaseLogger.dataConnect
            .error("executeMutation() response: \(results.jsonString()) decode failed.")
        } else {
          try FirebaseLogger.dataConnect
            .error("executeMutation() response decode failed.")
        }
        throw DataConnectError.decodeFailed
      }
    } catch {
      if debugEnable == true {
        try FirebaseLogger.dataConnect
          .error(
            "executeMutation() with request: \(grpcRequest.jsonString()) grpc call FAILED with \(error)."
          )
      } else {
        try FirebaseLogger.dataConnect
          .error(
            "executeMutation() grpc call FAILED with \(error)."
          )
      }
      throw error
    }
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
        if debugEnable == true {
          FirebaseLogger.dataConnect
            .debug("Auth token added: \(token)")
        } else {
          FirebaseLogger.dataConnect
            .debug("Auth token added.")
        }
      } else {
        FirebaseLogger.dataConnect.debug("No auth token available. Not adding auth header.")
      }
    } catch {
      FirebaseLogger.dataConnect
        .debug("Cannot get auth token successfully due to: \(error). Not adding auth header.")
    }

    // Add AppCheck token if available
    do {
      if let token = try await appCheck?.token(forcingRefresh: false) {
        headers.add(name: RequestHeaders.appCheckHeader, value: token.token)
        if debugEnable == true {
          FirebaseLogger.dataConnect
            .debug("App Check token added: \(token.token)")
        } else {
          FirebaseLogger.dataConnect
            .debug("App Check token added.")
        }
      } else {
        FirebaseLogger.dataConnect
          .debug("App Check token unavailable. Not adding App Check header.")
      }
    } catch {
      FirebaseLogger.dataConnect
        .debug(
          "Cannot get App Check token successfully due to: \(error). Not adding App Check header."
        )
    }

    let options = CallOptions(customMetadata: headers)
    return options
  }
}
