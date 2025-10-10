// Copyright 2024 Google LLC
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct DataConnectSettings: Hashable, Equatable, Sendable {
  public let host: String
  public let port: Int
  public let sslEnabled: Bool
  public let cacheConfig: CacheConfig?

  public init(host: String, port: Int, sslEnabled: Bool, cacheConfig: CacheConfig? = CacheConfig()) {
    self.host = host
    self.port = port
    self.sslEnabled = sslEnabled
    self.cacheConfig = cacheConfig
  }

  public init() {
    host = "firebasedataconnect.googleapis.com"
    port = 443
    sslEnabled = true
    cacheConfig = CacheConfig()
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(host)
    hasher.combine(port)
    hasher.combine(sslEnabled)
  }

  public static func == (lhs: DataConnectSettings, rhs: DataConnectSettings) -> Bool {
    return lhs.host == rhs.host &&
      lhs.port == rhs.port &&
      lhs.sslEnabled == rhs.sslEnabled
  }
}
