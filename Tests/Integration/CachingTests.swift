// Copyright 2026 Google LLC
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

import XCTest
import FirebaseCore
@testable import FirebaseDataConnect

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class CachingTests: IntegrationTestBase {
  override func setUp(completion: @escaping ((any Error)?) -> Void) {
    Task {
      do {
        try await ProjectConfigurator.shared.configureProject()
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }

  func createCachedConnector(storage: CacheSettings.Storage = .memory, maxAge: TimeInterval = 60) -> KitchenSinkConnector {
    let cacheSettings = CacheSettings(storage: storage, maxAge: maxAge)
    let settings = DataConnectSettings(
      host: DataConnect.EmulatorDefaults.host,
      port: 3628,
      sslEnabled: false,
      cacheSettings: cacheSettings
    )
    let dc = DataConnect(
      app: IntegrationTestBase.defaultApp!,
      connectorConfig: KitchenSinkConnector.connectorConfig,
      settings: settings,
      callerSDKType: .generated
    )
    return KitchenSinkConnector(dataConnect: dc)
  }

  // Test preferCache policy: first call fetches from server, second call fetches from cache
  func testPreferCachePolicy() async throws {
    let connector = createCachedConnector()
    let id = UUID()

    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 42,
      text: "preferCache test",
      decimal: 3.14
    )

    let queryRef = connector.getStandardScalarQuery.ref(id: id)

    // First fetch should come from server
    let firstResult = try await queryRef.execute(fetchPolicy: .preferCache)
    XCTAssertEqual(firstResult.source, .server)
    XCTAssertEqual(firstResult.data?.standardScalars?.text, "preferCache test")

    // Second fetch should come from cache
    let secondResult = try await queryRef.execute(fetchPolicy: .preferCache)
    XCTAssertEqual(secondResult.source, .cache)
    XCTAssertEqual(secondResult.data?.standardScalars?.text, "preferCache test")
  }

  // Test cacheOnly policy: returns cached data if available, or nil if not
  func testCacheOnlyPolicy() async throws {
    let connector = createCachedConnector()
    let id = UUID()

    let queryRef = connector.getStandardScalarQuery.ref(id: id)

    // Initial cacheOnly fetch should return nil data since cache is empty
    let emptyResult = try await queryRef.execute(fetchPolicy: .cacheOnly)
    XCTAssertEqual(emptyResult.source, .cache)
    XCTAssertNil(emptyResult.data?.standardScalars)

    // Populate server and cache
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 100,
      text: "cacheOnly test",
      decimal: 1.23
    )
    _ = try await queryRef.execute(fetchPolicy: .preferCache)

    // Now cacheOnly should return the cached result
    let cachedResult = try await queryRef.execute(fetchPolicy: .cacheOnly)
    XCTAssertEqual(cachedResult.source, .cache)
    XCTAssertEqual(cachedResult.data?.standardScalars?.text, "cacheOnly test")
  }

  // Test serverOnly policy: always reaches out to server even if cache exists
  func testServerOnlyPolicy() async throws {
    let connector = createCachedConnector()
    let id = UUID()

    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 7,
      text: "serverOnly test",
      decimal: 0.99
    )

    let queryRef = connector.getStandardScalarQuery.ref(id: id)

    // First fetch populates cache
    let firstResult = try await queryRef.execute(fetchPolicy: .serverOnly)
    XCTAssertEqual(firstResult.source, .server)

    // Second fetch with serverOnly should still come from server
    let secondResult = try await queryRef.execute(fetchPolicy: .serverOnly)
    XCTAssertEqual(secondResult.source, .server)
  }

  // Test maxAge expiry: once TTL expires, preferCache should reach out to server
  func testMaxAgeExpiry() async throws {
    let ttl: TimeInterval = 1.0
    let connector = createCachedConnector(storage: .memory, maxAge: ttl)
    let id = UUID()

    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 55,
      text: "maxAge test",
      decimal: 5.55
    )

    let queryRef = connector.getStandardScalarQuery.ref(id: id)

    // First fetch from server
    let firstResult = try await queryRef.execute(fetchPolicy: .preferCache)
    XCTAssertEqual(firstResult.source, .server)

    // Immediate second fetch from cache
    let secondResult = try await queryRef.execute(fetchPolicy: .preferCache)
    XCTAssertEqual(secondResult.source, .cache)

    // Wait for TTL to expire
    try await Task.sleep(nanoseconds: UInt64((ttl + 0.5) * 1_000_000_000))

    // Third fetch should re-validate from server because cache is stale
    let staleResult = try await queryRef.execute(fetchPolicy: .preferCache)
    XCTAssertEqual(staleResult.source, .server)
  }
}
