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

import FirebaseDataConnect

public struct AnyValueTypeKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension AnyValueTypeKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension AnyValueTypeKey: Equatable {
  public static func == (lhs: AnyValueTypeKey, rhs: AnyValueTypeKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension AnyValueTypeKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct LargeIntTypeKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension LargeIntTypeKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension LargeIntTypeKey: Equatable {
  public static func == (lhs: LargeIntTypeKey, rhs: LargeIntTypeKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension LargeIntTypeKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct LocalDateTypeKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension LocalDateTypeKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension LocalDateTypeKey: Equatable {
  public static func == (lhs: LocalDateTypeKey, rhs: LocalDateTypeKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension LocalDateTypeKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct ScalarBoundaryKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension ScalarBoundaryKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension ScalarBoundaryKey: Equatable {
  public static func == (lhs: ScalarBoundaryKey, rhs: ScalarBoundaryKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension ScalarBoundaryKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct StandardScalarsKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension StandardScalarsKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension StandardScalarsKey: Equatable {
  public static func == (lhs: StandardScalarsKey, rhs: StandardScalarsKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension StandardScalarsKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct TestAutoIdKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension TestAutoIdKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension TestAutoIdKey: Equatable {
  public static func == (lhs: TestAutoIdKey, rhs: TestAutoIdKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension TestAutoIdKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

public struct TestIdKey {
  public private(set) var id: UUID

  enum CodingKeys: String, CodingKey {
    case id
  }
}

extension TestIdKey: Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    try codecHelper.encode(id, forKey: .id, container: &container)
  }
}

extension TestIdKey: Equatable {
  public static func == (lhs: TestIdKey, rhs: TestIdKey) -> Bool {
    if lhs.id != rhs.id {
      return false
    }

    return true
  }
}

extension TestIdKey: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}
