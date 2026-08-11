// Copyright 2026 Google LLC
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

import Clocks
import FirebaseCore
@testable import FirebaseDataConnect
import SwiftProtobuf
import XCTest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class StreamSubscriptionManagerTests: XCTestCase {
  func testQueryExecuteRequest() async throws {
    let subManager = StreamSubscriptionManager()
    let requestID = RequestIdentifier(operationId: "test-query", sequenceNumber: 1)

    let queryContinuation = Task {
      try await subManager.waitForResponse(for: requestID)
    }

    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s

    var response = FirebaseDataConnectStreamResponse()
    response.requestID = "test-query|1"
    response.data = try Google_Protobuf_Struct(jsonString: "{\"test\": \"data\"}")
    // response.extensions is optional in the proto but the generated struct has it as a property.
    // Let's see if we need to set it or if it defaults. It defaults to a new instance.

    await subManager.handleResponse(response)

    let result = try await queryContinuation.value
    XCTAssertNotNil(result)
    let decodedData = try JSONSerialization.jsonObject(with: result.data) as? [String: String]
    XCTAssertEqual(decodedData?["test"], "data")
  }

  func testMutationExecuteRequest() async throws {
    let subManager = StreamSubscriptionManager()
    let requestID = RequestIdentifier(operationId: "test-mutation", sequenceNumber: 1)

    let mutationContinuation = Task {
      try await subManager.waitForResponse(for: requestID)
    }

    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s

    var response = FirebaseDataConnectStreamResponse()
    response.requestID = "test-mutation|1"
    response.data = try Google_Protobuf_Struct(jsonString: "{\"test\": \"mutation-data\"}")

    await subManager.handleResponse(response)

    let result = try await mutationContinuation.value
    XCTAssertNotNil(result)
    let decodedData = try JSONSerialization.jsonObject(with: result.data) as? [String: String]
    XCTAssertEqual(decodedData?["test"], "mutation-data")
  }

  func testStreamFailureResetsMutationContinuations() async throws {
    let subManager = StreamSubscriptionManager()
    let queryRequestID = RequestIdentifier(operationId: "test-query", sequenceNumber: 1)
    let mutationRequestID = RequestIdentifier(operationId: "test-mutation", sequenceNumber: 2)

    let queryContinuation = Task {
      try await subManager.waitForResponse(for: queryRequestID)
    }

    let mutationContinuation = Task {
      try await subManager.waitForResponse(for: mutationRequestID)
    }

    await subManager.saveRequest(
      FirebaseDataConnectStreamRequest(),
      for: mutationRequestID,
      type: .mutation
    )

    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s

    await subManager.handleMutationsOnDisconnect()

    queryContinuation.cancel() // Queries shouldn't fail, so we just cancel the dangling task.

    do {
      _ = try await mutationContinuation.value
      XCTFail("Mutation continuation should have thrown an error")
    } catch let error as DataConnectOperationError {
      XCTAssertEqual(
        error.response?.errors.first?.message,
        "Stream terminated while waiting for mutation response"
      )
    } catch {
      XCTFail("Unexpected error type: \(error)")
    }
  }

  func testWaitForResponseCancellation() async throws {
    let subManager = StreamSubscriptionManager()
    let requestID = RequestIdentifier(operationId: "test-cancel", sequenceNumber: 1)

    let task = Task {
      try await subManager.waitForResponse(for: requestID)
    }

    try await Task.sleep(nanoseconds: 100_000_000) // 0.1s

    task.cancel()

    do {
      _ = try await task.value
      XCTFail("Task should have been cancelled and thrown an error")
    } catch is CancellationError {
      // Success
    } catch {
      XCTFail("Unexpected error: \(error)")
    }

    let hasPending = await subManager.hasPendingExecutes()
    XCTAssertFalse(hasPending, "Execute continuation should have been removed")
  }

  func testOnIdleCallback() async throws {
    let expectation = expectation(description: "onIdle should be called")
    let testClock = TestClock()

    let subManager = StreamSubscriptionManager(clock: testClock)
    await subManager.setOnIdle {
      expectation.fulfill()
    }

    let queryRequestID = RequestIdentifier(operationId: "test-query", sequenceNumber: 1)
    let subRequestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 2)

    let stream = try await subManager.createStream(for: subRequestID)
    let queryContinuation = Task {
      try await subManager.waitForResponse(for: queryRequestID)
    }

    try await Task.sleep(nanoseconds: 50_000_000)

    await subManager.removeSubscription(for: subRequestID)

    var response = FirebaseDataConnectStreamResponse()
    response.requestID = "test-query|1"
    response.data = try Google_Protobuf_Struct(jsonString: "{\"test\": \"data\"}")
    await subManager.handleResponse(response)

    _ = try await queryContinuation.value

    // Advance virtual time by 15s to trigger onIdle
    await testClock.advance(by: .seconds(15))

    await fulfillment(of: [expectation], timeout: 1.0)

    _ = stream
  }

  func testGracePeriodDelaysOnIdle() async throws {
    let expectation = expectation(description: "onIdle should be called after grace period")
    let testClock = TestClock()

    let subManager = StreamSubscriptionManager(clock: testClock)
    await subManager.setOnIdle {
      expectation.fulfill()
    }

    let subRequestID = RequestIdentifier(operationId: "test-sub-grace", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: subRequestID)

    // Remove subscription
    await subManager.removeSubscription(for: subRequestID)

    // Advance virtual time by 14.9 seconds (just before 15s grace period expires)
    await testClock.advance(by: .seconds(14.9))
    let hasAnySub = await subManager.hasAnySubscription()
    XCTAssertFalse(hasAnySub)

    // Advance virtual time by remaining 0.1 seconds (total 15.0s)
    await testClock.advance(by: .seconds(0.1))

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream
  }

  func testResubscribeWithinGracePeriodCancelsTimer() async throws {
    let expectation = expectation(description: "onIdle should NOT be called if resubscribed")
    expectation.isInverted = true
    let testClock = TestClock()

    let subManager = StreamSubscriptionManager(clock: testClock)
    await subManager.setOnIdle {
      expectation.fulfill()
    }

    let subRequestID1 = RequestIdentifier(operationId: "test-sub-1", sequenceNumber: 1)
    let stream1 = try await subManager.createStream(for: subRequestID1)

    // Unsubscribe stream 1
    await subManager.removeSubscription(for: subRequestID1)

    // Advance virtual time 14.9s (just before 15s grace period expires)
    await testClock.advance(by: .seconds(14.9))

    // Resubscribe stream 2
    let subRequestID2 = RequestIdentifier(operationId: "test-sub-2", sequenceNumber: 2)
    let stream2 = try await subManager.createStream(for: subRequestID2)

    // Advance virtual time past the original 15s duration
    await testClock.advance(by: .seconds(15))

    // Fulfill inverted expectation (assert onIdle was never called)
    await fulfillment(of: [expectation], timeout: 0.1)

    _ = stream1
    _ = stream2
  }

  enum TestOperationType {
    case query
    case mutation
  }

  private func setUpTestEnvironment() async -> (subManager: StreamSubscriptionManager, testClock: TestClock<Duration>, expectation: XCTestExpectation) {
    let expectation = expectation(description: "onIdle should be called")
    let testClock = TestClock()
    let subManager = StreamSubscriptionManager(clock: testClock)
    await subManager.setOnIdle {
      expectation.fulfill()
    }
    return (subManager, testClock, expectation)
  }

  private func startPendingExecute(
    _ manager: StreamSubscriptionManager,
    type: TestOperationType,
    operationId: String = "test-op",
    sequenceNumber: UInt64 = 2
  ) async throws -> (id: RequestIdentifier, task: Task<ServerResponse, Error>) {
    let id = RequestIdentifier(operationId: operationId, sequenceNumber: sequenceNumber)
    let task = Task {
      try await manager.waitForResponse(for: id)
    }

    // Wait for the execute to be registered
    while await !manager.hasPendingExecutes() {
      try await Task.sleep(nanoseconds: 5_000_000)
    }

    return (id, task)
  }

  private func completeExecute(
    _ manager: StreamSubscriptionManager,
    id: RequestIdentifier,
    type: TestOperationType,
    task: Task<ServerResponse, Error>
  ) async throws {
    var response = FirebaseDataConnectStreamResponse()
    response.requestID = "\(id.operationId)|\(id.sequenceNumber)"
    let jsonString = type == .query ? "{\"status\": \"query-ok\"}" : "{\"status\": \"mutation-ok\"}"
    response.data = try Google_Protobuf_Struct(jsonString: jsonString)
    await manager.handleResponse(response)
    _ = try await task.value
  }

  func testPendingQueryCompletesWithinGracePeriod() async throws {
    let (subManager, testClock, expectation) = await setUpTestEnvironment()

    let subRequestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: subRequestID)

    let (queryID, queryTask) = try await startPendingExecute(subManager, type: .query)

    // Unsubscribe last subscriber -> starts grace period immediately
    await subManager.removeSubscription(for: subRequestID)

    // Complete execute within grace period (at 5 seconds)
    await testClock.advance(by: .seconds(5))
    try await completeExecute(subManager, id: queryID, type: .query, task: queryTask)

    // 14.9s after unsubscribe (5s + 9.9s) -> shouldn't disconnect yet
    await testClock.advance(by: .seconds(9.9))

    // Remaining 0.1s (total 15.0s) -> should trigger disconnect
    await testClock.advance(by: .seconds(0.1))

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream
  }

  func testPendingMutationCompletesWithinGracePeriod() async throws {
    let (subManager, testClock, expectation) = await setUpTestEnvironment()

    let subRequestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: subRequestID)

    let (mutationID, mutationTask) = try await startPendingExecute(subManager, type: .mutation)

    // Unsubscribe last subscriber -> starts grace period immediately
    await subManager.removeSubscription(for: subRequestID)

    // Complete execute within grace period (at 5 seconds)
    await testClock.advance(by: .seconds(5))
    try await completeExecute(subManager, id: mutationID, type: .mutation, task: mutationTask)

    // 14.9s after unsubscribe (5s + 9.9s) -> shouldn't disconnect yet
    await testClock.advance(by: .seconds(9.9))

    // Remaining 0.1s (total 15.0s) -> should trigger disconnect
    await testClock.advance(by: .seconds(0.1))

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream
  }

  func testPendingQueryCompletesAfterGracePeriod() async throws {
    let (subManager, testClock, expectation) = await setUpTestEnvironment()

    let subRequestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: subRequestID)

    let (queryID, queryTask) = try await startPendingExecute(subManager, type: .query)

    // Unsubscribe last subscriber -> starts grace period immediately
    await subManager.removeSubscription(for: subRequestID)

    // Advance time past 15 seconds (e.g. 20s) -> shouldn't disconnect because query is pending
    await testClock.advance(by: .seconds(20))

    // Complete the query response -> should disconnect immediately
    try await completeExecute(subManager, id: queryID, type: .query, task: queryTask)

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream
  }

  func testPendingMutationCompletesAfterGracePeriod() async throws {
    let (subManager, testClock, expectation) = await setUpTestEnvironment()

    let subRequestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: subRequestID)

    let (mutationID, mutationTask) = try await startPendingExecute(subManager, type: .mutation)

    // Unsubscribe last subscriber -> starts grace period immediately
    await subManager.removeSubscription(for: subRequestID)

    // Advance time past 15 seconds (e.g. 20s) -> shouldn't disconnect because mutation is pending
    await testClock.advance(by: .seconds(20))

    // Complete the mutation response -> should disconnect immediately
    try await completeExecute(subManager, id: mutationID, type: .mutation, task: mutationTask)

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream
  }

  func testPendingQueryCompletesAfterGracePeriodWithResubscribe() async throws {
    let (subManager, testClock, expectation) = await setUpTestEnvironment()

    let subRequestID = RequestIdentifier(operationId: "test-sub-1", sequenceNumber: 1)
    let stream1 = try await subManager.createStream(for: subRequestID)

    let (queryID, queryTask) = try await startPendingExecute(subManager, type: .query)

    // Unsubscribe last subscriber -> starts grace period immediately
    await subManager.removeSubscription(for: subRequestID)

    // Advance time past 15 seconds (e.g. 17s) -> shouldn't disconnect because query is pending
    await testClock.advance(by: .seconds(17))

    // A new subscriber subscribes before the query completes
    let subRequestID2 = RequestIdentifier(operationId: "test-sub-2", sequenceNumber: 3)
    let stream2 = try await subManager.createStream(for: subRequestID2)

    // Complete the query response
    try await completeExecute(subManager, id: queryID, type: .query, task: queryTask)

    // Advance time by 20s -> shouldn't disconnect because new subscriber is still active
    await testClock.advance(by: .seconds(20))

    // New subscriber unsubscribes -> starts new grace period
    await subManager.removeSubscription(for: subRequestID2)

    // Advance by 14.9s -> shouldn't disconnect yet
    await testClock.advance(by: .seconds(14.9))

    // Advance remaining 0.1s -> should disconnect
    await testClock.advance(by: .seconds(0.1))

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream1
    _ = stream2
  }

  func testPendingMutationCompletesAfterGracePeriodWithResubscribe() async throws {
    let (subManager, testClock, expectation) = await setUpTestEnvironment()

    let subRequestID = RequestIdentifier(operationId: "test-sub-1", sequenceNumber: 1)
    let stream1 = try await subManager.createStream(for: subRequestID)

    let (mutationID, mutationTask) = try await startPendingExecute(subManager, type: .mutation)

    // Unsubscribe last subscriber -> starts grace period immediately
    await subManager.removeSubscription(for: subRequestID)

    // Advance time past 15 seconds (e.g. 17s) -> shouldn't disconnect because mutation is pending
    await testClock.advance(by: .seconds(17))

    // A new subscriber subscribes before the mutation completes
    let subRequestID2 = RequestIdentifier(operationId: "test-sub-2", sequenceNumber: 3)
    let stream2 = try await subManager.createStream(for: subRequestID2)

    // Complete the mutation response
    try await completeExecute(subManager, id: mutationID, type: .mutation, task: mutationTask)

    // Advance time by 20s -> shouldn't disconnect because new subscriber is still active
    await testClock.advance(by: .seconds(20))

    // New subscriber unsubscribes -> starts new grace period
    await subManager.removeSubscription(for: subRequestID2)

    // Advance by 14.9s -> shouldn't disconnect yet
    await testClock.advance(by: .seconds(14.9))

    // Advance remaining 0.1s -> should disconnect
    await testClock.advance(by: .seconds(0.1))

    await fulfillment(of: [expectation], timeout: 1.0)
    _ = stream1
    _ = stream2
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension TestClock: DataConnectClock where Duration == Swift.Duration {
  public func sleep(for nanoseconds: UInt64) async throws {
    try await self.sleep(for: .nanoseconds(nanoseconds))
  }
}
