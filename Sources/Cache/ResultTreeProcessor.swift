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
let ResultTreeKindCodingKey =
  CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.encodingMode")!

// Key that points to the QueryRef being updated in cache
let UpdatingQueryRefsCodingKey =
  CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.updatingQueryRef")!

// Key pointing to accumulator for referenced QueryRefs. EntityDataObjects fill this
let ImpactedRefsAccumulatorCodingKey =
  CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.impactedQueryRefs")!

// Key pointing to queryId being processed
let QueryIdCodingKey =
CodingUserInfoKey(rawValue: "com.google.firebase.dataconnect.queryId")!

// Kind-of result data we are encoding from or decoding to
enum ResultTreeKind {
  case hydrated // JSON data is full hydrated and contains full data in the tree
  case dehydrated // JSON data is dehydrated and only contains refs to actual data objects
}

// Class used to accumulate query refs as we dehydrate the tree and find EDOs
// EDOs contain references to other QueryRefs that reference the EDO
// We collect those QueryRefs here
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
class ImpactedQueryRefsAccumulator {
  // operationIds of impacted QueryRefs
  private(set) var queryRefIds: Set<String> = []

  // QueryRef requesting impacted
  //let requestor: (any QueryRefInternal)?
  let requestorId: String?

  init(requestor: (any QueryRefInternal)? = nil) {
    self.requestorId = requestor?.operationId
  }
  
  init(requestorId: String? = nil) {
    self.requestorId = requestorId
  }

  // appends the impacted operationId not matching requestor
  func append(_ queryRefId: String) {
    guard requestorId != nil else {
      queryRefIds.insert(queryRefId)
      return
    }

    if let requestorId,
       queryRefId != requestorId {
      queryRefIds.insert(queryRefId)
    }
  }
}

// Dehydration (normalization) and hydration of the data
// Hooks into the Codable process with userInfo flags driving what data gets encoded / decoded
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct ResultTreeProcessor {
  /*
    Takes a JSON tree with data and normalizes the entities contained in it,
    creating a resultant JSON tree with references to entities.
   */
  func dehydrateResults(_ queryId: String, _ hydratedTree: String, cacheProvider: CacheProvider) throws -> (
    dehydratedResults: String,
    rootObject: EntityNode,
    impactedRefIds: [String]
  ) {
    guard let hydratedData = hydratedTree.data(using: .utf8) else {
      throw DataConnectCodecError.encodingFailed()
    }

    let jsonDecoder = JSONDecoder()
    let impactedRefsAccumulator = ImpactedQueryRefsAccumulator(requestorId: queryId)

    jsonDecoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonDecoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.hydrated
    jsonDecoder.userInfo[ImpactedRefsAccumulatorCodingKey] = impactedRefsAccumulator
    let enode = try jsonDecoder.decode(EntityNode.self, from: hydratedData)

    DataConnectLogger
      .debug("Impacted QueryRefs count: \(impactedRefsAccumulator.queryRefIds.count)")
    let impactedRefs = Array(impactedRefsAccumulator.queryRefIds)

    let jsonEncoder = JSONEncoder()
    jsonEncoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonEncoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.dehydrated
    let jsonData = try jsonEncoder.encode(enode)

    guard let dehydratedResultsString = String(data: jsonData, encoding: .utf8) else {
      throw DataConnectCodecError.encodingFailed()
    }

    DataConnectLogger
      .debug(
        "\(#function): \nHydrated \n \(hydratedTree) \n\nDehydrated \n \(dehydratedResultsString)"
      )

    return (dehydratedResultsString, enode, impactedRefs)
  }

  /*
      Takes a dehydrated tree and fills it up with Entity data from referenced entities.
   */
  func hydrateResults(_ dehydratedTree: String, cacheProvider: CacheProvider) throws ->
    (hydratedResults: String, rootObject: EntityNode) {
    guard let dehydratedData = dehydratedTree.data(using: .utf8) else {
      throw DataConnectCodecError
        .decodingFailed(message: "Failed to convert dehydratedTree to Data")
    }

    let jsonDecoder = JSONDecoder()
    jsonDecoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonDecoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.dehydrated
    let enode = try jsonDecoder.decode(EntityNode.self, from: dehydratedData)
    DataConnectLogger.debug("Dehydrated Tree decoded to EDO: \(enode)")

    let jsonEncoder = JSONEncoder()
    jsonEncoder.userInfo[CacheProviderUserInfoKey] = cacheProvider
    jsonEncoder.userInfo[ResultTreeKindCodingKey] = ResultTreeKind.hydrated

    let hydratedResults = try jsonEncoder.encode(enode)
    guard let hydratedResultsString = String(data: hydratedResults, encoding: .utf8) else {
      throw DataConnectCodecError
        .encodingFailed(message: "Failed to convert EDO to String")
    }

    DataConnectLogger
      .debug(
        "\(#function) Dehydrated \n \(dehydratedTree) \n\nHydrated \n \(hydratedResultsString)"
      )

    return (hydratedResultsString, enode)
  }
}
