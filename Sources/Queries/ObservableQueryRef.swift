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
public protocol ObservableQueryRef: QueryRef {
  // results of fetch.
  var data: ResultData? { get }

  // source of the query results (server, cache, )
  var source: DataSource? { get }

  // last error received. if last fetch was successful this is cleared
  var lastError: DataConnectError? { get }
}

/// QueryRef class compatible with ObservableObject protocol
///
/// When the  requested publisher is an ObservableObject, the returned query refs will be instances
/// of this class
///
/// This class cannot be instantiated directly. To get an instance, call the
/// ``DataConnect/dataConnect(...)`` function
///
/// This class publishes two vars
/// - ``data``: Published variable that contains bindable results of the query.
/// - ``lastError``: Published variable that contains ``DataConnectError``  if last fetch had error.
///            If last fetch was successful, this variable is cleared
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class QueryRefObservableObject<
  ResultData: Decodable & Sendable,
  Variable: OperationVariable
>: ObservableObject, ObservableQueryRef {
  var operationId: String {
    return baseRef.operationId
  }

  private var request: QueryRequest<Variable>

  private var baseRef: GenericQueryRef<ResultData, Variable>

  private var resultsCancellable: AnyCancellable?

  init(request: QueryRequest<Variable>,
       dataType: ResultData.Type,
       grpcClient: GrpcClient,
       cache: Cache?) {
    self.request = request
    baseRef = GenericQueryRef(
      request: request,
      grpcClient: grpcClient,
      cache: cache
    )
    setupSubscription()
  }

  private func setupSubscription() {
    Task {
      resultsCancellable = await baseRef.subscribe()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { result in
          switch result {
          case let .success(operationResult):
            self.data = operationResult.data
            self.source = operationResult.source
            self.lastError = nil
          case let .failure(dcerror):
            self.lastError = dcerror.dataConnectError
          }
        })
    }
  }

  // ObservableQueryRef implementation

  /// data published by query of type `ResultData`
  @Published public private(set) var data: ResultData?

  /// Error thrown if error occurs during execution of query. If the last fetch was successful the
  /// error is cleared
  @Published public private(set) var lastError: DataConnectError?

  /// Source of the query results (server, local cache, ...)
  @Published public private(set) var source: DataSource?

  // QueryRef implementation

  /// Executes the query and returns `ResultData`. This will also update the published `data`
  /// variable
  public func execute(fetchPolicy: QueryFetchPolicy = .preferCache) async throws
    -> OperationResult<ResultData> {
    let result = try await baseRef.execute(fetchPolicy: fetchPolicy)
    return result
  }

  /// Returns the underlying results publisher.
  /// Use this function ONLY if you plan to use the Query Ref outside of SwiftUI context - (UIKit,
  /// background updates,...)
  public func subscribe() async throws
    -> AnyPublisher<Result<OperationResult<ResultData>, AnyDataConnectError>, Never> {
    return await baseRef.subscribe()
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension QueryRefObservableObject {
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(baseRef)
  }

  static func == (lhs: QueryRefObservableObject, rhs: QueryRefObservableObject) -> Bool {
    lhs.baseRef == rhs.baseRef
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension QueryRefObservableObject: QueryRefInternal {
  func publishServerResultsToSubscribers() async throws {
    try await baseRef.publishServerResultsToSubscribers()
  }

  func publishCacheResultsToSubscribers(allowStale: Bool) async throws {
    try await baseRef.publishCacheResultsToSubscribers(allowStale: allowStale)
  }
}

/// QueryRef class compatible with the Observation framework introduced in iOS 17
///
/// When the  requested publisher is an ObservableMacri, the returned query refs will be instances
/// of this class
///
/// This class cannot be instantiated directly. To get an instance, call the
/// ``DataConnect/dataConnect(...)`` function
///
/// This class publishes two vars
/// - ``data``: Published variable that contains bindable results of the query.
/// - ``lastError``: Published variable that contains ``DataConnectError``  if last fetch had error.
///            If last fetch was successful, this variable is cleared
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
@Observable
public class QueryRefObservation<
  ResultData: Decodable & Sendable,
  Variable: OperationVariable
>: ObservableQueryRef {
  var operationId: String {
    return baseRef.operationId
  }

  @ObservationIgnored
  private var request: QueryRequest<Variable>

  @ObservationIgnored
  private var baseRef: GenericQueryRef<ResultData, Variable>

  @ObservationIgnored
  private var resultsCancellable: AnyCancellable?

  init(request: QueryRequest<Variable>, dataType: ResultData.Type, grpcClient: GrpcClient,
       cache: Cache?) {
    self.request = request
    baseRef = GenericQueryRef(
      request: request,
      grpcClient: grpcClient,
      cache: cache
    )
    setupSubscription()
  }

  private func setupSubscription() {
    Task {
      resultsCancellable = await baseRef.subscribe()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { result in
          switch result {
          case let .success(resultData):
            self.data = resultData.data
            self.source = resultData.source
            self.lastError = nil
          case let .failure(dcerror):
            self.lastError = dcerror.dataConnectError
          }
        })
    }
  }

  // ObservableQueryRef implementation

  /// data published by query of type `ResultData`
  public private(set) var data: ResultData?

  /// Error thrown if error occurs during execution of query. If the last fetch was successful the
  /// error is cleared
  public private(set) var lastError: DataConnectError?

  /// Source of the query results (server, local cache, ...)
  public private(set) var source: DataSource?

  // QueryRef implementation

  /// Executes the query and returns `ResultData`. This will also update the published `data`
  /// variable
  public func execute(fetchPolicy: QueryFetchPolicy = .preferCache) async throws
    -> OperationResult<ResultData> {
    let result = try await baseRef.execute(fetchPolicy: fetchPolicy)
    return result
  }

  /// Returns the underlying results publisher.
  /// Use this function ONLY if you plan to use the Query Ref outside of SwiftUI context - (UIKit,
  /// background updates,...)
  public func subscribe() async throws
    -> AnyPublisher<Result<OperationResult<ResultData>, AnyDataConnectError>, Never> {
    return await baseRef.subscribe()
  }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
public extension QueryRefObservation {
  nonisolated func hash(into hasher: inout Hasher) {
    hasher.combine(baseRef)
  }

  static func == (lhs: QueryRefObservation, rhs: QueryRefObservation) -> Bool {
    lhs.baseRef == rhs.baseRef
  }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
extension QueryRefObservation: CustomStringConvertible {
  public nonisolated var description: String {
    "QueryRefObservation(\(String(describing: baseRef)))"
  }
}

@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
extension QueryRefObservation: QueryRefInternal {
  func publishServerResultsToSubscribers() async throws {
    try await baseRef.publishServerResultsToSubscribers()
  }

  func publishCacheResultsToSubscribers(allowStale: Bool) async throws {
    try await baseRef.publishCacheResultsToSubscribers(allowStale: allowStale)
  }
}
