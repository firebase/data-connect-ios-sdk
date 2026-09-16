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
import GRPC
import XCTest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestResultData: Codable, Sendable {
  let value: String
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct TestVariables: OperationVariable {}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private actor MockAuthGrpcClient: GrpcClient {
  var streamContinuations: [AsyncThrowingStream<ServerResponse, Error>.Continuation] = []

  func executeQuery<ResultType: Decodable, VariableType: OperationVariable>(
    request: QueryRequest<VariableType>,
    resultType: ResultType.Type
  ) async throws -> ServerResponse {
    throw DataConnectInternalError.internalError(message: "Not implemented")
  }

  func executeMutation<ResultType: Decodable, VariableType: OperationVariable>(
    request: MutationRequest<VariableType>,
    resultType: ResultType.Type
  ) async throws -> OperationResult<ResultType> {
    throw DataConnectInternalError.internalError(message: "Not implemented")
  }

  func subscribe<ResultType: Decodable, VariableType: OperationVariable>(
    request: QueryRequest<VariableType>,
    resultType: ResultType.Type
  ) async throws -> AsyncThrowingStream<ServerResponse, Error> {
    let stream = AsyncThrowingStream<ServerResponse, Error> { continuation in
      self.streamContinuations.append(continuation)
    }
    return stream
  }

  func unsubscribe<VariableType: OperationVariable>(
    request: QueryRequest<VariableType>
  ) async throws {}

  func hasActiveSubscriptions() async -> Bool {
    !streamContinuations.isEmpty
  }

  func isStreamingConnected() async -> Bool {
    true
  }

  func createCallOptions() async -> CallOptions {
    CallOptions()
  }

  func finishLatestStream(throwing error: Error) {
    if let continuation = streamContinuations.popLast() {
      continuation.finish(throwing: error)
    }
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class SubscriptionAuthTests: XCTestCase {
  private var cancellables = Set<AnyCancellable>()

  func testSubscriptionReceivesAuthUserChangedErrorAndCanResubscribe() async throws {
    let mockGrpcClient = MockAuthGrpcClient()
    let queryRequest = QueryRequest<TestVariables>(
      operationName: "testQuery",
      variables: TestVariables()
    )

    let queryRef = GenericQueryRef<TestResultData, TestVariables>(
      request: queryRequest,
      grpcClient: mockGrpcClient
    )

    let firstErrorExpectation = XCTestExpectation(description: "First subscription receives AuthUserChanged")

    let publisher1 = try await queryRef.subscribe()
    publisher1
      .receive(on: DispatchQueue.main)
      .sink { result in
        switch result {
        case .success:
          break
        case let .failure(typeErasedError):
          let dcError = typeErasedError.dataConnectError
          if let authError = dcError as? DataConnectAuthError {
            switch authError.code {
            case .userChanged:
              XCTAssertEqual(authError.code, .userChanged)
              XCTAssertTrue(authError.message?.contains("uid-1") == true)
              firstErrorExpectation.fulfill()
            default:
              XCTFail("Unexpected code: \(authError.code)")
            }
          } else {
            XCTFail("Expected DataConnectAuthError but got: \(dcError)")
          }
        }
      }
      .store(in: &cancellables)

    // Wait for the stream to be created in the background Task
    try await Task.sleep(nanoseconds: 100_000_000)

    // Simulate auth user change by terminating the stream with DataConnectAuthError
    let authError = DataConnectAuthError.userChanged(
      message: "Firebase user changed from uid=uid-1 to uid=uid-2"
    )
    await mockGrpcClient.finishLatestStream(throwing: authError)

    await fulfillment(of: [firstErrorExpectation], timeout: 2.0)

    // Now verify that we can re-subscribe on the same queryRef
    let publisher2 = try await queryRef.subscribe()
    XCTAssertNotNil(publisher2)

    // Wait for the second stream to be created
    try await Task.sleep(nanoseconds: 100_000_000)
    let hasActive = await mockGrpcClient.hasActiveSubscriptions()
    XCTAssertTrue(hasActive, "A new stream should have been created upon re-subscribing")
  }
}
