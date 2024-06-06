// Copyright 2024 Google LLC
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

import Combine
import Observation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public enum ResultsPublisherType {
  case auto // automatically determine ObservableQueryRef
  case observableObject // pre-iOS 17 ObservableObject
  case observableMacro // iOS 17+ Observation framework
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct QueryRequest<Variable: OperationVariable>: OperationRequest, Hashable, Equatable {
  public private(set) var operationName: String
  public private(set) var variables: Variable?

  public init(operationName: String, variables: Variable? = nil) {
    self.operationName = operationName
    self.variables = variables
  }

  // Hashable and Equatable implementation
  public func hash(into hasher: inout Hasher) {
    hasher.combine(operationName)
    if let variables {
      hasher.combine(variables)
    }
  }

  public static func == (lhs: QueryRequest, rhs: QueryRequest) -> Bool {
    guard lhs.operationName == rhs.operationName else {
      return false
    }

    if lhs.variables == nil && rhs.variables == nil {
      return true
    }

    guard let lhsVar = lhs.variables,
          let rhsVar = rhs.variables,
          lhsVar == rhsVar else {
      return false
    }

    return true
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol QueryRef: OperationRef {
  // This call starts query execution and publishes data
  func subscribe() async throws -> AnyPublisher<Result<ResultData, DataConnectError>, Never>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
actor GenericQueryRef<ResultData: Decodable, Variable: OperationVariable>: QueryRef {
  private var resultsPublisher = PassthroughSubject<Result<ResultData, DataConnectError>,
    Never>()

  var request: QueryRequest<Variable>

  private var grpcClient: GrpcClient

  init(request: QueryRequest<Variable>, grpcClient: GrpcClient) {
    self.request = request
    self.grpcClient = grpcClient
  }

  // This call starts query execution and publishes data to data var
  // In v0, it simply reloads query results
  public func subscribe() -> AnyPublisher<Result<ResultData, DataConnectError>, Never> {
    Task {
      do {
        _ = try await reloadResults()
      } catch {}
    }
    return resultsPublisher.eraseToAnyPublisher()
  }

  // one-shot execution. It will fetch latest data, update any caches
  // and updates the published data var
  public func execute() async throws -> OperationResult<ResultData> {
    let resultData = try await reloadResults()
    return OperationResult(data: resultData)
  }

  private func reloadResults() async throws -> ResultData {
    let results = try await grpcClient.executeQuery(
      request: request,
      resultType: ResultData.self
    )
    await updateData(data: results.data)
    return results.data
  }

  func updateData(data: ResultData) async {
    resultsPublisher.send(.success(data))
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol ObservableQueryRef: QueryRef {
  // results of fetch.
  var data: ResultData? { get }

  // last error received. if last fetch was successful this is cleared
  var lastError: DataConnectError? { get }
}

/*
 @available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
 extension ObservableQueryRef {
   public func subscribe() async throws -> AnyPublisher<Result<ResultDataType, DataConnectError>, Never> {
     //return Empty<Result<ResultDataType, DataConnectError>, Never>()
   }
 }
 */

// QueryRef class used with ObservableObject protocol
// data: Published variable that contains bindable results of the query.
// lastError: Published variable that contains DataConnectError if last fetch had error.
//            If last fetch was successful, this variable is cleared
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public class QueryRefObservableObject<
  ResultData: Decodable,
  Variable: OperationVariable
>: ObservableObject, ObservableQueryRef {
  private var request: QueryRequest<Variable>

  private var baseRef: GenericQueryRef<ResultData, Variable>

  private var resultsCancellable: AnyCancellable?

  init(request: QueryRequest<Variable>, dataType: ResultData.Type, grpcClient: GrpcClient) {
    self.request = request
    baseRef = GenericQueryRef(request: request, grpcClient: grpcClient)
    setupSubscription()
  }

  private func setupSubscription() {
    Task {
      resultsCancellable = await baseRef.subscribe()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { result in
          switch result {
          case let .success(resultData):
            self.data = resultData
            self.lastError = nil
          case let .failure(dcerror):
            self.lastError = dcerror
          }
        })
    }
  }

  // ObservableQueryRef implementation

  @Published public private(set) var data: ResultData?

  @Published public private(set) var lastError: DataConnectError?

  // QueryRef implementation

  public func execute() async throws -> OperationResult<ResultData> {
    let result = try await baseRef.execute()
    return result
  }

  public func subscribe() async throws
    -> AnyPublisher<Result<ResultData, DataConnectError>, Never> {
    return await baseRef.subscribe()
  }
}

// QueryRef class compatible with the Observation framework introduced in iOS 17
// data: Published variable that contains bindable results of the query.
// lastError: Published variable that contains DataConnectError if last fetch had error.
//            If last fetch was successful, this variable is cleared
@available(macOS 14, iOS 17, tvOS 17, watchOS 10, *)
@Observable
public class QueryRefObservation<
  ResultData: Decodable,
  Variable: OperationVariable
>: ObservableQueryRef {
  @ObservationIgnored
  private var request: QueryRequest<Variable>

  @ObservationIgnored
  private var baseRef: GenericQueryRef<ResultData, Variable>

  @ObservationIgnored
  private var resultsCancellable: AnyCancellable?

  init(request: QueryRequest<Variable>, dataType: ResultData.Type, grpcClient: GrpcClient) {
    self.request = request
    baseRef = GenericQueryRef(request: request, grpcClient: grpcClient)
    setupSubscription()
  }

  private func setupSubscription() {
    Task {
      resultsCancellable = await baseRef.subscribe()
        .receive(on: DispatchQueue.main)
        .sink(receiveValue: { result in
          switch result {
          case let .success(resultData):
            self.data = resultData
            self.lastError = nil
          case let .failure(dcerror):
            self.lastError = dcerror
          }
        })
    }
  }

  // ObservableQueryRef implementation

  public private(set) var data: ResultData?

  public private(set) var lastError: DataConnectError?

  // QueryRef implementation

  public func execute() async throws -> OperationResult<ResultData> {
    let result = try await baseRef.execute()
    return result
  }

  public func subscribe() async throws
    -> AnyPublisher<Result<ResultData, DataConnectError>, Never> {
    return await baseRef.subscribe()
  }
}
