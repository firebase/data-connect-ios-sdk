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
actor StreamingGrpcClient: GrpcClient {
  private let app: FirebaseApp
  private let connectorName: String
  private let serverSettings: DataConnectSettings
  private let auth: Auth
  private let appCheck: AppCheckInterop?
  private let callerSDKType: CallerSDKType
  private let googRequestHeaderValue: String
  private let googApiClientHeaderValue: String

  private var streamingCall: FirebaseDataConnectStreamingCall?
  private var subManager = StreamSubscriptionManager()

  private var requestIdSequence: UInt64 = 0

  private var nextRequestIdSequence: UInt64 {
    requestIdSequence += 1
    return requestIdSequence
  }

  private lazy var streamingClient: FirebaseDataConnectStreamingClient? = {
    do {
      DataConnectLogger.debug(
        "StreamingGrpcClient: streaming client initialization starting."
      )
      let channel = try DataConnectGrpcClient.grpcChannel(serverSettings: serverSettings)
      DataConnectLogger.debug(
        "StreamingGrpcClient: streaming client created."
      )
      return FirebaseDataConnectStreamingClient(channel: channel)
    } catch {
      DataConnectLogger
        .debug(
          "Error: \(error) when creating StreamingGrpcClient."
        )
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

    Task {
      // TODO: Handle failures here.
      await connectStream()
    }
  }

  func connectStream() async {
    do {
      guard streamingCall == nil else {
        DataConnectLogger.debug("connectStream() called multiple times, ignoring.")
        return
      }

      guard let streamingClient else {
        DataConnectLogger.error(
          "When calling connectStream(), grpc client has not been configured."
        )
        return
      }

      let callOptions = await createCallOptions()
      streamingCall = streamingClient.makeConnectCall(callOptions: callOptions)

      guard let streamingCall else {
        DataConnectLogger.error("Error: Failed to setup a streaming call")
        return
      }

      requestIdSequence = 0 // reset sequence
      let firstRequestId = RequestIdentifier(
        operationId: UUID().uuidString,
        sequenceNumber: nextRequestIdSequence
      )
      var firstRequest = FirebaseDataConnectStreamRequest()
      firstRequest.requestID = firstRequestId.stringValue
      firstRequest.name = connectorName
      try await streamingCall.requestStream.send(firstRequest)
      DataConnectLogger.debug("Created streaming call")

      Task {
        do {
          for try await response in streamingCall.responseStream {
            DataConnectLogger.debug("Received stream response from the server: \(response)")
            await subManager.handleResponse(response)
          }
        } catch {
          DataConnectLogger.error("Error in stream response \(error)")
        }
      }

    } catch {
      // TODO: Handle stream connect failure. Retries?
      DataConnectLogger.error("Error setting up stream: \(error)")
    }
  }

  func executeQuery<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> ServerResponse {
    guard let streamingCall else {
      DataConnectLogger.error(
        "When calling executeQueryStream(), grpc client has not been configured."
      )
      throw DataConnectInternalError.internalError(message: "Streaming call not configured")
    }

    do {
      var fdcRequest = request

      let seqRequestId = RequestIdentifier(
        operationId: fdcRequest.requestId,
        sequenceNumber: nextRequestIdSequence
      )

      let protoCodec = ProtoCodec()
      var streamRequest = FirebaseDataConnectStreamRequest()
      streamRequest.requestID = "\(seqRequestId)"
      streamRequest.execute = try protoCodec.createStreamExecuteRequest(request: fdcRequest)

      DataConnectLogger
        .debug(
          "Making streaming call with request \(streamRequest.requestID), \(streamRequest.name), \(streamRequest.execute.operationName)"
        )

      async let response = subManager.waitForResponse(for: seqRequestId)
      try DataConnectLogger.debug("Sending streaming request \(streamRequest.jsonString())")
      try await streamingCall.requestStream.send(streamRequest)
      DataConnectLogger.debug("Done sending request")

      return try await response
    } catch {
      DataConnectLogger.error("Error sending request to the server: \(error)")
      throw error
    }
  }

  func executeMutation<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: MutationRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> OperationResult<ResultType> {
    throw DataConnectInternalError
      .internalError(message: "Mutation not supported in StreamingGrpcClient")
  }

  func subscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws -> AsyncStream<ServerResponse> {
    guard let streamingCall else {
      DataConnectLogger.error(
        "When calling subscribe(), grpc streaming client has not been configured."
      )
      throw DataConnectInitError.appNotConfigured(message: "GRPC Streaming failed to setup")
    }

    var fdcRequest = request
    let hasSubscription = await subManager.hasSubscription(for: fdcRequest.requestId)

    let requestID = RequestIdentifier(
      operationId: fdcRequest.requestId,
      sequenceNumber: nextRequestIdSequence
    )
    let stream = try await subManager.createStream(for: requestID)

    if !hasSubscription {
      let protoCodec = ProtoCodec()
      var streamRequest = FirebaseDataConnectStreamRequest()
      streamRequest.requestID = requestID.stringValue
      streamRequest.subscribe = try protoCodec.createStreamExecuteRequest(request: request)

      do {
        try await streamingCall.requestStream.send(streamRequest)
      } catch {
        await subManager.removeSubscription(for: requestID)
        throw error
      }
    }

    return stream
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

// MARK: Helper types

private struct RequestIdentifier: CustomStringConvertible, Hashable, Equatable {
  let operationId: String
  let sequenceNumber: UInt64

  var stringValue: String {
    "\(operationId)|\(sequenceNumber)"
  }

  var description: String {
    stringValue
  }

  init(operationId: String, sequenceNumber: UInt64) {
    self.operationId = operationId
    self.sequenceNumber = sequenceNumber
  }

  init?(stringValue: String) {
    let components = stringValue.split(separator: "|")
    guard components.count == 2, let sequenceNumber = UInt64(components[1]),
          let operationId = String(components[0]) as String? else {
      return nil
    }

    self.operationId = operationId
    self.sequenceNumber = sequenceNumber
  }
}

private actor StreamSubscriptionManager {
  private var pendingExecuteRequests: [RequestIdentifier: CheckedContinuation<
    ServerResponse,
    Error
  >] = [:]
  private var subscriptionRequests = [RequestIdentifier: AsyncStream<ServerResponse>.Continuation]()
  private var operationSubs = [String: RequestIdentifier]()

  func waitForResponse(for requestID: RequestIdentifier) async throws -> ServerResponse {
    try await withCheckedThrowingContinuation { continuation in
      pendingExecuteRequests[requestID] = continuation
    }
  }

  func createStream(for requestID: RequestIdentifier) throws -> AsyncStream<ServerResponse> {
    if let existingReq = operationSubs[requestID.operationId] {
      removeSubscription(for: existingReq)
    }

    let stream = AsyncStream<ServerResponse> { continuation in
      subscriptionRequests[requestID] = continuation
      operationSubs[requestID.operationId] = requestID

      continuation.onTermination = { _ in
        Task { await self.removeSubscription(for: requestID) }
      }
    }
    return stream
  }

  func hasSubscription(for operationId: String) -> Bool {
    operationSubs[operationId] != nil
  }

  func removeSubscription(for requestID: RequestIdentifier) {
    if let continuation = subscriptionRequests[requestID] {
      continuation.finish()
    }
    subscriptionRequests.removeValue(forKey: requestID)
    operationSubs.removeValue(forKey: requestID.operationId)
  }

  func handleResponse(_ response: FirebaseDataConnectStreamResponse) {
    do {
      guard let reqId = RequestIdentifier(stringValue: response.requestID) else {
        DataConnectLogger.error("Error obtaining requestID from response")
        return
      }

      if let continuation = pendingExecuteRequests.removeValue(
        forKey: reqId
      ) {
        let serverResponse = try serverResponse(for: response)
        continuation.resume(returning: serverResponse)
        return
      }

      if let continuation = subscriptionRequests[reqId] {
        let serverResponse = try serverResponse(for: response)
        continuation.yield(serverResponse)
      }
    } catch {
      DataConnectLogger.error("Error handing stream response \(error)")
    }
  }

  func handleError(_ error: Error, for requestID: RequestIdentifier) {
    if let continuation = pendingExecuteRequests.removeValue(forKey: requestID) {
      continuation.resume(throwing: error)
    }
  }

  func handleStreamFailure(_ error: Error) {
    pendingExecuteRequests.values.forEach { $0.resume(throwing: error) }
    pendingExecuteRequests.removeAll()
  }

  private func serverResponse(for response: FirebaseDataConnectStreamResponse) throws
    -> ServerResponse {
    let jsonDecoder = JSONDecoder()
    var extensionResponse: ExtensionResponse?
    do {
      extensionResponse = try jsonDecoder
        .decode(ExtensionResponse.self, from: response.extensions.jsonUTF8Data())
    } catch {
      DataConnectLogger.error("Failed to decode extensions: \(error)")
    }
    return try ServerResponse(data: response.data.jsonUTF8Data(), extensions: extensionResponse)
  }
}
