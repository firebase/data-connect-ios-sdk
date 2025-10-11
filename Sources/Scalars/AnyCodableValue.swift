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

import FirebaseCore

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum AnyCodableValue: Codable, Equatable, CustomStringConvertible {
  case string(String)
  case int64(Int64)
  case number(Double)
  case bool(Bool)
  case uuid(UUID)
  case timestamp(Timestamp)
  case dictionary([String: AnyCodableValue])
  case array([AnyCodableValue])
  case null

  static func == (lhs: AnyCodableValue, rhs: AnyCodableValue) -> Bool {
    switch (lhs, rhs) {
    case let (.string(l), .string(r)): return l == r
    case let (.int64(l), .int64(r)): return l == r
    case let (.number(l), .number(r)): return l == r
    case let (.bool(l), .bool(r)): return l == r
    case let (.uuid(l), .uuid(r)): return l == r
    case let (.timestamp(l), .timestamp(r)): return l == r
    case let (.dictionary(l), .dictionary(r)): return l == r
    case let (.array(l), .array(r)): return l == r
    case (.null, .null): return true
    default: return false
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let tsVal = try? container.decode(Timestamp.self) {
      self = .timestamp(tsVal)
    } else if let stringVal = try? container.decode(String.self) {
      if let int64Val = try? Int64CodableConverter().decode(input: stringVal) {
        self = .int64(int64Val)
      } else if let uuidVal = try? UUIDCodableConverter().decode(input: stringVal) {
        self = .uuid(uuidVal)
      } else {
        self = .string(stringVal)
      }
    } else if let doubleVal = try? container.decode(Double.self) {
      self = .number(doubleVal)
    } else if let boolVal = try? container.decode(Bool.self) {
      self = .bool(boolVal)
    } else if let dictVal = try? container.decode([String: AnyCodableValue].self) {
      self = .dictionary(dictVal)
    } else if let arrayVal = try? container.decode([AnyCodableValue].self) {
      self = .array(arrayVal)
    } else if container.decodeNil() {
      self = .null
    } else {
      throw DataConnectCodecError
        .decodingFailed(message: "Error decode AnyCodableValue from \(container)")
    }
  }

  func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .int64(value):
      let encodedVal = try? Int64CodableConverter().encode(input: value)
      try container.encode(encodedVal)
    case let .string(value):
      try container.encode(value)
    case let .number(value):
      try container.encode(value)
    case let .bool(value):
      try container.encode(value)
    case let .uuid(value):
      try container.encode(UUIDCodableConverter().encode(input: value))
    case let .timestamp(value):
      try container.encode(value)
    case let .dictionary(value):
      try container.encode(value)
    case let .array(value):
      try container.encode(value)
    case .null:
      try container.encodeNil()
    }
  }

  var isScalar: Bool {
    switch self {
    case .array, .dictionary:
      return false // treating array itself as non-scalar till its contained types are inspected
    default:
      return true
      // .null is an odd one.
      // Since we don't know its type at base SDK
      // it will be stored inline so treating as scalar
    }
  }

  var description: String {
    switch self {
    case let .int64(value):
      return value.description
    case let .string(value):
      return value
    case let .number(value):
      return value.description
    case let .bool(value):
      return value.description
    case let .uuid(value):
      return value.uuidString
    case let .timestamp(value):
      return value.description
    case let .dictionary(value):
      return value.description
    case let .array(value):
      return value.description
    case .null:
      return "null"
    }
  }
}
