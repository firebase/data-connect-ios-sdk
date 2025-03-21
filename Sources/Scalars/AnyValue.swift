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

/// AnyValue represents the Any graphql scalar, which represents Codable data -  scalar data (Int,
/// Double, String, Bool,...) or a JSON object
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnyValue {
  public private(set) var value: Data

  public init(codableValue: Codable) throws {
    do {
      let jsonEncoder = JSONEncoder()
      value = try jsonEncoder.encode(codableValue)
    }
  }

  public func decodeValue<T: Decodable>(_ type: T.Type) throws -> T? {
    do {
      let jsonDecoder = JSONDecoder()
      let decodedResult = try jsonDecoder.decode(type, from: value)
      return decodedResult
    }
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnyValue: Codable {
  public init(from decoder: any Decoder) throws {
    let singleValueContainer = try decoder.singleValueContainer()
    value = try singleValueContainer.decode(Data.self)
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(value)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnyValue: Equatable {
  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.value == rhs.value
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnyValue: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(value)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnyValue: Sendable {}
