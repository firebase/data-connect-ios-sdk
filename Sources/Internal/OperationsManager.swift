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
class OperationsManager {
  private var grpcClient: GrpcClient
  
  private var cache: Cache?
 
  private let queryRefAccessQueue = DispatchQueue(
    label: "firebase.dataconnect.queryRef.AccessQ",
    autoreleaseFrequency: .workItem
  )
  private var queryRefs = [String: any ObservableQueryRef]()

  private let mutationRefAccessQueue = DispatchQueue(
    label: "firebase.dataconnect.mutRef.AccessQ",
    autoreleaseFrequency: .workItem
  )
  private var mutationRefs = [AnyHashable: any OperationRef]()

  init(grpcClient: GrpcClient, cache: Cache? = nil) {
    self.grpcClient = grpcClient
    self.cache = cache
  }

  func queryRef<ResultDataType: Decodable & Sendable,
    VariableType: OperationVariable>(for request: QueryRequest<VariableType>,
                                     with resultType: ResultDataType
                                       .Type,
                                     publisher: ResultsPublisherType = .auto)
    -> any ObservableQueryRef {
    queryRefAccessQueue.sync {
      var req = request // requestId is a mutating call.
      let requestId = req.requestId
      
      if let ref = queryRefs[requestId] {
        return ref
      }

      if publisher == .auto || publisher == .observableMacro {
        if #available(iOS 17, macOS 14, tvOS 17, watchOS 10, *) {
          let obsRef = QueryRefObservation<ResultDataType, VariableType>(
            request: request,
            dataType: resultType,
            grpcClient: self.grpcClient,
            cache: self.cache
          ) as (any ObservableQueryRef)
          queryRefs[requestId] = obsRef
          return obsRef
        }
      }

      let refObsObject = QueryRefObservableObject<ResultDataType, VariableType>(
        request: request,
        dataType: resultType,
        grpcClient: grpcClient,
        cache: self.cache
      ) as (any ObservableQueryRef)
      queryRefs[requestId] = refObsObject
      return refObsObject
    } // accessQueue.sync
  }
  
  func queryRef(for operationId: String) -> (any ObservableQueryRef)? {
    queryRefAccessQueue.sync {
      return queryRefs[operationId]
    }
  }

  func mutationRef<ResultDataType: Decodable,
    VariableType: OperationVariable>(for request: MutationRequest<VariableType>,
                                     with resultType: ResultDataType
                                       .Type) -> MutationRef<ResultDataType, VariableType> {
    mutationRefAccessQueue.sync {
      if let ref = mutationRefs[
        AnyHashable(
          request
        )
      ] as? MutationRef<ResultDataType, VariableType> {
        return ref
      }

      let ref = MutationRef<ResultDataType, VariableType>(
        request: request,
        grpcClient: grpcClient
      )
      mutationRefs[AnyHashable(request)] = ref
      return ref
    }
  } // accessQueue.sync
}
