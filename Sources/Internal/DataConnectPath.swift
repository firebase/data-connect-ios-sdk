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

// Represents a path within the result data
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct DataConnectPath: Codable {
  enum CodingKeys: String, CodingKey {
    case components = "path"
  }

  let components: [DataConnectPathSegment]

  init(components: [DataConnectPathSegment] = []) {
    self.components = components
  }

  func appending(_ component: DataConnectPathSegment) -> DataConnectPath {
    var nc = components
    nc.append(component)
    return DataConnectPath(components: nc)
  }
}

extension DataConnectPath: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(components)
  }

  public static func == (lhs: DataConnectPath, rhs: DataConnectPath) -> Bool {
    return lhs.components == rhs.components
  }
}

extension DataConnectPath: CustomStringConvertible {
  public var description: String {
    return "DataConnectPath(\(components))"
  }
}
