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


/// Indicates the source of the query results data.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum QueryResultSource: Sendable {
  
  /// source not known or cannot be determined
  case unknown
  
  /// The query results are from server
  case server
  
  /// Query results are from cache
  /// stale - indicates if cached data is within TTL or outside.
  case cache(stale: Bool)
}
