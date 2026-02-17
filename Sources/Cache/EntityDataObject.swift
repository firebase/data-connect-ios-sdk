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

// Represents a normalized entity shared amongst queries.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
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
    case guid
    case serverValues = "sval"
    case referencedFrom = "refs"
  }

  // Updates the value received from server and returns a list of QueryRef operation ids
  // referenced from this EntityDataObject
  @discardableResult func updateServerValue(_ key: String,
                                            _ newValue: AnyCodableValue,
                                            _ requestorId: String? = nil)
    -> [String] {
    accessQueue.sync {
      self.serverValues[key] = newValue
      DataConnectLogger.debug("EDO updateServerValue: \(key) \(newValue) for \(guid)")

      if let requestorId {
        referencedFrom.insert(requestorId)
        DataConnectLogger
          .debug("Inserted referencedFrom \(requestorId). New count \(referencedFrom.count)")
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

  // inline encodable data
  // used when trying to create a hydrated tree
  func encodableData() throws -> [String: AnyCodableValue] {
    accessQueue.sync {
      var encodingValues = [String: AnyCodableValue]()
      encodingValues.merge(serverValues) { _, new in new }
      return encodingValues
    }
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
