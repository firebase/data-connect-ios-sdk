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
/*
 
 Init with JSON (root)
 Convert to CodableValue and Init itself
 Codable Value must be a dict at root level
 
 Dict can contain
 (if BDO)
 - Scalars, [Scalar] => Move this to DBO
 - References, [References] => Keep with
 (if no guid and therefore no BDO)
 - Store CodableValue as - is
 
 
 */

// Kind of result data we are encoding from or decoding to
enum ResultTreeKind {
  case hydrated // JSON data is full hydrated and contains full data in the tree
  case dehydrated // JSON data is dehydrated and only contains refs to actual data objects
}

let ResultTreeKindCodingKey = CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.encodingMode")!

struct StubDataObject {
  
  // externalized (normalized) data.
  // Requires an entity globalID to be provided in selection set
  var backingData: BackingDataObject?
  
  // inline scalars are only populated if there is no BackingDataObject
  // i.e. if there is no entity globalID
  var scalars = [String: AnyCodableValue]()
  
  // entity properties that point to other stub objects
  var references = [String: StubDataObject]()
  
  // properties that point to a list of other objects
  // scalar lists are stored inline.
  var objectLists = [String: [StubDataObject]]()
  
  enum CodingKeys: String, CodingKey {
    case globalID = "cacheId"
    case objectLists
    case references
    case scalars
  }
  
  struct DynamicKey: CodingKey {
    var intValue: Int?
    let stringValue: String
    init?(intValue: Int) { return nil }
    init?(stringValue: String) { self.stringValue = stringValue }
  }
   
  init?(value: AnyCodableValue, cacheProvider: CacheProvider) {
    guard case let .dictionary(objectValues) = value else {
      DataConnectLogger.error("StubDataObject inited with a non-dictionary type")
      return nil
    }
    
    if case let .string(guid) = objectValues[GlobalIDKey] {
      backingData = cacheProvider.dataObject(entityGuid: guid)
    } else if case let .uuid(guid) = objectValues[GlobalIDKey] {
      // underlying deserializer is detecting a uuid and converting it.
      // TODO: Remove once server starts to send the real GlobalID
      backingData = cacheProvider.dataObject(entityGuid: guid.uuidString)
    }
    
    for (key, value) in objectValues {
      switch value {
      case .dictionary(_):
        // a dictionary is treated as a composite object
        // and converted to another Stub
        if let st = StubDataObject(value: value, cacheProvider: cacheProvider) {
          references[key] = st
        } else {
          DataConnectLogger.warning("Failed to convert dictionary to a reference")
        }
      case .array(let objs):
        var refArray = [StubDataObject]()
        var scalarArray = [AnyCodableValue]()
        for obj in objs {
          if let st = StubDataObject(value: obj, cacheProvider: cacheProvider) {
            refArray.append(st)
          } else {
            if obj.isScalar {
              scalarArray.append(obj)
            }
            // Not handling the case of Array of Arrays (matrices)
          }
        }
        if refArray.count > 0 {
          objectLists[key] = refArray
        } else if scalarArray.count > 0 {
          if let backingData { backingData.updateServerValue(key, value)}
        }
      default:
        if let backingData {
          backingData.updateServerValue(key, value)
        } else {
          scalars[key] = value
        }
        
      }
    }
  }
}

extension StubDataObject: Decodable {
  
  init (from decoder: Decoder) throws {
    
    guard let cacheProvider = decoder.userInfo[CacheProviderUserInfoKey] as? CacheProvider else {
      throw DataConnectCodecError.decodingFailed(message: "Missing CacheProvider in decoder")
    }
    
    guard let resultTreeKind = decoder.userInfo[ResultTreeKindCodingKey] as? ResultTreeKind else {
      throw DataConnectCodecError.decodingFailed(message: "Missing ResultTreeKind in decoder")
    }
    
    if resultTreeKind == .hydrated {
      // our input is a hydrated result tree
      let container = try decoder.singleValueContainer()
      
      let value = try container.decode(AnyCodableValue.self)
      
      let sdo = StubDataObject(value: value, cacheProvider: cacheProvider)
      //DataConnectLogger.debug("Create SDO from JSON \(sdo?.debugDescription)")
      
      if let sdo {
        self = sdo
      } else {
        throw DataConnectCodecError.decodingFailed(message: "Failed to decode into a valid StubDataObject")
      }
      
    } else {
      // our input is a dehydrated result tree
      let container = try decoder.container(keyedBy: CodingKeys.self)
      
      if let globalID = try container.decodeIfPresent(String.self, forKey: .globalID) {
        self.backingData = cacheProvider.dataObject(entityGuid: globalID)
      }
      
      if let refs = try container.decodeIfPresent([String: StubDataObject].self, forKey: .references) {
        self.references = refs
      }
      
      if let lists = try container.decodeIfPresent([String: [StubDataObject]].self, forKey: .objectLists) {
        self.objectLists = lists
      }
      
      if let scalars = try container.decodeIfPresent([String: AnyCodableValue].self, forKey: .scalars) {
        self.scalars = scalars
      }
      
    }
  }
}

extension StubDataObject: Encodable {
  func encode(to encoder: Encoder) throws {
    guard let resultTreeKind = encoder.userInfo[ResultTreeKindCodingKey] as? ResultTreeKind else {
      throw DataConnectCodecError.decodingFailed(message: "Missing ResultTreeKind in decoder")
    }
    
    if resultTreeKind == .hydrated {
      //var container = encoder.singleValueContainer()
      var container = encoder.container(keyedBy: DynamicKey.self)
      
      if let backingData {
        let encodableData = try backingData.encodableData()
        for (key, value) in encodableData {
          try container.encode(value, forKey: DynamicKey(stringValue: key)!)
        }
      }
      
      if references.count > 0 {
        for (key, value) in references {
          try container.encode(value, forKey: DynamicKey(stringValue: key)!)
        }
      }
      
      if objectLists.count > 0 {
        for (key, value) in objectLists {
          try container.encode(value, forKey: DynamicKey(stringValue: key)!)
        }
      }
      
      if scalars.count > 0 {
        for (key, value) in scalars {
          try container.encode(value, forKey: DynamicKey(stringValue: key)!)
        }
      }
    } else {
      // dehydrated tree required
      var container = encoder.container(keyedBy: CodingKeys.self)
      if let backingData {
        try container.encode(backingData.guid, forKey: .globalID)
      }
      
      if references.count > 0 {
        try container.encode(references, forKey: .references)
      }
      
      if objectLists.count > 0 {
        try container.encode(objectLists, forKey: .objectLists)
      }
      
      if scalars.count > 0 {
        try container.encode(scalars, forKey: .scalars)
      }
    }
  }
}

extension StubDataObject: Equatable {
  public static func == (lhs: StubDataObject, rhs: StubDataObject) -> Bool {
    return lhs.backingData == rhs.backingData &&
    lhs.references == rhs.references &&
    lhs.objectLists == rhs.objectLists &&
    lhs.scalars == rhs.scalars
  }
}

extension StubDataObject: CustomDebugStringConvertible {
  var debugDescription: String {
    return """
      StubDataObject:
          \(String(describing: self.backingData))
        References:
          \(self.references)
        Lists:
          \(self.objectLists)
        Scalars:
          \(self.scalars)
      """
  }
}
