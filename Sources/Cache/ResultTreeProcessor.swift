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



// Normalization and recontruction of ResultTree
struct ResultTreeProcessor {
  
  /*
   Go down the tree and convert them to Stubs
    For each Stub
      - extract primary key
      - Get the BDO for the PK
        - extract scalars and update BDO with scalars
      - for each array
        - recursively process each object (could be scalar or composite)
      - for composite objects (dictionaries), create references to their stubs
        - create a Stub object and init it with dictionary.
   
   */
  
  func dehydrateResults(_ hydratedTree: String, cacheProvider: CacheProvider) throws -> (dehydratedResults: String, rootObject: StubDataObject) {
    let jsonDecoder = JSONDecoder()
    jsonDecoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonDecoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.hydrated
    let sdo = try jsonDecoder.decode(StubDataObject.self, from: hydratedTree.data(using: .utf8)!)
     
    let jsonEncoder = JSONEncoder()
    jsonEncoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonEncoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.dehydrated
    let jsonData = try jsonEncoder.encode(sdo)
    let dehydratedResultsString = String(data: jsonData, encoding: .utf8)!
    
    DataConnectLogger
      .debug(
        "\(#function): \nHydrated \n \(hydratedTree) \n\nDehydrated \n \(dehydratedResultsString)"
      )
    
    return (dehydratedResultsString, sdo)
  }
  
  
  func hydrateResults(_ dehydratedTree: String, cacheProvider: CacheProvider) throws ->
  (hydratedResults: String, rootObject: StubDataObject) {
     let jsonDecoder = JSONDecoder()
     jsonDecoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
     jsonDecoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.dehydrated
     let sdo = try jsonDecoder.decode(StubDataObject.self, from: dehydratedTree.data(using: .utf8)!)
    DataConnectLogger.debug("Dehydrated Tree decoded to SDO: \(sdo)")
    
     let jsonEncoder = JSONEncoder()
     jsonEncoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
     jsonEncoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.hydrated
     let hydratedResults = try jsonEncoder.encode(sdo)
     let hydratedResultsString = String(data: hydratedResults, encoding: .utf8)!
     
     DataConnectLogger
       .debug(
        "\(#function) Dehydrated \n \(dehydratedTree) \n\nHydrated \n \(hydratedResultsString)"
       )
     
    return (hydratedResultsString, sdo)
  }
  
  //func denormalize(_ tree: String)
}
