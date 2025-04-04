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
public struct ConnectorConfig: Hashable, Equatable, Sendable {
  public private(set) var serviceId: String
  public private(set) var location: String
  public private(set) var connector: String

  public init(serviceId: String, location: String, connector: String) {
    self.serviceId = serviceId
    self.location = location
    self.connector = connector
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(serviceId)
    hasher.combine(location)
    hasher.combine(connector)
  }

  public static func == (lhs: Self, rhs: Self) -> Bool {
    return lhs.serviceId == rhs.serviceId &&
      lhs.location == rhs.location &&
      lhs.connector == rhs.connector
  }
}
