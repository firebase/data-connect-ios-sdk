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

class SynchronizedDictionary<Key: Hashable, Value> {
  private var dictionary: [Key: Value] = [:]
  private let queue: DispatchQueue = DispatchQueue(label: "com.google.firebase.dataconnect.syncDictionaryQ")
  
  init() {}
  
  subscript(key: Key) -> Value? {
    get {
      return queue.sync { self.dictionary[key] }
    } set {
      queue.async(flags: .barrier) {
        self.dictionary[key] = newValue
      }
    }
  }
  
  func rawCopy() -> [Key: Value] {
    return queue.sync { self.dictionary }
  }
  
  
}

extension SynchronizedDictionary: Encodable where Value: Encodable, Key: Encodable {
  func encode(to encoder: any Encoder) throws {
    var container = encoder.singleValueContainer()
    try queue.sync {
      try container.encode(dictionary)
    }
  }
}
