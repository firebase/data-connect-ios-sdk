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
