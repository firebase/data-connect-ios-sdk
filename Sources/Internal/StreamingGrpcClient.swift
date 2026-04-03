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
  private var connectionTask: Task<Void, Never>?
  private var reconnectTask: Task<Void, Never>?
  private var responseStreamTask: Task<Void, Never>?

  private var authListenerHandle: AuthStateDidChangeListenerHandle?
  private var currentUid: String?
  private var pendingNewToken: String?

  private var requestIdSequence: UInt64 = 1

  private var nextRequestIdSequence: UInt64 {
    requestIdSequence += 1
    return requestIdSequence
  }

  private lazy var streamingClient: FirebaseDataConnectStreamingClient? = {
    authListenerHandle = auth.addStateDidChangeListener { [weak self] auth, user in
      Task { [weak self] in
        await self?.authStatusChanged(user: user)
      }
    }
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

    currentUid = auth.currentUser?.uid
  }

  deinit {
    if let handle = authListenerHandle {
      auth.removeStateDidChangeListener(handle)
    }
  }

  private func authStatusChanged(user: User?) async {
    let newUid = user?.uid
    if newUid != currentUid {
      DataConnectLogger
        .debug(
          "Auth identity changed from \(currentUid ?? "nil") to \(newUid ?? "nil"). Disconnecting stream."
        )

      currentUid = newUid
      pendingNewToken = nil

      await subManager.handleAuthStateChange()
      await streamingCall?.requestStream.finish()
    } else if let user = user {
      DataConnectLogger
        .debug("Auth token refreshed for user \(newUid ?? "nil"). Updating on stream.")
      do {
        let token = try await user.getIDToken()
        let hasSubs = await subManager.hasAnySubscription()
        if hasSubs {
          var headerRequest = FirebaseDataConnectStreamRequest()
          headerRequest.headers[GrpcClientRequestHeaders.firebaseAuthToken] = token

          if let call = streamingCall {
            try await call.requestStream.send(headerRequest)
            DataConnectLogger.debug("Sent new auth token on stream.")
          } else {
            DataConnectLogger.debug("Stream not active, storing token for next request.")
            pendingNewToken = token
          }
        } else {
          DataConnectLogger.debug("No active subscriptions, storing token for next request.")
          pendingNewToken = token
        }
      } catch {
        DataConnectLogger.error("Failed to get ID token: \(error)")
      }
    }
  }

  func connectStream() async {
    if let existingTask = connectionTask {
      _ = await existingTask.result
      return
    }
    if let existingReconnectTask = reconnectTask {
      _ = await existingReconnectTask.result
      return
    }

    connectionTask = Task {
      defer { connectionTask = nil }
      do {
        try await internalConnectStream()
      } catch {
        DataConnectLogger.error("Explicit connectStream failed: \(error)")
      }
    }
    _ = await connectionTask?.result
  }

  private func internalConnectStream() async throws {
    guard let streamingClient else {
      DataConnectLogger.error(
        "When calling internalConnectStream(), gRPC client has not been configured."
      )
      throw DataConnectInternalError.internalError(message: "Streaming client not configured")
    }
    guard streamingCall == nil else {
      DataConnectLogger.debug(
        "gRPC stream already set up. Ignoring internalConnectStream() call."
      )
      return
    }
    guard responseStreamTask == nil else {
      DataConnectLogger
        .debug("Already listening to responseStream. Ignoring internalConnectStream() call.")
      return
    }

    let callOptions = await createCallOptions()
    let call = streamingClient.makeConnectCall(callOptions: callOptions)

    let firstRequestId = RequestIdentifier(
      operationId: UUID().uuidString,
      sequenceNumber: nextRequestIdSequence
    )
    var firstRequest = FirebaseDataConnectStreamRequest()
    firstRequest.requestID = firstRequestId.stringValue
    firstRequest.name = connectorName
    try await call.requestStream.send(firstRequest)
    DataConnectLogger.debug("Created streaming call")

    responseStreamTask = Task {
      do {
        for try await response in call.responseStream {
          DataConnectLogger.debug("Received stream response from the server: \(response)")
          await subManager.handleResponse(response)
        }
        DataConnectLogger.error("Server closed stream while client is still expecting responses.")
      } catch {
        DataConnectLogger.error("Stream terminated with error: \(error)")
      }
      await handleStreamDisconnect()
    }

    streamingCall = call
  }

  private func handleStreamDisconnect() async {
    streamingCall = nil
    responseStreamTask = nil
    await subManager.handleMutationsOnDisconnect()

    let hasSubs = await subManager.hasAnySubscription()
    let hasPending = await subManager.hasPendingExecutes()
    if hasSubs || hasPending {
      await startReconnectLoop()
    }
  }

  private func startReconnectLoop() async {
    guard reconnectTask == nil else { return }

    reconnectTask = Task {
      defer { reconnectTask = nil }

      var backoffSeconds = 1.0
      let maxBackoffSeconds = 30.0
      let backoffMultiplier = 1.3

      while !Task.isCancelled {
        do {
          try await Task.sleep(nanoseconds: UInt64(backoffSeconds * 1_000_000_000))

          DataConnectLogger.debug("Attempting to reconnect stream...")
          try await internalConnectStream()

          if let call = streamingCall {
            let requests = await subManager.getResendableRequests()
            for req in requests {
              try await call.requestStream.send(req)
            }
            break
          }
          DataConnectLogger.debug("Stream closed before active requests could be re-sent.")
        } catch {
          DataConnectLogger.error("Reconnect failed: \(error)")
          streamingCall = nil
          responseStreamTask = nil

          let randomFactor = Double.random(in: 0.9 ... 1.1)
          let nextBackoff = backoffSeconds * backoffMultiplier
          backoffSeconds = min(nextBackoff * randomFactor, maxBackoffSeconds)

          let hasSubs = await subManager.hasAnySubscription()
          let hasPending = await subManager.hasPendingExecutes()
          if !hasSubs && !hasPending {
            break
          }
        }
      }
    }
  }

  func executeQuery<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> ServerResponse {
    var fdcRequest = request
    let requestId = fdcRequest.requestId
    return try await executeOperation(request: fdcRequest, requestId: requestId)
  }

  func executeMutation<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: MutationRequest<VariableType>,
    resultType: ResultType.Type)
    async throws -> OperationResult<ResultType> {
    var fdcRequest = request
    let requestId = fdcRequest.requestId
    let serverResponse = try await executeOperation(request: fdcRequest, requestId: requestId)
    let jsonDecoder = JSONDecoder()
    let decodedResults = try jsonDecoder.decode(ResultType.self, from: serverResponse.data)
    return OperationResult(data: decodedResults, source: .server)
  }

  private func executeOperation<Req: OperationRequest>(request: Req,
                                                       requestId: String) async throws
    -> ServerResponse {
    guard let streamingCall else {
      DataConnectLogger.error(
        "When calling executeOperation(), gRPC client has not been configured."
      )
      throw DataConnectInternalError.internalError(message: "Streaming call not configured")
    }

    do {
      let seqRequestId = RequestIdentifier(
        operationId: requestId,
        sequenceNumber: nextRequestIdSequence
      )

      let protoCodec = ProtoCodec()
      var streamRequest = FirebaseDataConnectStreamRequest()
      streamRequest.requestID = "\(seqRequestId)"
      streamRequest.execute = try protoCodec.createStreamExecuteRequest(request: request)

      if let token = pendingNewToken {
        streamRequest.headers[GrpcClientRequestHeaders.firebaseAuthToken] = token
        pendingNewToken = nil
      }

      DataConnectLogger
        .debug(
          "Making streaming call with request \(streamRequest.requestID), \(streamRequest.name), \(streamRequest.execute.operationName)"
        )

      async let response = subManager.waitForResponse(for: seqRequestId)
      try DataConnectLogger.debug("Sending streaming request \(streamRequest.jsonString())")
      if request is MutationRequest<Req.Variable> {
        await subManager
          .saveRequest(streamRequest, for: seqRequestId, type: RequestType.mutation)
      } else {
        await subManager.saveRequest(streamRequest, for: seqRequestId, type: RequestType.query)
      }
      do {
        try await streamingCall.requestStream.send(streamRequest)
      } catch {
        await subManager.handleError(error, for: seqRequestId)
        throw error
      }
      DataConnectLogger.debug("Done sending request")

      return try await response
    } catch {
      DataConnectLogger.error("Error sending request to the server: \(error)")
      throw error
    }
  }

  func subscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws -> AsyncStream<ServerResponse> {
    await connectStream()

    guard let streamingCall else {
      DataConnectLogger.error(
        "When calling subscribe(), gRPC streaming client has not been configured."
      )
      throw DataConnectInitError.appNotConfigured(message: "GRPC Streaming failed to setup")
    }

    var fdcRequest = request
    let hasSubscription = await subManager.hasSubscription(for: fdcRequest.requestId)
    if hasSubscription {
      DataConnectLogger
        .debug("subscribe() called multiple times for the same request: \(fdcRequest.requestId)")
    }

    let requestID = RequestIdentifier(
      operationId: fdcRequest.requestId,
    )
    let stream = try await subManager.createStream(for: requestID)

    if !hasSubscription {
      let protoCodec = ProtoCodec()
      var streamRequest = FirebaseDataConnectStreamRequest()
      streamRequest.requestID = requestID.stringValue
      streamRequest.subscribe = try protoCodec.createStreamExecuteRequest(request: request)

      if let token = pendingNewToken {
        streamRequest.headers[GrpcClientRequestHeaders.firebaseAuthToken] = token
        pendingNewToken = nil
      }

      do {
        await subManager.saveRequest(streamRequest, for: requestID, type: RequestType.subscribe)
        try await streamingCall.requestStream.send(streamRequest)
      } catch {
        await subManager.removeSubscription(for: requestID)
        throw error
      }
    }

    return stream
  }

  func unsubscribe<
    ResultType: Decodable,
    VariableType: OperationVariable
  >(request: QueryRequest<VariableType>,
    resultType: ResultType.Type) async throws {
    var fdcRequest = request
    await subManager.removeSubscription(for: RequestIdentifier(operationId: fdcRequest.requestId))
  }

  func hasActiveSubscriptions() async -> Bool {
    await subManager.hasAnySubscription()
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

struct RequestIdentifier: CustomStringConvertible, Hashable, Equatable {
  let operationId: String
  let sequenceNumber: UInt64

  var stringValue: String {
    "\(operationId)|\(sequenceNumber)"
  }

  var description: String {
    stringValue
  }

  init(operationId: String) {
    self.operationId = operationId
    sequenceNumber = 0
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

enum RequestType {
  case query
  case mutation
  case subscribe
}

actor StreamSubscriptionManager {
  // These structures map request IDs to continuations, for propagating response data back to the
  // query layer.
  private var executeContinuations: [RequestIdentifier: CheckedContinuation<
    ServerResponse,
    Error
  >] = [:]
  private var subscribeContinuations =
    [RequestIdentifier: AsyncStream<ServerResponse>.Continuation]()

  // These structures map request IDs to request bodies, for re-sending requests if the stream
  // connection unexpectedly terminates, as well as for de-duplicating identical requests. We do not
  // re-send or de-duplicate mutation execution requests, as those are not idempotent.
  private var activeSubscribeRequests: [
    RequestIdentifier: FirebaseDataConnectStreamRequest
  ] =
    [:]
  private var activeQueryExecuteRequests: [RequestIdentifier: FirebaseDataConnectStreamRequest] =
    [:]
  private var activeMutationExecuteRequests: Set<RequestIdentifier> = []

  func saveRequest(_ request: FirebaseDataConnectStreamRequest,
                   for requestID: RequestIdentifier,
                   type: RequestType) {
    switch type {
    case .query:
      activeQueryExecuteRequests[requestID] = request
    case .mutation:
      activeMutationExecuteRequests.insert(requestID)
    case .subscribe:
      activeSubscribeRequests[requestID] = request
    }
  }

  func getResendableRequests() -> [FirebaseDataConnectStreamRequest] {
    Array(activeSubscribeRequests.values) + Array(activeQueryExecuteRequests.values)
  }

  func waitForResponse(for requestID: RequestIdentifier) async throws -> ServerResponse {
    try await withTaskCancellationHandler {
      try await withCheckedThrowingContinuation { continuation in
        guard !Task.isCancelled else {
          continuation.resume(throwing: CancellationError())
          return
        }
        executeContinuations[requestID] = continuation
      }
    } onCancel: {
      Task {
        await self.cancelPendingExecute(for: requestID)
      }
    }
  }

  func cancelPendingExecute(for requestID: RequestIdentifier) {
    if let continuation = executeContinuations.removeValue(forKey: requestID) {
      continuation.resume(throwing: CancellationError())
    }
    activeQueryExecuteRequests.removeValue(forKey: requestID)
    activeMutationExecuteRequests.remove(requestID)
  }

  func createStream(for requestID: RequestIdentifier) throws -> AsyncStream<ServerResponse> {
    if let continuation = subscribeContinuations[requestID] {
      // This shouldn't occur, as subscribes should be de-duplicated earlier, but we want to handle
      // it gracefully in case.
      continuation.finish()
    }

    let stream = AsyncStream<ServerResponse> { continuation in
      subscribeContinuations[requestID] = continuation

      continuation.onTermination = { _ in
        Task { await self.removeSubscription(for: requestID) }
      }
    }
    return stream
  }

  func hasSubscription(for operationId: String) -> Bool {
    subscribeContinuations[RequestIdentifier(operationId: operationId)] != nil
  }

  func hasAnySubscription() -> Bool {
    !subscribeContinuations.isEmpty
  }

  func hasPendingExecutes() -> Bool {
    !executeContinuations.isEmpty
  }

  func removeSubscription(for requestID: RequestIdentifier) {
    if let continuation = subscribeContinuations.removeValue(forKey: requestID) {
      continuation.finish()
    }
    activeSubscribeRequests.removeValue(forKey: requestID)
  }

  func handleResponse(_ response: FirebaseDataConnectStreamResponse) {
    do {
      guard let reqId = RequestIdentifier(stringValue: response.requestID) else {
        DataConnectLogger.error("Error obtaining requestID from response")
        return
      }

      if let continuation = executeContinuations.removeValue(
        forKey: reqId
      ) {
        activeQueryExecuteRequests.removeValue(forKey: reqId)
        activeMutationExecuteRequests.remove(reqId)
        do {
          let serverResponse = try serverResponse(for: response)
          continuation.resume(returning: serverResponse)
        } catch {
          continuation.resume(throwing: error)
        }
        return
      }

      if let continuation = subscribeContinuations[reqId] {
        do {
          let serverResponse = try serverResponse(for: response)
          continuation.yield(serverResponse)
        } catch {
          DataConnectLogger.error("Error handling stream response: \(error)")
        }
      }
    } catch {
      DataConnectLogger.error("Error handling stream response \(error)")
    }
  }

  func handleMutationsOnDisconnect() {
    let mutations = Array(activeMutationExecuteRequests)
    let errStr = "Stream terminated while waiting for mutation response"
    let failureResponse = OperationFailureResponse(
      rawJsonData: "",
      errors: [.init(message: errStr, path: [])],
      data: nil
    )
    for reqId in mutations {
      if let continuation = executeContinuations.removeValue(forKey: reqId) {
        activeMutationExecuteRequests.remove(reqId)
        continuation
          .resume(throwing: DataConnectOperationError.executionFailed(response: failureResponse))
      } else {
        DataConnectLogger
          .debug("No continuation found for pending mutation with request ID \(reqId)")
      }
    }
  }

  func handleAuthStateChange() {
    for value in subscribeContinuations.values {
      value.finish()
    }
    subscribeContinuations.removeAll()
    activeSubscribeRequests.removeAll()

    let errStr = "Authentication state change occured while waiting for stream response"
    let failureResponse = OperationFailureResponse(
      rawJsonData: "",
      errors: [.init(message: errStr, path: [])],
      data: nil
    )
    for value in executeContinuations.values {
      value.resume(throwing: DataConnectOperationError.executionFailed(response: failureResponse))
    }
    executeContinuations.removeAll()
    activeQueryExecuteRequests.removeAll()
    activeMutationExecuteRequests.removeAll()
  }

  func handleError(_ error: Error, for reqId: RequestIdentifier) {
    if let continuation = executeContinuations.removeValue(forKey: reqId) {
      activeQueryExecuteRequests.removeValue(forKey: reqId)
      activeMutationExecuteRequests.remove(reqId)
      continuation.resume(throwing: error)
    }
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
    let errorInfoList = DataConnectGrpcClient.createErrorInfoList(errors: response.errors)
    guard errorInfoList.isEmpty else {
      let resultsString = try response.data.jsonString()
      // TODO: Decode results here like in the UnaryClient.
      let failureResponse = OperationFailureResponse(
        rawJsonData: resultsString,
        errors: errorInfoList,
        data: nil
      )
      throw
        DataConnectOperationError
        .executionFailed(
          response: failureResponse
        )
    }
    let jsonData = try response.data.jsonUTF8Data()
    return ServerResponse(data: jsonData, extensions: extensionResponse)
  }
}
