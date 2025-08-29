
import Foundation
import CryptoKit

import Firebase

@preconcurrency import Combine
import Observation

/// The type of publisher to use for the Query Ref
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum ResultsPublisherType {
  /// automatically determine ObservableQueryRef.
  /// Tries to pick the iOS 17+ Observation but falls back to ObservableObject
  case auto

  /// pre-iOS 17 ObservableObject
  case observableObject

  /// iOS 17+ Observation framework
  case observableMacro
}


@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol QueryRef: OperationRef {
  // This call starts query execution and publishes data
  func subscribe() async throws -> AnyPublisher<Result<OperationResult<ResultData>, AnyDataConnectError>, Never>
  
  // Execute override for queries to include fetch policy
  func execute(fetchPolicy: QueryFetchPolicy) async throws -> OperationResult<ResultData>
}

extension QueryRef {
  public func execute() async throws -> OperationResult<ResultData> {
    try await execute(fetchPolicy: .defaultPolicy)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor GenericQueryRef<ResultData: Decodable & Sendable, Variable: OperationVariable>: QueryRef {
  
  private let resultsPublisher = PassthroughSubject<Result<OperationResult<ResultData>, AnyDataConnectError>,
    Never>()

  private var request: QueryRequest<Variable>

  private let grpcClient: GrpcClient
  
  private let cacheProvider: CacheProvider?
  
  private var ttl: TimeInterval? = 10.0 // 

  init(request: QueryRequest<Variable>, grpcClient: GrpcClient, cacheProvider: CacheProvider? = nil) {
    self.request = request
    self.grpcClient = grpcClient
    self.cacheProvider = cacheProvider
  }

  // This call starts query execution and publishes data to data var
  // In v0, it simply reloads query results
  public func subscribe() -> AnyPublisher<Result<OperationResult<ResultData>, AnyDataConnectError>, Never> {
    Task {
      do {
        _ = try await fetchCachedResults(allowStale: true)
        try await Task.sleep(nanoseconds: 3000_000_000) //3secs
        _ = try await fetchServerResults()
      } catch {}
    }
    return resultsPublisher.eraseToAnyPublisher()
  }

  // one-shot execution. It will fetch latest data, update any caches
  // and updates the published data var
  public func execute(fetchPolicy: QueryFetchPolicy = .defaultPolicy) async throws -> OperationResult<ResultData> {
    
    switch fetchPolicy {
    case .defaultPolicy:
      let cachedResult = try await fetchCachedResults(allowStale: false)
      if cachedResult.data != nil {
        return cachedResult
      } else {
        do {
          let serverResults = try await fetchServerResults()
          return serverResults
        } catch let dcerr as DataConnectOperationError {
          // TODO: Catch network specific error looking for deadline exceeded
          /*
           if dcErr is deadlineExceeded {
            try await fetchCachedResults(allowStale: true)
           } else rethrow
           */
          throw dcerr
        }
      }
    case .cache:
      let cachedResult = try await fetchCachedResults(allowStale: true)
      return cachedResult
    case .server:
      let serverResults = try await fetchServerResults()
      return serverResults
    }
  }

  private func fetchServerResults() async throws -> OperationResult<ResultData> {
    let results = try await grpcClient.executeQuery(
      request: request,
      resultType: ResultData.self
    )
    
    do {
      if let cacheProvider {
        // TODO: Normalize data before saving to cache
        let processor = ResultTreeProcessor()
        let (dehydratedTree, sdo) = try processor.dehydrateResults(
          results.results,
          cacheProvider: cacheProvider
        )
        
        // TODO: Use server timestamp when available
        cacheProvider
          .setResultTree(
            queryId: self.request.requestId,
            tree: .init(
              serverTimestamp: results.timestamp,
              cachedAt: Date(),
              ttl: results.ttl,
              data: dehydratedTree,
              rootObject: sdo
            )
          )
      }
    }
    
    print("ResultData type \(ResultData.self)")
    print("Returned JSON \(results.results)")
    let decoder = JSONDecoder()
    let decodedData = try decoder.decode(ResultData.self, from: results.results.data(using: .utf8)!)
    
    let result = OperationResult(data: decodedData, source: .server)
    // send to subscribers
    await updateData(data: result)
    
    return result
  }
  
  private func fetchCachedResults(allowStale: Bool) async throws -> OperationResult<ResultData> {
    guard let cacheProvider,
          let ttl,
          ttl > 0 else {
      DataConnectLogger.info("No cache provider configured or ttl is not set \(ttl)")
      return OperationResult(data: nil, source: .cache(stale: false))
    }
    
    if let cacheEntry = cacheProvider.resultTree(queryId: self.request.requestId),
       (cacheEntry.isStale(ttl) && allowStale) || !cacheEntry.isStale(ttl)
    {
      let stale = cacheEntry.isStale(ttl)
      
      let resultTreeProcessor = ResultTreeProcessor()
      let (hydratedTree, _) = try resultTreeProcessor.hydrateResults(
        cacheEntry.data,
        cacheProvider: cacheProvider
      )
      
      let decoder = JSONDecoder()
      let decodedData = try decoder.decode(ResultData.self, from: hydratedTree.data(using: .utf8)!)
      
      let result = OperationResult(data: decodedData, source: .cache(stale: stale))
      // send to subscribers
      await updateData(data: result)
      
      return result
    }
    
    return OperationResult(data: nil, source: .cache(stale: false))
  }

  func updateData(data: OperationResult<ResultData>) async {
    resultsPublisher.send(.success(data))
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol ObservableQueryRef: QueryRef {
  // results of fetch.
  var data: ResultData? { get }
  
  // source of the query results (server, cache, )
  var source: QueryResultSource { get }

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
  private var request: QueryRequest<Variable>

  private var baseRef: GenericQueryRef<ResultData, Variable>

  private var resultsCancellable: AnyCancellable?

  init(
    request: QueryRequest<Variable>,
    dataType: ResultData.Type,
    grpcClient: GrpcClient,
    cacheProvider: CacheProvider?
  ) {
    self.request = request
    baseRef = GenericQueryRef(
      request: request,
      grpcClient: grpcClient,
      cacheProvider: cacheProvider
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
  @Published public private(set) var source: QueryResultSource = .unknown

  // QueryRef implementation

  /// Executes the query and returns `ResultData`. This will also update the published `data`
  /// variable
  public func execute(fetchPolicy: QueryFetchPolicy = .defaultPolicy) async throws -> OperationResult<ResultData> {
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
  @ObservationIgnored
  private var request: QueryRequest<Variable>

  @ObservationIgnored
  private var baseRef: GenericQueryRef<ResultData, Variable>

  @ObservationIgnored
  private var resultsCancellable: AnyCancellable?

  init(request: QueryRequest<Variable>, dataType: ResultData.Type, grpcClient: GrpcClient, cacheProvider: CacheProvider?) {
    self.request = request
    baseRef = GenericQueryRef(
      request: request,
      grpcClient: grpcClient,
      cacheProvider: cacheProvider
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
  public private(set) var source: QueryResultSource = .unknown

  // QueryRef implementation

  /// Executes the query and returns `ResultData`. This will also update the published `data`
  /// variable
  public func execute(fetchPolicy: QueryFetchPolicy = .defaultPolicy) async throws -> OperationResult<ResultData> {
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
