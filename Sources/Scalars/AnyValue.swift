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
  public var value: Data {
    do {
      let jsonEncoder = JSONEncoder()
      let data = try jsonEncoder.encode(anyCodableValue)
      return data
    } catch {
      DataConnectLogger.logger.warning("Error encoding anyCodableValue \(error)")
      return Data()
    }
  }

  private var anyCodableValue: AnyCodableValue

  public init(codableValue: Codable) throws {
    do {
      if let int64Val = codableValue as? Int64 {
        anyCodableValue = .int64(int64Val)
      } else {
        // to recontruct JSON dictionary, one has to decode it from json data
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(codableValue)
        let jsonDecoder = JSONDecoder()
        anyCodableValue = try jsonDecoder.decode(AnyCodableValue.self, from: jsonData)
      }
    }
  }

  public func decodeValue<T: Decodable>(_ type: T.Type) throws -> T? {
    do {
      switch anyCodableValue {
      case let .int64(int64):
        if type == Int64.self {
          return int64 as? T
        } else {
          throw DataConnectCodecError.decodingFailed()
        }
      default:
        let jsonDecoder = JSONDecoder()
        let decodedResult = try jsonDecoder.decode(type, from: value)
        return decodedResult
      }
    }
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension AnyValue: Codable {
  public init(from decoder: any Swift.Decoder) throws {
    var container = try decoder.singleValueContainer()
    do {
      if let b64Data = try? container.decode(Data.self) {
        // backwards compatibility
        let jsonDecoder = JSONDecoder()
        anyCodableValue = try jsonDecoder.decode(AnyCodableValue.self, from: b64Data)
      } else {
        let codecHelper = SingleValueCodecHelper()
        anyCodableValue = try codecHelper.decodeSingle(AnyCodableValue.self, container: &container)
      }
    }
  }

  public func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    let codecHelper = SingleValueCodecHelper()
    try codecHelper.encodeSingle(anyCodableValue, container: &container)
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

// MARK: -

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum AnyCodableValue: Codable, Equatable {
  case string(String)
  case int64(Int64)
  case number(Double)
  case bool(Bool)
  case dictionary([String: AnyCodableValue])
  case array([AnyCodableValue])
  case null

  static func == (lhs: AnyCodableValue, rhs: AnyCodableValue) -> Bool {
    switch (lhs, rhs) {
    case let (.string(l), .string(r)): return l == r
    case let (.int64(l), .int64(r)): return l == r
    case let (.number(l), .number(r)): return l == r
    case let (.bool(l), .bool(r)): return l == r
    case let (.dictionary(l), .dictionary(r)): return l == r
    case let (.array(l), .array(r)): return l == r
    case (.null, .null): return true
    default: return false
    }
  }

  init(from decoder: Decoder) throws {
    let container = try decoder.singleValueContainer()

    if let stringVal = try? container.decode(String.self) {
      if let int64Val = try? Int64CodableConverter().decode(input: stringVal) {
        self = .int64(int64Val)
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
    case let .dictionary(value):
      try container.encode(value)
    case let .array(value):
      try container.encode(value)
    case .null:
      try container.encodeNil()
    }
  }
}
