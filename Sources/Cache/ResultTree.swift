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
struct ResultTree {
  let data: String // tree data - could be hydrated or dehydrated.
  let ttl: TimeInterval // interval during which query results are considered fresh
  let cachedAt: Date // Local time when the entry was cached / updated
  var lastAccessed: Date // Local time when the entry was read or updated
  
  var rootObject: StubDataObject?
  
  func isStale(_ ttl: TimeInterval) -> Bool {
    let now = Date()
    return now.timeIntervalSince(cachedAt) > ttl
  }
  
  enum CodingKeys: String, CodingKey {
    case cachedAt = "ca"
    case lastAccessed = "la"
    case ttl = "ttl"
    case data = "d"
  }

}


extension ResultTree: Codable {
  init(from decoder: any Decoder) throws {
    let container = try decoder.container(keyedBy: CodingKeys.self)
    self.cachedAt = try container.decode(Date.self, forKey: .cachedAt)
    self.lastAccessed = try container.decode(Date.self, forKey: .lastAccessed)
    self.ttl = try container.decode(TimeInterval.self, forKey: .ttl)
    self.data = try container.decode(String.self, forKey: .data)
  }
  
  func encode(to encoder: any Encoder) throws {
    var container = encoder.container(keyedBy: CodingKeys.self)
    try container.encode(cachedAt, forKey: .cachedAt)
    try container.encode(lastAccessed, forKey: .lastAccessed)
    try container.encode(ttl, forKey: .ttl)
    try container.encode(data, forKey: .data)
  }
}
