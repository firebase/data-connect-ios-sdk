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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct ServerResponse {
  let data: Data // json data
  let extensions: ExtensionResponse?
}

// represents path element along with metadata associated with that path
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct PathMetadataResponse: Decodable {
  let path: [DataConnectPathSegment]
  let entityId: String?
  let entityIds: [String]?
}

// Used to decode the server response contained in `extensions` field
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct ExtensionResponse: Decodable {
  enum CodingKeys: String, CodingKey {
    case maxAge = "ttl"
    case dataConnect
  }

  let maxAge: TimeInterval?
  let dataConnect: [PathMetadataResponse]

  func flattenPathMetadata() -> [DataConnectPath: PathMetadata] {
    var result: [DataConnectPath: PathMetadata] = [:]
    for pmr in dataConnect {
      if let entityId = pmr.entityId {
        let pm = PathMetadata(path: DataConnectPath(segments: pmr.path), entityId: entityId)

        if DataConnectLogger.isDebugEnabled && result[pm.path] != nil {
          // testing only
          DataConnectLogger.debug("ERR - anomaly - path already exists: \(pm.path)")
        }

        result[pm.path] = pm
      }

      if let entityIds = pmr.entityIds {
        for (index, entityId) in entityIds.enumerated() {
          let indexPath = DataConnectPath(segments: pmr.path).appending(
            .listIndex(index)
          )
          let pm = PathMetadata(path: indexPath, entityId: entityId)

          if DataConnectLogger.isDebugEnabled && result[pm.path] != nil {
            // testing only
            DataConnectLogger.debug("ERR - anomaly - path already exists: \(pm.path)")
          }

          result[pm.path] = pm
        }
      }
    }
    return result
  }
}
