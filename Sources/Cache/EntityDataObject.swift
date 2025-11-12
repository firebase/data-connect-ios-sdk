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

import Foundation

struct ScalarField {
  let name: String
  let value: AnyCodableValue
}

// Represents a normalized entity shared amongst queries.
class EntityDataObject: Codable {
  let guid: String // globally unique id received from server

  private let accessQueue = DispatchQueue(
    label: "com.google.firebase.dataconnect.entityData",
    autoreleaseFrequency: .workItem
  )

  required init(guid: String) {
    self.guid = guid
  }

  private var serverValues = [String: AnyCodableValue]()

  enum CodingKeys: String, CodingKey {
    case globalID = "guid"
    case serverValues = "sval"
  }

  // Updates the value received from server and returns a list of QueryRef operation ids
  // referenced from this EntityDataObject
  @discardableResult func updateServerValue(_ key: String,
                                            _ newValue: AnyCodableValue,
                                            _ requestor: (any QueryRefInternal)? = nil)
    -> [String] {
    accessQueue.sync {
      self.serverValues[key] = newValue
      DataConnectLogger.debug("EDO updateServerValue: \(key) \(newValue) for \(guid)")

      if let requestor {
        referencedFrom.insert(requestor.operationId)
        DataConnectLogger
          .debug("Inserted referencedFrom \(requestor). New count \(referencedFrom.count)")
      }
      let refs = [String](referencedFrom)
      return refs
    }
  }

  func value(forKey key: String) -> AnyCodableValue? {
    accessQueue.sync {
      self.serverValues[key]
    }
  }

  // MARK: Track referenced QueryRefs

  // Set of QueryRefs that reference this EDO
  private var referencedFrom = Set<String>()

  func updateReferencedFrom(_ refs: Set<String>) {
    accessQueue.sync {
      self.referencedFrom = refs
    }
  }

  func referencedFromRefs() -> Set<String> {
    accessQueue.sync {
      self.referencedFrom
    }
  }

  var isReferencedFromAnyQueryRef: Bool {
    accessQueue.sync {
      !referencedFrom.isEmpty
    }
  }

  // MARK: Encoding / Decoding support

  func encodableData() throws -> [String: AnyCodableValue] {
    var encodingValues = [String: AnyCodableValue]()
    encodingValues[GlobalIDKey] = .string(guid)
    encodingValues.merge(serverValues) { _, new in new }
    return encodingValues
  }

  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(guid, forKey: .globalID)
    try container.encode(serverValues, forKey: .serverValues)
  }

  required init(from decoder: Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)

    let globalId = try container.decode(String.self, forKey: .globalID)
    guid = globalId

    serverValues = try container.decode([String: AnyCodableValue].self, forKey: .serverValues)
  }
}

extension EntityDataObject: CustomStringConvertible {
  var description: String {
    return """
    EntityDataObject:
      globalID: \(guid)
      serverValues:
        \(serverValues)
    """
  }
}

extension EntityDataObject: Equatable {
  static func == (lhs: EntityDataObject, rhs: EntityDataObject) -> Bool {
    return lhs.guid == rhs.guid && lhs.serverValues == rhs.serverValues
  }
}

extension EntityDataObject: CustomDebugStringConvertible {
  var debugDescription: String {
    return description
  }
}
