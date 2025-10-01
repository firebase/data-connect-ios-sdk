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

struct ScalarField {
  let name: String
  let value: AnyCodableValue
}

class BackingDataObject: CustomStringConvertible, Codable {
  
  // Set of QueryRefs that reference this BDO
  var referencedFrom = Set<String>()
  
  var guid: String // globally unique id received from server
  
  required init(guid: String) {
    self.guid = guid
  }
  
  private var serverValues = SynchronizedDictionary<String, AnyCodableValue>()
  
  enum CodingKeys: String, CodingKey {
    case globalID = "guid"
    case serverValues = "serVal"
  }
  
  // Updates value received from server and returns a list of QueryRef operation ids
  // referenced from this BackingDataObject
  @discardableResult func updateServerValue(
    _ key: String,
    _ newValue: AnyCodableValue,
    _ requestor: (any QueryRefInternal)? = nil
  ) -> [String] {

    self.serverValues[key] = newValue
    DataConnectLogger.debug("BDO updateServerValue: \(key) \(newValue) for \(guid)")
    
    if let requestor {
      referencedFrom.insert(requestor.operationId)
      DataConnectLogger
        .debug("Inserted referencedFrom \(requestor). New count \(referencedFrom.count)")
      
    }
    let refs: [String] = Array<String>(referencedFrom)
    return refs
  }
  
  func value(forKey key: String) -> AnyCodableValue? {
    return self.serverValues[key]
  }
  
  var description: String {
    return """
      BackingDataObject:
        globalID: \(guid)
        serverValues:
          \(serverValues.rawCopy())
      """
  }
  
  func encodableData() throws -> [String: AnyCodableValue] {
    var encodingValues = [String: AnyCodableValue]()
    encodingValues[GlobalIDKey] = .string(guid)
    encodingValues.merge(serverValues.rawCopy()) { (_, new) in new }
    return encodingValues
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(guid, forKey: .globalID)
    try container.encode(serverValues.rawCopy(), forKey: .serverValues)
    // once we have localValues, we will need to merge between the two dicts and encode
  }
  
  required init(from decoder: Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    
    let globalId = try container.decode(String.self, forKey: .globalID)
    self.guid = globalId
    
    let rawValues = try container.decode([String: AnyCodableValue].self, forKey: .serverValues)
    serverValues.updateValues(rawValues)
  }
  
}


extension BackingDataObject: Equatable {
  static func == (lhs: BackingDataObject, rhs: BackingDataObject) -> Bool {
    return lhs.guid == rhs.guid && lhs.serverValues.rawCopy() == rhs.serverValues.rawCopy()
  }
}

extension BackingDataObject: CustomDebugStringConvertible {
  var debugDescription: String {
    return description
  }
}


