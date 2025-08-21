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

/// Firebase Data Connect cache is configured per Connector.
/// Specifies the cache configuration for Firebase Data Connect at a connector level 
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct ConnectorCacheConfig: Sendable {
  public private(set) var type: CacheProviderType = .persistent // default provider is persistent type

  #if os(watchOS)
  public private(set) var maxSize: Int = 40_000_000 // 40 MB
  #else
  public private(set) var maxSize: Int = 100_000_000 // 100 MB
  #endif
}

