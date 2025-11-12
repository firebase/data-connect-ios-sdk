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
public protocol QueryRef: OperationRef, Equatable, Hashable {
  /// This call starts query execution and publishes data
  /// Subscribe always returns cache data first while it attempts to fetch from the server
  func subscribe() async throws -> AnyPublisher<Result<
    OperationResult<ResultData>,
    AnyDataConnectError
  >, Never>

  /// Execute override for queries to include fetch policy. Defaults to `preferCache` policy
  func execute(fetchPolicy: QueryFetchPolicy) async throws -> OperationResult<ResultData>
}

public extension QueryRef {
  // default implementation for execute()
  func execute() async throws -> OperationResult<ResultData> {
    try await execute(fetchPolicy: .preferCache)
  }
}
