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

import FirebaseCore

class EphemeralCacheProvider: CacheProvider, CustomStringConvertible {
  
  let cacheIdentifier: String
  
  init(_ cacheIdentifier: String) {
    self.cacheIdentifier = cacheIdentifier
    
    DataConnectLogger.debug("Initialized \(Self.Type.self) with identifier:\(cacheIdentifier)")
  }
  
  // MARK: ResultTree
  private var resultTreeCache = SynchronizedDictionary<String, ResultTree>()
  
  func setResultTree(
    queryId: String,
    tree: ResultTree
  ) {
    resultTreeCache[queryId] =  tree
    DataConnectLogger.debug("Update resultTreeEntry for \(queryId)")
  }

  func resultTree(queryId: String) -> ResultTree? {
    return resultTreeCache[queryId]
  }
  
  // MARK: BackingDataObjects
  private var backingDataObjects = SynchronizedDictionary<String, BackingDataObject>()
  
  func backingData(_ entityGuid: String) -> BackingDataObject {
    guard let dataObject = backingDataObjects[entityGuid] else {
      let bdo = BackingDataObject(guid: entityGuid)
      backingDataObjects[entityGuid] = bdo
      DataConnectLogger.debug("Created BDO for \(entityGuid)")
      return bdo
    }
    
    DataConnectLogger.debug("Returning existing BDO for \(entityGuid)")
    return dataObject
  }

  func updateBackingData(_ object: BackingDataObject) {
    backingDataObjects[object.guid] = object
  }

  var description: String {
    return "EphemeralCacheProvider - \(cacheIdentifier)"
  }

}
