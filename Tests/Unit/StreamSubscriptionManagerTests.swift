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
}
