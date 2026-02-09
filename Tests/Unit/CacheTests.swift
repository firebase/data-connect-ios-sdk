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
  let resultTreeData = """
    {
        "posts": [
          {
            "title": "Post 1",
            "author": {
              "name": "Alice",
            },
            "comments_on_post": [
              {
                "content": "Great post!",
              },
              {
                "content": "Insightful",
              },
            ],
          },
          {
            "title": "Post 2",
            "author": {
              "name": "Bob",
            },
            "comments_on_post": [
              {
                "content": "Me too",
              },
              {
                "content": "Congrats!",
              },
            ],
          },
              {
                "title": "Post 3 by same Author as Post 2",
                "author": {
                  "name": "Bob",
                },
                "comments_on_post": [
                  {
                    "content": "Me too on post3",
                  },
                  {
                    "content": "Congrats! on post3",
                  },
                ],
              },

        ],
      }

  """

  let resultTreeExt = """
      {
          "dataConnect": [
            {
              "path": ["posts"],
              "entityIds": ["idForPost1GoesHere", "idForPost2GoesHere", "idForPost3GoesHere"],
            },
            {
              "path": ["posts", 0, "author"],
              "entityId": "idForAuthorOfPost1",
            },
            {
              "path": ["posts", 1, "author"], 
              "entityId": "idForAuthorOfPost2",
            },
            {
              "path": ["posts", 2, "author"],
              "entityId": "idForAuthorOfPost2",
            },
            {
              "path": ["posts", 0, "comments_on_post"],
              "entityIds": ["idForPost1Comment1", "idForPost1Comment2"],
            },
            {
              "path": ["posts", 1, "comments_on_post"],
              "entityIds": ["idForPost2Comment1", "idForPost2Comment2"],
            },
            {
              "path": ["posts", 2, "comments_on_post"],
              "entityIds": ["idForPost3Comment1", "idForPost3Comment2"],
            },
          ],
        }

  """

  let resultDataOneItem = """
    {
      "post": {
            "title": "Post 1",
            "author": {
              "name": "Alice",
            },
            "comments_on_post": [
              {
                "content": "Great post!",
              },
              {
                "content": "Insightful",
              },
            ],
          },
    }
  """

  let resultDataOneItemExt = """
          {
              "dataConnect": [
                {
                  "path": ["post"],
                  "entityId": "idForPost1GoesHere",
                },
                {
                  "path": ["post", "author"],
                  "entityId": "idForAuthorOfPost1",
                },
                {
                  "path": ["post", "author", "comments_on_post"],
                  "entityIds": ["idForPost1Comment1", "idForPost1Comment2"],
                },
              ],
          }
  """

  let resultDataOneItemUpdate = """
    {
      "post": {
            "title": "Post 1",
            "author": {
              "name": "Alice UPDATE",
            },
            "comments_on_post": [
              {
                "content": "Great post!",
              },
              {
                "content": "Insightful",
              },
            ],
          },
    }
  """

  let resultDataOneItemExtUpdate = """
          {
              "dataConnect": [
                {
                  "path": ["post"],
                  "entityId": "idForPost1GoesHere",
                },
                {
                  "path": ["post", "author"],
                  "entityId": "idForAuthorOfPost1",
                },
                {
                  "path": ["post", "author", "comments_on_post"],
                  "entityIds": ["idForPost1Comment1", "idForPost1Comment2"],
                },
              ],
          }
  """
  
  let anyValueData = """
    {"anyValueItems": [
      { "name": "AnyItemA", 
        "blob": {"values":[["A", "AA"], ["B"], ["C"]]}}, 
      { "name": "AnyItem B", 
        "blob": {"values":["A", 45, {"embedKey": "embedVal"}]}
      }
    ]}
    """
  
  let anyValueSingleData = """
        {"anyValueItem": 
          { "name": "AnyItem B", 
            "blob": {"values":["A", 45, {"embedKey": "embedVal"}, ["A", "AA"]]}
          }
        }
    
    """
  
  let anyValueExt = """
    { "dataConnect": [
      { "path": ["anyValueItems"], 
        "entityIds": ["261f0505ae1927df18b9ee0cff6aff78c77e03516be978d0f83d8fb6ec8cbc07", "9e34d6e7635c90f088d0b92a5876258f5d2c72332c720549b5a71c35058af9c3"]
      }
    ]}
    """
  
  let anyValueSingleExt = """
        { "dataConnect": [
          { "path": ["anyValueItem"], 
            "entityId": "AnyValueItemSingle_ID"
          }
        ]}
    """

  var cacheProvider: SQLiteCacheProvider?

  override func setUpWithError() throws {
    cacheProvider = try SQLiteCacheProvider(
      "testEphemeralCacheProvider",
      ephemeral: true
    )
  }

  override func tearDownWithError() throws {}

  func testParseExtensions() throws {
    do {
      let jsonDecoder = JSONDecoder()
      let extensions = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultTreeExt.data(using: .utf8)!
      )

      let flattenedPaths = extensions.flattenPathMetadata()

      XCTAssertEqual(flattenedPaths.count, 12)

      let path1 = DataConnectPath(components: [.field("posts"), .listIndex(1)])
      let entityId1 = "idForPost2GoesHere"
      XCTAssertEqual(flattenedPaths[path1]?.entityId, entityId1)

      let path2 = DataConnectPath(
        components: [.field("posts"), .listIndex(0), .field("comments_on_post"), .listIndex(0)]
      )
      let entityId2 = "idForPost1Comment1"
      XCTAssertEqual(flattenedPaths[path2]?.entityId, entityId2)

      let path3 = DataConnectPath(components: [.field("posts"), .listIndex(0), .field("author")])
      let entityId3 = "idForAuthorOfPost1"
      XCTAssertEqual(flattenedPaths[path3]?.entityId, entityId3)

      let path4 = DataConnectPath(components: [.field("posts"), .listIndex(1), .field("author")])
      let entityId4 = "idForAuthorOfPost2"
      XCTAssertEqual(flattenedPaths[path4]?.entityId, entityId4)
    }
  }

  func testDehydrate() throws {
    do {
      let cp = try XCTUnwrap(cacheProvider)

      let resultsProcessor = ResultTreeProcessor()

      let jsonDecoder = JSONDecoder()
      let extensions = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultTreeExt.data(using: .utf8)!
      )

      let flattenedPaths = extensions.flattenPathMetadata()

      let (dehydratedResults, rootNode, _) = try resultsProcessor
        .dehydrateResults(
          "testQuery",
          resultTreeData.data(using: .utf8)!,
          flattenedPaths,
          cacheProvider: cp
        )

      print(String(data: dehydratedResults, encoding: .utf8) ?? "No UTF-8 string")

      XCTAssertNotNil(rootNode)

      XCTAssert(rootNode.objectLists.count == 1)

      rootNode.objectLists.values.first?.forEach { node in
        XCTAssert(node.entityData != nil)
      }

    } catch {
      print("Error dehydrating: \(error)")
      throw error
    }
  }

  // Confirm that providing same entity cache id uses the same EntityDataObject instance
  func testEntityDataObjectReuse() throws {
    do {
      let cp = try XCTUnwrap(cacheProvider)

      let jsonDecoder = JSONDecoder()
      let extensions = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultTreeExt.data(using: .utf8)!
      )

      let flattenedPaths = extensions.flattenPathMetadata()

      let resultsProcessor = ResultTreeProcessor()
      _ = try resultsProcessor
        .dehydrateResults(
          "queryList",
          resultTreeData.data(using: .utf8)!,
          flattenedPaths,
          cacheProvider: cp
        )

      let reused_id = "idForAuthorOfPost2"

      let user1 = cp.entityData(reused_id)
      let user2 = cp.entityData(reused_id)

      // both user objects should be references to same db entity
      XCTAssertTrue(user1 == user2)
    }
  }

  func testDehydrationHydration() throws {
    do {
      let cp = try XCTUnwrap(cacheProvider)

      let jsonDecoder = JSONDecoder()
      let extResponse = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultDataOneItemExt.data(using: .utf8)!
      )
      let flattenedPaths = extResponse.flattenPathMetadata()

      let resultsProcessor = ResultTreeProcessor()

      let (dehydratedTree, do1, _) = try resultsProcessor.dehydrateResults("queryOneItem",
                                                                           resultDataOneItem
                                                                             .data(using: .utf8)!,
                                                                           flattenedPaths,
                                                                           cacheProvider: cp)

      let (_, do2) = try resultsProcessor.hydrateResults(
        dehydratedTree,
        cacheProvider: cp
      )

      XCTAssertEqual(do1, do2)
    }
  }

  func testImpactedRefs() throws {
    do {
      let cp = try XCTUnwrap(cacheProvider)

      let resultsProcessor = ResultTreeProcessor()

      let jsonDecoder = JSONDecoder()

      let resultTreeExt = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultTreeExt.data(using: .utf8)!
      )

      let queryIdList = "queryList"
      let (_, _, impactedRefs) = try resultsProcessor.dehydrateResults(
        queryIdList,
        resultTreeData.data(using: .utf8)!,
        resultTreeExt.flattenPathMetadata(),
        cacheProvider: cp
      )
      XCTAssertTrue(impactedRefs.isEmpty) // first query so no 'others' are impacted

      let queryIdOneItem = "queryOneItem"
      let queryIdOneItemExt = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultDataOneItemExt.data(using: .utf8)!
      )
      let (
        _,
        _,
        impactedRefsOneItem
      ) = try resultsProcessor.dehydrateResults(queryIdOneItem,
                                                resultDataOneItem
                                                  .data(using: .utf8)!,
                                                queryIdOneItemExt.flattenPathMetadata(),
                                                cacheProvider: cp)
      XCTAssertTrue(impactedRefsOneItem.contains(queryIdList))

      let queryIdOneItemUpdate = "queryOneItemUpdate"
      let queryIdOneItemUpdateExt = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: resultDataOneItemExtUpdate.data(using: .utf8)!
      )
      let (
        _,
        _,
        impactedRefsOneItemUpdate
      ) = try resultsProcessor.dehydrateResults(
        queryIdOneItemUpdate,
        resultDataOneItemUpdate.data(using: .utf8)!, queryIdOneItemUpdateExt.flattenPathMetadata(),
        cacheProvider: cp
      )
      XCTAssertTrue(impactedRefsOneItemUpdate.contains(queryIdOneItem))
      XCTAssertTrue(impactedRefsOneItemUpdate.contains(queryIdList))
    }
  }
  
  struct AnyValueBlob: Codable {
    var values: [AnyCodableValue]
  }
  
  struct AnyValueCached: Codable {
    var name: String
    var blob: AnyValueBlob
  }
  
  struct AnyValueResponse: Codable {
    var anyValueItem: AnyValueCached
  }
  
  func testAnyValueCaching() throws {
    
    do {
      let cp = try XCTUnwrap(cacheProvider)
      let resultsProcessor = ResultTreeProcessor()
      
      let jsonDecoder = JSONDecoder()
      
      let resultTreeExt = try jsonDecoder.decode(
        ExtensionResponse.self,
        from: anyValueSingleExt.data(using: .utf8)!
      )
      let flattenedPaths = resultTreeExt.flattenPathMetadata()
      
      let (dehydratedTree, do1, _) = try resultsProcessor.dehydrateResults("queryAnyValue",
                                                                           anyValueSingleData
        .data(using: .utf8)!,
                                                                           flattenedPaths,
                                                                           cacheProvider: cp)
      
      let (hydratedData, do2) = try resultsProcessor.hydrateResults(
        dehydratedTree,
        cacheProvider: cp
      )
      
      print("hydrated Data \(String(data: hydratedData, encoding: .utf8))")
      
      let cachedValue = try jsonDecoder.decode(AnyValueResponse.self, from: hydratedData)
      print(cachedValue.anyValueItem.name)
      XCTAssert(cachedValue.anyValueItem.name == "AnyItem B")
      
      XCTAssert(cachedValue.anyValueItem.blob.values.count  == 4)
      
      for (indx, val) in cachedValue.anyValueItem.blob.values.enumerated() {
        
        switch val {
          case let .string(s):
          XCTAssert(indx == 0 && s == "A")
          case let .number(d):
          XCTAssert(indx == 1 && d == 45.0)
        case let .dictionary(d):
          XCTAssert(indx == 2 && d.count == 1)
        case let .array(a):
          XCTAssert(indx == 3 && a.count == 2)
        default:
          XCTFail("Invalid type in internal blob")
        }
      }
      
    } catch {
      print(error)
      XCTFail()
    }
    
  }

  func testMaxAge() throws {
    let ttl: TimeInterval = 0.2 // 200ms
    let resultTree = ResultTree(
      data: resultTreeData.data(using: .utf8)!,
      cachedAt: Date(),
      lastAccessed: Date()
    )

    // Within TTL
    XCTAssertFalse(resultTree.isStale(ttl))

    // Outside TTL
    let expectation = XCTestExpectation(description: "Wait for TTL to expire")
    DispatchQueue.main.asyncAfter(deadline: .now() + ttl + 0.1) {
      XCTAssertTrue(resultTree.isStale(ttl))
      expectation.fulfill()
    }

    wait(for: [expectation], timeout: 1.0)
  }

  // MARK: Schema Versioning

  func testSemanticVersionToInt() throws {
    let intVal = DBSemanticVersion(1, 0, 0)
    XCTAssertEqual(intVal?.storageInt, Int32(1_000_000))

    let intVal2 = DBSemanticVersion(1, 2, 3)
    XCTAssertEqual(intVal2?.storageInt, Int32(1_002_003))

    let intVal3 = DBSemanticVersion(0, 2, 0)
    XCTAssertEqual(intVal3?.storageInt, 2000)

    let intVal4 = DBSemanticVersion(0, 0, 30)
    XCTAssertEqual(intVal4?.storageInt, 30)
  }

  func testInvalidVersionComponents() throws {
    let ver = DBSemanticVersion(1200, 0, 0)

    XCTAssert(ver == nil)
  }

  func testSemanticVersionToString() throws {
    // Test exact major version
    let version1 = DBSemanticVersion(storageInt: 1_000_000)
    XCTAssertEqual(version1.description, "1.0.0")

    // Test standard Major.Minor.Patch
    let version2 = DBSemanticVersion(storageInt: 1_002_003)
    XCTAssertEqual(version2.description, "1.2.3")

    // Test leading zeros in components (Minor version only)
    let version3 = DBSemanticVersion(storageInt: 2000)
    XCTAssertEqual(version3.description, "0.2.0")

    // Test Patch only with padding logic
    let version4 = DBSemanticVersion(storageInt: 30)
    XCTAssertEqual(version4.description, "0.0.30")

    // Test maximum theoretical version for Int32 safety
    let versionMax = DBSemanticVersion(storageInt: 2_147_483_647)
    XCTAssertEqual(versionMax.description, "2147.483.647")
  }

  func testInitializedSchemaVersion() throws {
    let cp = try SQLiteCacheProvider("123", ephemeral: true)

    let initializedVersion = DBSemanticVersion(1, 0, 0)
    XCTAssertEqual(initializedVersion, cp.getSchemaVersion())
  }
}
