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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct OperationResult<ResultData: Decodable & Sendable>: Sendable {
  public var data: ResultData?
  public let source: QueryResultSource
}

// notional protocol that denotes a variable.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol OperationVariable: Encodable, Hashable, Equatable, Sendable {}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
protocol OperationRequest: Hashable, Equatable, Sendable {
  associatedtype Variable: OperationVariable
  var operationName: String { get } // Name within Connector definition
  var variables: Variable? { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol OperationRef: Hashable, Equatable {
  associatedtype ResultData: Decodable & Sendable

  func execute() async throws -> OperationResult<ResultData>
}
