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

actor EphemeralCacheProvider: CacheProvider, @preconcurrency CustomStringConvertible {
  
  let cacheConfig: CacheConfig
  
  let cacheIdentifier: String
  
  init(cacheConfig: CacheConfig, cacheIdentifier: String) {
    self.cacheConfig = cacheConfig
    self.cacheIdentifier = cacheIdentifier
    
    DataConnectLogger.debug("Initialized \(Self.Type.self) with config \(cacheConfig)")
  }
  
  private var resultTreeCache: [String: ResultTreeEntry] = [:]
  
  func setResultTree(queryId: String, serverTimestamp: Timestamp, data: String) {
    resultTreeCache[queryId] =  .init(
      serverTimestamp: serverTimestamp,
      cachedAt: Date(),
      data: data
    )
  }

  func resultTree(queryId: String) -> ResultTreeEntry? {
    return resultTreeCache[queryId]
  }
  
  var description: String {
    return "EphemeralCacheProvider - \(cacheIdentifier)"
  }

}
