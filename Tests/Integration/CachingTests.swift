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

import FirebaseCore
@testable import FirebaseDataConnect
import XCTest

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

  // Test preferCache policy: first call fetches from server, second call fetches from cache
  func testPreferCachePolicy() async throws {
    let connector = DataConnect.kitchenSinkConnector
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

  // Test cacheOnly policy when no cached data exists: returns nil data
  func testCacheOnlyPolicy_noCachedData() async throws {
    let connector = DataConnect.kitchenSinkConnector
    let id = UUID()

    let queryRef = connector.getStandardScalarQuery.ref(id: id)

    let emptyResult = try await queryRef.execute(fetchPolicy: .cacheOnly)
    XCTAssertEqual(emptyResult.source, .cache)
    XCTAssertNil(emptyResult.data?.standardScalars)
  }

  // Test cacheOnly policy when cached data exists: returns cached data without fetching from server
  func testCacheOnlyPolicy_withCachedData() async throws {
    let connector = DataConnect.kitchenSinkConnector
    let id = UUID()

    // Populate server and cache with initial data
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 100,
      text: "initial cacheOnly test",
      decimal: 1.23
    )

    let queryRef = connector.getStandardScalarQuery.ref(id: id)
    _ = try await queryRef.execute(fetchPolicy: .preferCache)

    // Perform another mutation on the server to alter the data without updating this query's cache
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 200,
      text: "updated server data",
      decimal: 4.56
    )

    // Now cacheOnly should return the original cached result, ignoring the server update
    let cachedResult = try await queryRef.execute(fetchPolicy: .cacheOnly)
    XCTAssertEqual(cachedResult.source, .cache)
    XCTAssertEqual(cachedResult.data?.standardScalars?.text, "initial cacheOnly test")
    XCTAssertEqual(cachedResult.data?.standardScalars?.number, 100)
  }

  // Test serverOnly policy: always reaches out to server even if cache exists
  func testServerOnlyPolicy() async throws {
    let connector = DataConnect.kitchenSinkConnector
    let id = UUID()

    // Populate server and cache with initial data
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 7,
      text: "initial serverOnly test",
      decimal: 0.99
    )

    let queryRef = connector.getStandardScalarQuery.ref(id: id)
    let firstResult = try await queryRef.execute(fetchPolicy: .serverOnly)
    XCTAssertEqual(firstResult.source, .server)
    XCTAssertEqual(firstResult.data?.standardScalars?.text, "initial serverOnly test")

    // Perform another mutation on the server to alter the data
    _ = try await connector.createStandardScalarMutation.execute(
      id: id,
      number: 8,
      text: "updated serverOnly test",
      decimal: 1.99
    )

    // Second fetch with serverOnly should fetch the new server data, ignoring the cache
    let secondResult = try await queryRef.execute(fetchPolicy: .serverOnly)
    XCTAssertEqual(secondResult.source, .server)
    XCTAssertEqual(secondResult.data?.standardScalars?.text, "updated serverOnly test")
    XCTAssertEqual(secondResult.data?.standardScalars?.number, 8)
  }

  // Test maxAge expiry: once TTL expires, preferCache should reach out to server
  func testMaxAgeExpiry() async throws {
    let ttl: TimeInterval = 2.0
    let connector = DataConnect.kitchenSinkConnector
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
