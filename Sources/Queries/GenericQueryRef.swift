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

import CryptoKit
import Foundation

import Firebase

@preconcurrency import Combine
import Observation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor GenericQueryRef<ResultData: Decodable & Sendable, Variable: OperationVariable>: QueryRef {
  private let resultsPublisher = PassthroughSubject<
    Result<OperationResult<ResultData>, AnyDataConnectError>,
    Never
  >()

  private var request: QueryRequest<Variable>

  private let grpcClient: GrpcClient

  private let cache: Cache?

  private var ttl: TimeInterval? = 10.0 //

  // Ideally we would like this to be part of the QueryRef protocol
  // Not adding for now since the protocol is Public
  // This property is for now an internal property.
  let operationId: String

  init(request: QueryRequest<Variable>, grpcClient: GrpcClient, cache: Cache? = nil) {
    self.request = request
    self.grpcClient = grpcClient
    self.cache = cache
    operationId = self.request.requestId
  }

  // This call starts query execution and publishes data to data var
  // In v0, it simply reloads query results
  public func subscribe()
    -> AnyPublisher<Result<OperationResult<ResultData>, AnyDataConnectError>, Never> {
    Task {
      do {
        _ = try await fetchCachedResults(allowStale: true)
        _ = try await fetchServerResults()
      } catch {
        resultsPublisher.send(.failure(AnyDataConnectError(dataConnectError: DataConnectInternalError.internalError(message: "Failed to subscribe to query", cause: error))))
      }
    }
    return resultsPublisher.eraseToAnyPublisher()
  }

  // one-shot execution. It will fetch latest data, update any caches
  // and updates the published data var
  public func execute(fetchPolicy: QueryFetchPolicy = .preferCache) async throws
    -> OperationResult<ResultData> {
    switch fetchPolicy {
    case .preferCache:
      let cachedResult = try await fetchCachedResults(allowStale: false)
      if cachedResult.data != nil {
        return cachedResult
      } else {
        let serverResults = try await fetchServerResults()
        return serverResults
      }
    case .cacheOnly:
      let cachedResult = try await fetchCachedResults(allowStale: true)
      return cachedResult
    case .serverOnly:
      let serverResults = try await fetchServerResults()
      return serverResults
    }
  }

  private func fetchServerResults() async throws -> OperationResult<ResultData> {
    let response = try await grpcClient.executeQuery(
      request: request,
      resultType: ResultData.self
    )

    do {
      if let cache {
        cache.update(queryId: operationId, response: response, requestor: self)
      }
    }

    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(
      ResultData.self,
      from: response.jsonResults.data(using: .utf8)!
    )

    let result = OperationResult(data: decodedData, source: .server)
    // send to subscribers
    await updateData(data: result)

    return result
  }

  private func fetchCachedResults(allowStale: Bool) async throws -> OperationResult<ResultData> {
    guard let cache,
          let ttl,
          ttl > 0 else {
      DataConnectLogger.info("No cache provider configured or ttl is not set \(ttl)")
      return OperationResult(data: nil, source: .cache)
    }

    if let cacheEntry = cache.resultTree(queryId: request.requestId),
       (cacheEntry.isStale(ttl) && allowStale) || !cacheEntry.isStale(ttl) {
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(
        ResultData.self,
        from: cacheEntry.data.data(using: .utf8)!
      )

      let result = OperationResult(data: decodedData, source: .cache)
      // send to subscribers
      await updateData(data: result)

      return result
    }

    return OperationResult(data: nil, source: .cache)
  }

  func updateData(data: OperationResult<ResultData>) async {
    resultsPublisher.send(.success(data))
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension GenericQueryRef {
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(operationId)
  }

  static func == (lhs: GenericQueryRef, rhs: GenericQueryRef) -> Bool {
    lhs.operationId == rhs.operationId
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension GenericQueryRef: CustomStringConvertible {
  nonisolated var description: String {
    "GenericQueryRef(\(operationId))"
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension GenericQueryRef: QueryRefInternal {
  func publishServerResultsToSubscribers() async throws {
    _ = try await fetchServerResults()
  }

  func publishCacheResultsToSubscribers(allowStale: Bool) async throws {
    _ = try await fetchCachedResults(allowStale: allowStale)
  }
}
