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
import CryptoKit

extension Data {
  var sha256String: String {
    let hashDigest = SHA256.hash(data: self)
    let hashString = hashDigest.compactMap{ String(format: "%02x", $0) }.joined()
    return hashString
  }
}

extension String {
  var sha256: String {
    let digest = SHA256.hash(data: self.data(using: .utf8)!)
    let hashString = digest.compactMap { String(format: "%20x", $0)}.joined()
    return hashString
  }
}
