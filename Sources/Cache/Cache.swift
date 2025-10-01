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

import FirebaseAuth

class Cache {
  
  let config: CacheConfig
  let dataConnect: DataConnect
  
  private var cacheProvider: CacheProvider?
  
  private let queue = DispatchQueue(label: "com.google.firebase.dataconnect.cache")
  
  // holding it to avoid dereference
  private var authChangeListenerProtocol: NSObjectProtocol?
  
  init(config: CacheConfig, dataConnect: DataConnect) {
    self.config = config
    self.dataConnect = dataConnect
    
    // sync because we want the provider initialized immediately when in init
    queue.sync {
      self.initializeCacheProvider()
      setupChangeListeners()
    }
    
  }
  
  private func initializeCacheProvider() {
    
    dispatchPrecondition(condition: .onQueue(queue))
    
    let identifier = contructCacheIdentifier()
    
    // Create a cacheProvider if -
    // we don't have an existing cacheProvider
    // we have one but its identifier is different than new one (e.g. auth uid changed)
    if cacheProvider != nil && cacheProvider?.cacheIdentifier == identifier {
      return
    }
    
    switch config.type {
    case .ephemeral:
      self.cacheProvider = EphemeralCacheProvider(identifier)
    case .persistent:
      do {
        self.cacheProvider = try SQLiteCacheProvider(identifier)
      } catch {
        DataConnectLogger.error("Unable to initialize Persistent provider \(error)")
      }
    }
  }
  
  private func setupChangeListeners() {
    dispatchPrecondition(condition: .onQueue(queue))
    
    authChangeListenerProtocol = Auth.auth(app: dataConnect.app).addStateDidChangeListener { _, _ in
      self.queue.async(flags: .barrier) {
        self.initializeCacheProvider()
      }
    }
  }
  
  // Create an identifier for the cache that the Provider will use for cache scoping
  private func contructCacheIdentifier() -> String {
    dispatchPrecondition(condition: .onQueue(queue))
    
    let identifier = "\(self.config.type)-\(String(describing: dataConnect.app.options.projectID))-\(Auth.auth(app: dataConnect.app).currentUser?.uid ?? "anon")-\(dataConnect.settings.host)"
    let encoded = identifier.sha256
    DataConnectLogger.debug("Created Cache Identifier \(encoded) for \(identifier)")
    return encoded
  }
  
  func resultTree(queryId: String) -> ResultTree? {
    // result trees are stored dehydrated in the cache
    // retrieve cache, hydrate it and then return
    queue.sync {
      guard let dehydratedTree = cacheProvider?.resultTree(queryId: queryId) else {
        return nil
      }
      
      do {
        let resultsProcessor = ResultTreeProcessor()
        let (hydratedResults, rootObj) = try resultsProcessor.hydrateResults(
          dehydratedTree.data,
          cacheProvider: cacheProvider!
        )
        
        let hydratedTree = ResultTree(
          data: hydratedResults,
          ttl: dehydratedTree.ttl,
          cachedAt: dehydratedTree.cachedAt,
          lastAccessed: dehydratedTree.lastAccessed,
          rootObject: rootObj
        )

        return hydratedTree
      } catch {
        DataConnectLogger.warning("Error getting result tree \(error)")
        return nil
      }
    }
  }

  func update(queryId: String, response: ServerResponse, requestor: (any QueryRefInternal)? = nil) {
    queue.async(flags: .barrier) {
      guard let cacheProvider = self.cacheProvider else {
      DataConnectLogger.debug("Cache provider not initialized yet. Skipping update for \(queryId)")
      return
      }
      do {
        let processor = ResultTreeProcessor()
        let (dehydratedResults, rootObj, impactedRefs) = try processor.dehydrateResults(
          response.jsonResults,
          cacheProvider: cacheProvider,
          requestor: requestor
        )

        cacheProvider
          .setResultTree(
            queryId: queryId,
            tree: .init(
              data: dehydratedResults,
              ttl: response.ttl,
              cachedAt: Date(),
              lastAccessed: Date(),
              rootObject: rootObj
            )
          )
        
        impactedRefs.forEach { refId in
          guard let q = self.dataConnect.queryRef(for: refId) as? (any QueryRefInternal) else {
            return
          }
          Task {
            do {
              try await q.publishCacheResultsToSubscribers(allowStale: true)
            } catch {
              DataConnectLogger.warning("Error republishing cached results for impacted queryrefs \(error))")
            }
          }
        }
      } catch {
        DataConnectLogger.warning("Error updating cache for \(queryId): \(error)")
      }
    }
  }

}
