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

// Represents an object node in the ResultTree.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct EntityNode {
  // externalized (normalized) data.
  // Requires an entity globalID to be provided in selection set
  var entityData: EntityDataObject?

  // inline scalars are only populated if there is no EntityDataObject
  // i.e. if there is no entity globalID
  var scalars = [String: AnyCodableValue]()

  // entity properties that point to other entity nodes
  var references = [String: EntityNode]()

  // properties that point to a list of other objects
  // scalar lists are stored inline.
  var objectLists = [String: [EntityNode]]()

  enum CodingKeys: String, CodingKey {
    case globalID = "guid"
    case objectLists
    case references
    case scalars
  }

  init?(value: AnyCodableValue,
        path: DataConnectPath,
        cacheProvider: CacheProvider,
        paths: [DataConnectPath: PathMetadata],
        impactedRefsAccumulator: ImpactedQueryRefsAccumulator? = nil) {
    guard case let .dictionary(objectValues) = value else {
      DataConnectLogger.error("EntityNode inited with a non-dictionary type")
      return nil
    }

    if let mdata = paths[path],
       let entityId = mdata.entityId {
      entityData = cacheProvider.entityData(entityId)
      DataConnectLogger.debug("Got entityData for \(entityId) at \(path)")
    }

    for (key, value) in objectValues {
      switch value {
      case .dictionary:
        // a dictionary is treated as a composite object
        // and converted to another node
        if let st = EntityNode(
          value: value,
          path: path.appending(.field(key)),
          cacheProvider: cacheProvider,
          paths: paths,
          impactedRefsAccumulator: impactedRefsAccumulator
        ) {
          references[key] = st
        } else {
          DataConnectLogger.warning("Failed to convert dictionary to a reference")
        }
      case let .array(objs):
        var refArray = [EntityNode]()
        var scalarArray = [AnyCodableValue]()
        for (index, obj) in objs.enumerated() {
          if let st = EntityNode(
            value: obj,
            path: path.appending(.field(key)).appending(.listIndex(index)),
            // path + key + index /movies/reviews/3
            cacheProvider: cacheProvider,
            paths: paths,
            impactedRefsAccumulator: impactedRefsAccumulator
          ) {
            refArray.append(st)
          } else {
            if obj.isScalar {
              scalarArray.append(obj)
            }
            // Not handling the case of Array of Arrays (matrices)
          }
        }
        if refArray.count > 0, scalarArray.count > 0 {
          DataConnectLogger.debug("Mixed Array of Objects and Scalars found for key \(key)")
          // mixed arrays could occur within Any value types since the content of this type is
          // unpredictable
          // we treat these as dynamic / json values and store the key as-is like scalars.
          if entityData != nil {
            entityData?.updateServerValue(key, value, impactedRefsAccumulator?.requestorId)
          } else {
            scalars[key] = value
          }
        } else if refArray.count > 0 {
          objectLists[key] = refArray
        } else if scalarArray.count > 0 {
          if let entityData {
            let impactedRefs = entityData.updateServerValue(
              key,
              value,
              impactedRefsAccumulator?.requestorId
            )

            // accumulate any impacted QueryRefs due to this change
            for r in impactedRefs {
              impactedRefsAccumulator?.append(r)
            }
          }
        } else {
          // Since we don't know the type of an empty array
          // we store it as a scalar with the Entity if present
          // no point in keeping with query scalars
          // since they get overwritten with every query update
          DataConnectLogger.debug("Empty Array found for key \(key)")
          if entityData != nil {
            entityData?.updateServerValue(key, value, impactedRefsAccumulator?.requestorId)
          }
        }
      default:
        if let entityData {
          let impactedRefs = entityData.updateServerValue(
            key,
            value,
            impactedRefsAccumulator?.requestorId
          )

          // accumulate any QueryRefs impacted by this change
          for r in impactedRefs {
            impactedRefsAccumulator?.append(r)
          }
        } else {
          scalars[key] = value
        }
      }
    } // for (key,value)

    if let entityData {
      for refId in entityData.referencedFromRefs() {
        impactedRefsAccumulator?.append(refId)
      }
      cacheProvider.updateEntityData(entityData)
    }
  }
}

extension EntityNode: Decodable {
  init(from decoder: Decoder) throws {
    guard let cacheProvider = decoder.userInfo[CacheProviderUserInfoKey] as? CacheProvider else {
      throw DataConnectCodecError.decodingFailed(message: "Missing CacheProvider in decoder")
    }

    guard let resultTreeKind = decoder.userInfo[ResultTreeKindCodingKey] as? ResultTreeKind else {
      throw DataConnectCodecError.decodingFailed(message: "Missing ResultTreeKind in decoder")
    }

    if resultTreeKind == .hydrated {
      // our input is a hydrated result tree
      let container = try decoder.singleValueContainer()

      let value = try container.decode(AnyCodableValue.self)

      let impactedRefsAcc = decoder
        .userInfo[ImpactedRefsAccumulatorCodingKey] as? ImpactedQueryRefsAccumulator

      if impactedRefsAcc != nil {
        DataConnectLogger
          .debug("Got impactedRefs before dehydration \(String(describing: impactedRefsAcc))")
      }

      let paths = decoder.userInfo[EntityPathsCodingKey] as? [DataConnectPath: PathMetadata] ?? [:]

      let enode = EntityNode(
        value: value,
        path: DataConnectPath(),
        cacheProvider: cacheProvider,
        paths: paths,
        impactedRefsAccumulator: impactedRefsAcc
      )

      if impactedRefsAcc != nil {
        DataConnectLogger
          .debug("impactedRefs after dehydration \(String(describing: impactedRefsAcc))")
      }

      if let enode {
        self = enode
      } else {
        throw DataConnectCodecError
          .decodingFailed(message: "Failed to decode into a valid EntityNode")
      }

    } else {
      // our input is a dehydrated result tree
      let container = try decoder.container(keyedBy: CodingKeys.self)

      if let globalID = try container.decodeIfPresent(String.self, forKey: .globalID) {
        entityData = cacheProvider.entityData(globalID)
      }

      if let refs = try container.decodeIfPresent([String: EntityNode].self, forKey: .references) {
        references = refs
      }

      if let lists = try container.decodeIfPresent(
        [String: [EntityNode]].self,
        forKey: .objectLists
      ) {
        objectLists = lists
      }

      if let scalars = try container.decodeIfPresent(
        [String: AnyCodableValue].self,
        forKey: .scalars
      ) {
        self.scalars = scalars
      }
    }
  }
}

extension EntityNode: Encodable {
  func encode(to encoder: Encoder) throws {
    guard let resultTreeKind = encoder.userInfo[ResultTreeKindCodingKey] as? ResultTreeKind else {
      throw DataConnectCodecError.decodingFailed(message: "Missing ResultTreeKind in decoder")
    }

    if resultTreeKind == .hydrated {
      var container = encoder.container(keyedBy: DynamicCodingKey.self)

      if let entityData {
        let encodableData = try entityData.encodableData()
        for (key, value) in encodableData {
          try container.encode(value, forKey: DynamicCodingKey(stringValue: key)!)
        }
      }

      if references.count > 0 {
        for (key, value) in references {
          try container.encode(value, forKey: DynamicCodingKey(stringValue: key)!)
        }
      }

      if objectLists.count > 0 {
        for (key, value) in objectLists {
          try container.encode(value, forKey: DynamicCodingKey(stringValue: key)!)
        }
      }

      if scalars.count > 0 {
        for (key, value) in scalars {
          try container.encode(value, forKey: DynamicCodingKey(stringValue: key)!)
        }
      }
    } else {
      // dehydrated tree required
      var container = encoder.container(keyedBy: CodingKeys.self)
      if let entityData {
        try container.encode(entityData.guid, forKey: .globalID)
      }

      if references.count > 0 {
        try container.encode(references, forKey: .references)
      }

      if objectLists.count > 0 {
        try container.encode(objectLists, forKey: .objectLists)
      }

      if scalars.count > 0 {
        try container.encode(scalars, forKey: .scalars)
      }
    }
  }
}

extension EntityNode: Equatable {
  public static func == (lhs: EntityNode, rhs: EntityNode) -> Bool {
    return lhs.entityData == rhs.entityData &&
      lhs.references == rhs.references &&
      lhs.objectLists == rhs.objectLists &&
      lhs.scalars == rhs.scalars
  }
}

extension EntityNode: CustomDebugStringConvertible {
  var debugDescription: String {
    return """
    EntityNode:
        \(String(describing: entityData))
      References:
        \(references)
      Lists:
        \(objectLists)
      Scalars:
        \(scalars)
    """
  }
}
