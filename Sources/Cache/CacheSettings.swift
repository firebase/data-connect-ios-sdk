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

/// Specifies the cache configuration for a `DataConnect` instance.
///
/// You can configure the cache's storage policy and its maximum size.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct CacheSettings: Sendable {
  /// Defines the storage mechanism for the cache.
  public enum Storage: Sendable {
    /// The cache will be written to disk, persisting data across application launches.
    case persistent
    /// The cache will only be stored in memory and will be cleared when the application terminates.
    case memory
  }

  /// The storage mechanism to be used for caching. The default is `.persistent`.
  public let storage: Storage
  /// The maximum size of the cache in bytes.
  ///
  /// This size is not strictly enforced but is used as a guideline by the cache
  /// to trigger cleanup procedures. The default is 100MB (100,000,000 bytes).
  public let maxSizeBytes: UInt64

  /// Max time interval before a queries cache is considered stale and refreshed from the server
  /// This interval does not imply that cached data is evicted and it can still be accessed using
  /// the `cacheOnly` fetch policy
  public let maxAge: TimeInterval

  /// Creates a new cache settings configuration.
  ///
  /// - Parameters:
  ///   - storage: The storage mechanism to use. Defaults to `.persistent`.
  ///   - maxSize: The maximum desired size of the cache in bytes. Defaults to 100MB.
  ///   - maxAge: The max time interval before a queries cache is considered stale and refreshed
  /// from the server. Defaults to zero, implying queries results are always fetched from server and
  /// also cached. Results can be fetched from cache using the `cacheOnly` flag.
  public init(storage: Storage = .persistent, maxSize: UInt64 = 100_000_000,
              maxAge: TimeInterval = 0) {
    self.storage = storage
    maxSizeBytes = maxSize
    self.maxAge = maxAge
  }
}
