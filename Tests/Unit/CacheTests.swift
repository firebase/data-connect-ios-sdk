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
import XCTest

@testable import FirebaseDataConnect

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class CacheTests: XCTestCase {
  let resultTreeOneItemJson = """
    {"item":{"desc":null,"_id":"a2e64ada1771434aa3ec73f6a6d05428","price":40.456,"reviews":[{"title":"Item4 Review1 byUser3","id":"d769b8d6d4064e81948fb6b9374fba54","_id":"03ADC9EC-0102-4F24-BE8B-F6C0DD102EA4","user":{"name":"User3","id":"69562c9aee2f47ee8abb8181d4df53ec","_id":"65928AFC-22FA-422D-A2F1-85980DC682AE"}}],"id":"98e55525f20f4ee190034adcd6fb01dc","name":"Item4"}}

  """

  let resultTreeOneItemSimple = """
      {"item":{"desc":"itemDesc","name":"itemsOne", "_id":"123","price":4}}
  """

  let resultTreeJson = """
  {"items":[{"id":"0cadb2b93d46434db1d218d6db023b79","price":226.94024396145267,"name":"Item-24","_id":"78192783c32c48cd9b4146547421a6a5","userReviews_on_item":[]},{"_id":"fc9387b4c50a4eb28e91d7a09d108a44","id":"4a01c498dd014a29b20ac693395a2900","userReviews_on_item":[],"name":"Item-62","price":512.3027252608986},{"price":617.9690589103608,"id":"e2ed29ed3e9b42328899d49fa33fc785","userReviews_on_item":[],"_id":"a911561b2b904f008ab8c3a2d2a7fdbe","name":"Item-49"},{"id":"0da168e75ded479ea3b150c13b7c6ec7","price":10.456,"userReviews_on_item":[{"_id":"125791DB-696E-4446-8F2A-C17E7C2AF771","user":{"name":"User1","id":"2fff8099d54843a0bbbbcf905e4c3424","_id":"27E85023-D465-4240-82D6-0055AA122406"},"title":"Item1 Review1 byUser1","id":"1384a5173c31487c8834368348c3b89c"}],"name":"Item1","_id":"fcfa90f7308049a083c3131f9a7a9836"},{"id":"23311f29be09495cba198da89b8b7d0f","name":"Item2","price":20.456,"_id":"c565d2fb7386480c87aa804f2789d200","userReviews_on_item":[{"title":"Item2 Review1 byUser1","user":{"name":"User1","id":"2fff8099d54843a0bbbbcf905e4c3424","_id":"27E85023-D465-4240-82D6-0055AA122406"},"_id":"F652FB4E-65E0-43E0-ADB1-14582304F938","id":"7ec6b021e1654eff98b3482925fab0c9"}]},{"name":"Item3","_id":"c6218faf3607495aaeab752ae6d0b8a7","id":"b7d2287e94014f4fa4a1566f1b893105","price":30.456,"userReviews_on_item":[{"title":"Item3 Review1 byUser2","_id":"8455C788-647F-4AB3-971B-6A9C42456129","id":"9bf4d458dd204a4c8931fe952bba85b7","user":{"id":"00af97d8f274427cb5e2c691ca13521c","name":"User2","_id":"EB588061-7139-4D6D-9A1B-80D4150DC1B4"}}]},{"userReviews_on_item":[{"id":"d769b8d6d4064e81948fb6b9374fba54","_id":"03ADC9EC-0102-4F24-BE8B-F6C0DD102EA4","title":"Item4 Review1 byUser3","user":{"_id":"65928AFC-22FA-422D-A2F1-85980DC682AE","id":"69562c9aee2f47ee8abb8181d4df53ec","name":"User3"}}],"price":40.456,"name":"Item4","id":"98e55525f20f4ee190034adcd6fb01dc","_id":"a2e64ada1771434aa3ec73f6a6d05428"}]}
  """
  var cacheProvider: SQLiteCacheProvider?

  override func setUpWithError() throws {
    cacheProvider = try SQLiteCacheProvider(
      "testEphemeralCacheProvider",
      ephemeral: true
    )
  }

  override func tearDownWithError() throws {}

  // Confirm that providing same entity cache id uses the same EntityDataObject instance
  func testEntityDataObjectReuse() throws {
    do {
      let cp = try XCTUnwrap(cacheProvider)

      let resultsProcessor = ResultTreeProcessor()
      try resultsProcessor.dehydrateResults(resultTreeJson, cacheProvider: cp)

      let reused_id = "27E85023-D465-4240-82D6-0055AA122406"

      let user1 = cp.entityData(reused_id)
      let user2 = cp.entityData(reused_id)

      // both user objects should be references to same db entity
      XCTAssertTrue(user1 == user2)
    }
  }

  func testDehydrationHydration() throws {
    do {
      let cp = try XCTUnwrap(cacheProvider)

      let resultsProcessor = ResultTreeProcessor()

      let (dehydratedTree, do1, _) = try resultsProcessor.dehydrateResults(
        resultTreeOneItemJson,
        cacheProvider: cp
      )

      let (hydratedTree, do2) = try resultsProcessor.hydrateResults(
        dehydratedTree,
        cacheProvider: cp
      )

      XCTAssertEqual(do1, do2)
    }
  }
}
