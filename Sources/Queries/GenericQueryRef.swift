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

import Foundation

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

  // maxAge received from server in query response
  private var serverMaxAge: TimeInterval? = nil

  // maxAge computed based on server or cache settings
  // server is given priority over cache settings
  private var maxAge: TimeInterval {
    if let serverMaxAge {
      DataConnectLogger.debug("Using maxAge specified from server \(serverMaxAge)")
      return serverMaxAge
    }

    if let ma = cache?.config.maxAge {
      DataConnectLogger.debug("Using maxAge specified from cache settings \(ma)")
      return ma
    }

    return 0
  }

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
        resultsPublisher
          .send(.failure(AnyDataConnectError(dataConnectError: DataConnectInternalError
              .internalError(
                message: "Failed to subscribe to query",
                cause: error
              ))))
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
        serverMaxAge = response.extensions?.maxAge
        await cache.update(queryId: operationId, response: response, requestor: self)
      }
    }

    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(
      ResultData.self,
      from: response.data
    )

    let result = OperationResult(data: decodedData, source: .server)
    // send to subscribers
    await updateData(data: result)

    return result
  }

  private func fetchCachedResults(allowStale: Bool) async throws -> OperationResult<ResultData> {
    guard let cache
    else {
      DataConnectLogger.info("No cache provider configured")
      return OperationResult(data: nil, source: .cache)
    }

    if let cacheEntry = await cache.resultTree(queryId: request.requestId),
       (cacheEntry.isStale(maxAge) && allowStale) || !cacheEntry.isStale(maxAge) {
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(
        ResultData.self,
        from: cacheEntry.data
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
