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

import Combine
import FirebaseCore
@testable import FirebaseDataConnect
import XCTest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class RealtimeTests: IntegrationTestBase {
  override func setUp(completion: @escaping ((any Error)?) -> Void) {
    Task {
      do {
        try await ProjectConfigurator.shared.configureProject()
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }

  private func makeConnector() -> KitchenSinkConnector {
    return DataConnect.kitchenSinkConnector
  }

  // 1. Query should automatically refresh when a mutation is run.
  // The GetStandardScalar query has been configured to refresh for the CreateStandardScalar
  // mutation.
  func testMutationRefresh() async throws {
    let connector = makeConnector()
    let id = UUID()

    // Populate initial data
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 10,
      text: "initial text",
      decimal: 10.0
    )

    var results = [GetStandardScalarQuery.Data]()
    let initialExpectation = XCTestExpectation(description: "Received initial result")
    let refreshExpectation = XCTestExpectation(description: "Received mutation refresh result")

    let queryRef = connector.getStandardScalarQuery.ref(id: id)
    let pub = try await queryRef.subscribe()
    let cancellable = pub
      .receive(on: DispatchQueue.main)
      .sink { result in
        switch result {
        case let .success(res):
          if let data = res.data {
            results.append(data)
            if results.count == 1 {
              initialExpectation.fulfill()
            } else if results.count == 2 {
              refreshExpectation.fulfill()
            }
          }
        case let .failure(err):
          XCTFail("Subscription failed: \(err)")
        }
      }

    // Wait for initial result
    await fulfillment(of: [initialExpectation], timeout: 5.0)

    // Now execute mutation
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 20,
      text: "mutation refreshed text",
      decimal: 20.0
    )

    // Wait for refresh result
    await fulfillment(of: [refreshExpectation], timeout: 5.0)

    XCTAssertEqual(results.last?.standardScalars?.text, "mutation refreshed text")
    cancellable.cancel()
  }

  // 2. Query should automatically refresh every N seconds.
  // The GetLargeNum query has been configured to refresh every 2 seconds.
  func testPeriodicRefresh() async throws {
    let connector = makeConnector()
    let id = UUID()

    _ = try await connector.createLargeNumMutation.execute(
      id: id,
      num: 100,
      maxNum: 1000,
      minNum: 1
    )

    var results = [GetLargeNumQuery.Data]()
    let initialExpectation = XCTestExpectation(description: "Received initial result")
    let periodicExpectation = XCTestExpectation(description: "Received periodic refresh result")

    let queryRef = connector.getLargeNumQuery.ref(id: id)
    let pub = try await queryRef.subscribe()
    let cancellable = pub
      .receive(on: DispatchQueue.main)
      .sink { result in
        switch result {
        case let .success(res):
          if let data = res.data {
            results.append(data)
            if results.count == 1 {
              initialExpectation.fulfill()
            } else if results.count == 2 {
              periodicExpectation.fulfill()
            }
          }
        case let .failure(err):
          XCTFail("Subscription failed: \(err)")
        }
      }

    // Wait for initial result
    await fulfillment(of: [initialExpectation], timeout: 5.0)

    // Wait for periodic refresh (configured for 10 seconds, timeout after 15 seconds)
    await fulfillment(of: [periodicExpectation], timeout: 15.0)

    XCTAssertGreaterThanOrEqual(results.count, 2)
    cancellable.cancel()
  }

  private func assertCondition(timeout: TimeInterval = 5.0,
                               message: String,
                               condition: @escaping () async -> Bool) async throws {
    let startTime = Date()
    while Date().timeIntervalSince(startTime) < timeout {
      if await condition() {
        return
      }
      try await Task.sleep(nanoseconds: 50_000_000) // 50ms poll interval
    }
    XCTFail(message)
  }

  // 3. Test unsubscribe.
  // The grpc streaming connection should disconnect when there are no more subscriptions.
  func testUnsubscribe() async throws {
    let connector = makeConnector()
    let id = UUID()

    do {
      let queryRef = connector.getStandardScalarQuery.ref(id: id)
      let pub = try await queryRef.subscribe()
      let cancellable = pub.sink { _ in }

      // Poll until subscription becomes active
      try await assertCondition(
        timeout: 5.0,
        message: "Expected active subscription after subscribe"
      ) {
        await connector.dataConnect.grpcClient.hasActiveSubscriptions()
      }

      // Cancel subscription
      cancellable.cancel()
    }

    // Poll until subscription becomes disconnected
    try await assertCondition(
      timeout: 5.0,
      message: "Expected no active subscriptions after cancel"
    ) {
      await !connector.dataConnect.grpcClient.hasActiveSubscriptions()
    }
  }

  // 4. Before the first subscribe any execute operations should use unarygrpcclient.
  // So the streaming connection should be null / not connected.
  func testExecuteBeforeSubscribeUsesUnary() async throws {
    let connector = makeConnector()
    let id = UUID()

    // Verify streaming connection is initially null / not connected
    let isConnectedBefore = await connector.dataConnect.grpcClient.isStreamingConnected()
    XCTAssertFalse(
      isConnectedBefore,
      "Expected streaming connection to be null/not connected before subscribe"
    )

    // Execute a query
    _ = try await connector.getStandardScalarQuery.execute(id: id)

    // Verify streaming connection is STILL null / not connected
    let isConnectedAfterExecute = await connector.dataConnect.grpcClient.isStreamingConnected()
    XCTAssertFalse(
      isConnectedAfterExecute,
      "Expected execute before subscribe to use unary client, leaving streaming disconnected"
    )

    // Now subscribe and verify streaming connects
    do {
      let queryRef = connector.getStandardScalarQuery.ref(id: id)
      let pub = try await queryRef.subscribe()
      let cancellable = pub.sink { _ in }

      // Poll until streaming connects
      try await assertCondition(
        timeout: 5.0,
        message: "Expected streaming connection to be active after subscribe"
      ) {
        await connector.dataConnect.grpcClient.isStreamingConnected()
      }
      cancellable.cancel()
    }
  }

  // 5. The GRPC stream is closed if there are no external subscribers.
  // However ObservableQueryRefs sinks are still receiving updates performed by execute() calls.
  func testExecuteUpdatesObservableQueryRefAfterUnsubscribe() async throws {
    let connector = makeConnector()
    let id = UUID()

    // Create initial data
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 10,
      text: "initial text",
      decimal: 10.0
    )

    let queryRef = connector.getStandardScalarQuery.ref(id: id)

    do {
      let pub = try await queryRef.subscribe()
      let cancellable = pub.sink { _ in }

      // Poll until subscription becomes active
      try await assertCondition(
        timeout: 5.0,
        message: "Expected active subscription after subscribe"
      ) {
        await connector.dataConnect.grpcClient.hasActiveSubscriptions()
      }

      // Cancel subscription
      cancellable.cancel()
    }

    // Poll until subscription becomes disconnected
    try await assertCondition(
      timeout: 5.0,
      message: "Expected no active subscriptions after cancel"
    ) {
      await !connector.dataConnect.grpcClient.hasActiveSubscriptions()
    }

    // Poll until streaming connection disconnects
    try await assertCondition(
      timeout: 5.0,
      message: "Expected streaming connection to disconnect after cancel"
    ) {
      await !connector.dataConnect.grpcClient.isStreamingConnected()
    }

    // Verify that queryRef data is initially "initial text"
    XCTAssertEqual(queryRef.data?.standardScalars?.text, "initial text")

    // Now update data on the server using mutation
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 20,
      text: "updated text",
      decimal: 20.0
    )

    // Now call execute() on queryRef using serverOnly
    _ = try await queryRef.execute(fetchPolicy: .serverOnly)

    // Verify that queryRef.data is now updated to "updated text" even though streaming is
    // disconnected
    XCTAssertEqual(queryRef.data?.standardScalars?.text, "updated text")

    // Verify streaming is STILL disconnected
    let hasActiveSubscriptions = await connector.dataConnect.grpcClient.hasActiveSubscriptions()
    XCTAssertFalse(
      hasActiveSubscriptions,
      "Expected no active subscriptions after execute"
    )

    let isStreamingConnected = await connector.dataConnect.grpcClient.isStreamingConnected()
    XCTAssertFalse(
      isStreamingConnected,
      "Expected streaming connection to remain disconnected after execute"
    )
  }
}
