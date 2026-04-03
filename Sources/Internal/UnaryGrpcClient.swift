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
import Foundation
import GRPC
import NIOCore
import NIOPosix

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor UnaryGrpcClient: GrpcClient {
  private let app: FirebaseApp
  private let connectorName: String
  private let serverSettings: DataConnectSettings
  private let auth: Auth
  private let appCheck: AppCheckInterop?
  private let callerSDKType: CallerSDKType
  private let googRequestHeaderValue: String
  private let googApiClientHeaderValue: String

  private lazy var unaryClient: FirebaseDataConnectUnaryClient? = {
    do {
      DataConnectLogger
        .debug("UnaryGrpcClient: initialization starts.")
      let channel = try DataConnectGrpcClient.grpcChannel(serverSettings: serverSettings)
      DataConnectLogger
        .debug("UnaryGrpcClient: has been created.")
      return FirebaseDataConnectUnaryClient(channel: channel)
    } catch {
      DataConnectLogger
        .debug("Error:\(error) when creating UnaryGrpcClient.")
      return nil
    }
  }()

  init(app: FirebaseApp,
       connectorName: String,
       serverSettings: DataConnectSettings,
       auth: Auth,
       appCheck: AppCheckInterop?,
       callerSDKType: CallerSDKType,
       googRequestHeaderValue: String,
       googApiClientHeaderValue: String) {
    self.app = app
    self.connectorName = connectorName
    self.serverSettings = serverSettings
    self.auth = auth
    self.appCheck = appCheck
    self.callerSDKType = callerSDKType
    self.googRequestHeaderValue = googRequestHeaderValue
    self.googApiClientHeaderValue = googApiClientHeaderValue
  }

  func executeQuery<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type)
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

      let results = try await unaryClient.executeQuery(
        grpcRequest,
        callOptions: await createCallOptions()
      )
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

      let errorInfoList = DataConnectGrpcClient.createErrorInfoList(errors: results.errors)

      guard !errorInfoList.isEmpty else {
        return ServerResponse(data: jsonData, extensions: extensions)
      }

      let resultsString = try results.data.jsonString()
      do {
        let decodedResults = try codec.decode(result: results.data, asType: resultType)

        let failureResponse = OperationFailureResponse(
          rawJsonData: resultsString,
          errors: errorInfoList,
          data: decodedResults
        )
        throw DataConnectOperationError.executionFailed(
          response: failureResponse
        )

      } catch let operationErr as DataConnectOperationError {
        throw operationErr
      } catch {
        if !errorInfoList.isEmpty {
          let failureResponse = OperationFailureResponse(
            rawJsonData: resultsString,
            errors: errorInfoList,
            data: nil
          )
          throw
            DataConnectOperationError
            .executionFailed(
              cause: error,
              response: failureResponse
            )
        } else {
          throw DataConnectCodecError.decodingFailed(cause: error)
        }
      }
    } catch {
      let requestString = try grpcRequest.jsonString()
      DataConnectLogger.error(
        "executeQuery(): \(requestString, privacy: .private) grpc call FAILED with \(error)."
      )
      throw DataConnectOperationError.executionFailed(cause: error)
    }
  }

  func executeMutation<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: MutationRequest<VariableType>,
    resultType: ResultType.Type)
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
      let results = try await unaryClient.executeMutation(
        grpcRequest,
        callOptions: await createCallOptions()
      )
      let resultsString = try results.jsonString()
      DataConnectLogger
        .debug("executeMutation() receives response: \(resultsString, privacy: .private).")

      let errorInfoList = DataConnectGrpcClient.createErrorInfoList(errors: results.errors)

      do {
        let decodedResults = try codec.decode(result: results.data, asType: resultType)

        if !errorInfoList.isEmpty {
          let failureResponse = OperationFailureResponse(
            rawJsonData: resultsString,
            errors: errorInfoList,
            data: decodedResults
          )
          throw DataConnectOperationError.executionFailed(
            response: failureResponse
          )
        } else {
          return OperationResult(data: decodedResults, source: .server)
        }

      } catch let operationErr as DataConnectOperationError {
        throw operationErr
      } catch {
        if !errorInfoList.isEmpty {
          let failureResponse = OperationFailureResponse(
            rawJsonData: resultsString,
            errors: errorInfoList,
            data: nil
          )
          throw
            DataConnectOperationError
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

  func subscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws -> AsyncStream<ServerResponse> {
    throw DataConnectInternalError
      .internalError(message: "Subscribe not supported in UnaryGrpcClient")
  }

  func unsubscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws {
    throw DataConnectInternalError
      .internalError(message: "Unsubscribe not supported in UnaryGrpcClient")
  }

  func createCallOptions() async -> CallOptions {
    return await DataConnectGrpcClient.createCallOptions(
      app: app,
      auth: auth,
      appCheck: appCheck,
      googRequestHeaderValue: googRequestHeaderValue,
      googApiClientHeaderValue: googApiClientHeaderValue
    )
  }
}
