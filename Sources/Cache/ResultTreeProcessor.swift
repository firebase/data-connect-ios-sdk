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

// Key that indicates the kind of tree being coded - hydrated or dehydrated
let ResultTreeKindCodingKey = CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.encodingMode")!

// Key that points to the QueryRef being updated in cache
let UpdatingQueryRefsCodingKey = CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.updatingQueryRef")!

// Key pointing to container for QueryRefs. BackingDataObjects fill this
let ImpactedRefsAccumulatorCodingKey = CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.impactedQueryRefs")!

// Kind of result data we are encoding from or decoding to
enum ResultTreeKind {
  case hydrated // JSON data is full hydrated and contains full data in the tree
  case dehydrated // JSON data is dehydrated and only contains refs to actual data objects
}

// Class used to accumulate query refs as we dehydrate the tree and find BDOs
// BDOs contain references to other QueryRefs that reference the BDO
// We collect those QueryRefs here
class ImpactedQueryRefsAccumulator {
  // operationIds of impacted QueryRefs
  private(set) var queryRefIds: Set<String> = []
  
  // QueryRef requesting impacted
  let requestor: (any QueryRefInternal)?
  
  init(requestor: (any QueryRefInternal)? = nil) {
    self.requestor = requestor
  }
  
  // appends the impacted operationId not matching requestor
  func append(_ queryRefId: String) {
    guard requestor != nil else {
      queryRefIds.insert(queryRefId)
      return
    }
    
    if let requestor = requestor,
       queryRefId != requestor.operationId {
      queryRefIds.insert(queryRefId)
    }
    
  }
}

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
  
  func dehydrateResults(_ hydratedTree: String, cacheProvider: CacheProvider, requestor: (any QueryRefInternal)? = nil) throws -> (
    dehydratedResults: String,
    rootObject: StubDataObject,
    impactedRefIds: [String]
  ) {
    let jsonDecoder = JSONDecoder()
    let impactedRefsAccumulator = ImpactedQueryRefsAccumulator(requestor: requestor)
    
    jsonDecoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonDecoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.hydrated
    jsonDecoder.userInfo[ImpactedRefsAccumulatorCodingKey] = impactedRefsAccumulator
    let sdo = try jsonDecoder.decode(StubDataObject.self, from: hydratedTree.data(using: .utf8)!)
    
    DataConnectLogger.debug("Impacted QueryRefs count: \(impactedRefsAccumulator.queryRefIds.count)")
    let impactedRefs = Array(impactedRefsAccumulator.queryRefIds)
     
    let jsonEncoder = JSONEncoder()
    jsonEncoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonEncoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.dehydrated
    let jsonData = try jsonEncoder.encode(sdo)
    let dehydratedResultsString = String(data: jsonData, encoding: .utf8)!
    
    DataConnectLogger
      .debug(
        "\(#function): \nHydrated \n \(hydratedTree) \n\nDehydrated \n \(dehydratedResultsString)"
      )
    
    return (dehydratedResultsString, sdo, impactedRefs)
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
  
}
