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

// Client cache that internally uses a CacheProvider to store content.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
actor Cache {
  let config: CacheSettings
  weak var dataConnect: DataConnect?

  private var cacheProvider: CacheProvider?

  // holding it to avoid dealloc
  private var authChangeListenerProtocol: NSObjectProtocol?

  init(config: CacheSettings, dataConnect: DataConnect) {
    self.config = config
    self.dataConnect = dataConnect

    // this is a potential race since update or get could get scheduled before initialize
    // workarounds are complex since caller DataConnect APIs aren't async
    Task {
      await initializeCacheProvider()
      await setupChangeListeners()
    }
  }

  private func initializeCacheProvider() {
    let identifier = contructCacheIdentifier()

    guard identifier.isEmpty == false else {
      DataConnectLogger.error("CacheIdentifier is empty. Caching is disabled")
      return
    }

    // Create a cacheProvider if -
    // we don't have an existing cacheProvider
    // we have one but its identifier is different than new one (e.g. auth uid changed)
    if cacheProvider != nil, cacheProvider?.cacheIdentifier == identifier {
      return
    }

    do {
      switch config.storage {
      case .memory:
        cacheProvider = try SQLiteCacheProvider(identifier, ephemeral: true)
      case .persistent:
        cacheProvider = try SQLiteCacheProvider(identifier, ephemeral: false)
      }
    } catch {
      DataConnectLogger.error("Unable to initialize Persistent provider \(error)")
    }
  }

  private func setupChangeListeners() {
    guard let dataConnect else {
      DataConnectLogger.error("Unable to setup auth change listeners since DataConnect is nil")
      return
    }

    authChangeListenerProtocol = Auth.auth(app: dataConnect.app).addStateDidChangeListener { _, _ in
      self.initializeCacheProvider()
    }
  }

  // Create an identifier for the cache that the Provider will use for cache scoping
  private func contructCacheIdentifier() -> String {
    guard let dataConnect else {
      DataConnectLogger.error("Unable to construct a cache identifier since DataConnect is nil")
      return ""
    }

    let identifier =
      "\(config.storage)-\(dataConnect.app.options.projectID!)-\(dataConnect.app.name)-\(dataConnect.connectorConfig.serviceId)-\(dataConnect.connectorConfig.connector)-\(dataConnect.connectorConfig.location)-\(Auth.auth(app: dataConnect.app).currentUser?.uid ?? "anon")-\(dataConnect.settings.host)"
    let encoded = identifier.sha256
    DataConnectLogger.debug("Created Encoded Cache Identifier \(encoded) for \(identifier)")
    return encoded
  }

  func resultTree(queryId: String) -> ResultTree? {
    // result trees are stored dehydrated in the cache
    // retrieve cache, hydrate it and then return
    guard let cacheProvider else {
      DataConnectLogger.error("CacheProvider is nil in the Cache")
      return nil
    }

    guard let dehydratedTree = cacheProvider.resultTree(queryId: queryId) else {
      return nil
    }

    do {
      let resultsProcessor = ResultTreeProcessor()
      let (hydratedResults, rootObj) = try resultsProcessor.hydrateResults(
        dehydratedTree.data,
        cacheProvider: cacheProvider
      )

      let hydratedTree = ResultTree(
        data: hydratedResults,
        cachedAt: dehydratedTree.cachedAt,
        lastAccessed: dehydratedTree.lastAccessed,
        rootObject: rootObj
      )

      return hydratedTree
    } catch {
      DataConnectLogger.warning("Error decoding result tree \(error)")
      return nil
    }
  }

  func update(queryId: String, response: ServerResponse, requestor: (any QueryRefInternal)? = nil) {
    // server response contains hydrated trees
    // dehydrate (normalize) the results and store dehydrated trees
    guard let cacheProvider = cacheProvider else {
      DataConnectLogger
        .debug("Cache provider not initialized yet. Skipping update for \(queryId)")
      return
    }
    do {
      let processor = ResultTreeProcessor()
      let (dehydratedResults, rootObj, impactedRefs) = try processor.dehydrateResults(queryId,
                                                                                      response
                                                                                        .data,
                                                                                      response
                                                                                        .extensions?
                                                                                        .flattenPathMetadata(
                                                                                        ) ??
                                                                                        [:],
                                                                                      cacheProvider: cacheProvider)

      cacheProvider
        .setResultTree(
          queryId: queryId,
          tree: .init(
            data: dehydratedResults,
            cachedAt: Date(),
            lastAccessed: Date(),
            rootObject: rootObj
          )
        )

      if let dataConnect {
        for refId in impactedRefs {
          guard let q = dataConnect.queryRef(for: refId) as? (any QueryRefInternal) else {
            continue
          }
          Task {
            do {
              try await q.publishCacheResultsToSubscribers(allowStale: true)
            } catch {
              DataConnectLogger
                .warning("Error republishing cached results for impacted queryrefs \(error))")
            }
          }
        }
      }
    } catch {
      DataConnectLogger.warning("Error updating cache for \(queryId): \(error)")
    }
  }
}
