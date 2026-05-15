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

/// Policies for executing a Data Connect query. This value is optionally passed to `execute()`
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum QueryFetchPolicy {
  /// default policy tries to fetch from cache if fetch is within the `maxAge`.
  /// If fetch is outside `maxAge` it revalidates / refreshes from the server.
  /// Throws if server revalidation fails
  /// `maxAge` is specified as part of the YAML config using
  /// `clientCache.revalidateAfter` key.
  /// Documentation: https://firebase.google.com/docs/sql-connect/ios-sdk#caching
  case preferCache

  /// Always attempts to return from cache even if outside `maxAge`. Does not reach out to server.
  case cacheOnly

  /// Attempts to fetch from server ignoring cache.
  /// Cache is refreshed from server data if call succeeds.
  /// Throws if server call fails.
  case serverOnly
}
