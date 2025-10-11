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

// FDC field name in server response that identifies a GlobalID
let GlobalIDKey: String = "cacheId"

let CacheProviderUserInfoKey = CodingUserInfoKey(rawValue: "fdc_cache_provider")!

protocol CacheProvider {
  var cacheIdentifier: String { get }

  func resultTree(queryId: String) -> ResultTree?
  func setResultTree(queryId: String, tree: ResultTree)

  func entityData(_ entityGuid: String) -> EntityDataObject
  func updateEntityData(_ object: EntityDataObject)

  /*

   func size() -> Int
    */
}
