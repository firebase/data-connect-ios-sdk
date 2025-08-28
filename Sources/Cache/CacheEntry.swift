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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct ResultTreeEntry {
  let serverTimestamp: Timestamp // Server response timestamp
  let cachedAt: Date // Local time when the entry was cached / updated
  let ttl: TimeInterval // interval during which query results are considered fresh
  let data: String // tree data
  var rootObject: StubDataObject?
  
  func isStale(_ ttl: TimeInterval) -> Bool {
    let now = Date()
    return now.timeIntervalSince(cachedAt) > ttl
  }
}

