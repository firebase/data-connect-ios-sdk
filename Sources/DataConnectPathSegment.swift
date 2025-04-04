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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum DataConnectPathSegment: Codable, Equatable, Sendable {
  case field(String)
  case listIndex(Int)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension DataConnectPathSegment {
  init(from decoder: any Decoder) throws {
    let container = try decoder.singleValueContainer()

    do {
      let field = try container.decode(String.self)
      self = .field(field)
    } catch {
      let index = try container.decode(Int.self)
      self = .listIndex(index)
    }
  }

  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    switch self {
    case let .field(fieldVal):
      try container.encode(fieldVal)
    case let .listIndex(indexVal):
      try container.encode(indexVal)
    }
  }
}
