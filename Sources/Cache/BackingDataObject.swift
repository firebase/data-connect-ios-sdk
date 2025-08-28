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

class BackingDataObject:  CustomStringConvertible {
  
  let guid: String // globally unique id received from server
  
  init(guid: String) {
    self.guid = guid
  }
  
  private var serverValues = SynchronizedDictionary<String, AnyCodableValue>()
  
  func updateServerValue(_ key: String, _ newValue: AnyCodableValue) {
    self.serverValues[key] = newValue
    DataConnectLogger.debug("BDO updateServerValue: \(key) \(newValue) for \(guid)")
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
  
}

extension BackingDataObject: Encodable {
  
  func encodableData() throws -> [String: AnyCodableValue] {
    var encodingValues = [String: AnyCodableValue]()
    encodingValues[GlobalIDKey] = .string(guid)
    encodingValues.merge(serverValues.rawCopy()) { (_, new) in new }
    return encodingValues
  }
  
  public func encode(to encoder: Encoder) throws {
    var container = encoder.singleValueContainer()
    try container.encode(encodableData())
    // once we have localValues, we will need to merge between the two dicts and encode
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


