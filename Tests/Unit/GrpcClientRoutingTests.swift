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

import FirebaseCore
@testable import FirebaseDataConnect
import XCTest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class GrpcClientRoutingTests: XCTestCase {

  func testHasAnySubscriptionInitiallyFalse() async throws {
    let subManager = StreamSubscriptionManager()
    let hasSub = await subManager.hasAnySubscription()
    XCTAssertFalse(hasSub)
  }

  func testHasAnySubscriptionWhenSubscribed() async throws {
    let subManager = StreamSubscriptionManager()
    let requestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: requestID)

    let hasSub = await subManager.hasAnySubscription()
    XCTAssertTrue(hasSub)

    _ = stream
  }

  func testHasAnySubscriptionDuringGracePeriod() async throws {
    let subManager = StreamSubscriptionManager()
    let requestID = RequestIdentifier(operationId: "test-sub", sequenceNumber: 1)
    let stream = try await subManager.createStream(for: requestID)

    await subManager.removeSubscription(for: requestID)

    // During grace period, active subscriptions MUST return false
    // so DataConnectGrpcClient routes executeQuery/executeMutation to unaryClient
    let hasSub = await subManager.hasAnySubscription()
    XCTAssertFalse(hasSub)

    _ = stream
  }
}
