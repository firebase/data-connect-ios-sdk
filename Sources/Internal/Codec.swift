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

import SwiftProtobuf

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
typealias FirebaseDataConnectExecuteMutationRequest =
  Google_Firebase_Dataconnect_V1beta_ExecuteMutationRequest
typealias FirebaseDataConnectExecuteQueryRequest =
  Google_Firebase_Dataconnect_V1beta_ExecuteQueryRequest

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
class Codec {
  // Encode Codable to Protos
  func encode(args: any Encodable) throws -> Google_Protobuf_Struct {
    do {
      let jsonEncoder = JSONEncoder()
      let jsonData = try jsonEncoder.encode(args)
      let argsStruct = try Google_Protobuf_Struct(jsonUTF8Data: jsonData)
      return argsStruct
    }
  }

  // Decode Protos to Codable
  func decode<T: Decodable>(result: Google_Protobuf_Struct, asType: T.Type) throws -> T? {
    do {
      let jsonData = try result.jsonUTF8Data()
      let jsonDecoder = JSONDecoder()

      let resultAsType = try jsonDecoder.decode(asType, from: jsonData)

      return resultAsType
    }
  }

  func createQueryRequestProto<VariableType: OperationVariable>(connectorName: String,
                                                                request: QueryRequest<
                                                                  VariableType
                                                                >) throws
    -> FirebaseDataConnectExecuteQueryRequest {
    do {
      var varStruct: Google_Protobuf_Struct? = nil
      if let variables = request.variables {
        varStruct = try encode(args: variables)
      }

      let internalRequest = FirebaseDataConnectExecuteQueryRequest.with { ireq in
        ireq.operationName = request.operationName

        if let varStruct {
          ireq.variables = varStruct
        } else {
          ireq.variables = Google_Protobuf_Struct()
        }

        ireq.name = connectorName
      }

      return internalRequest
    }
  }

  func createMutationRequestProto<VariableType: OperationVariable>(connectorName: String,
                                                                   request: MutationRequest<
                                                                     VariableType
                                                                   >) throws
    -> FirebaseDataConnectExecuteMutationRequest {
    do {
      var varStruct: Google_Protobuf_Struct? = nil
      if let variables = request.variables {
        varStruct = try encode(args: variables)
      }

      let internalRequest = FirebaseDataConnectExecuteMutationRequest
        .with { ireq in
          ireq.operationName = request.operationName

          if let varStruct {
            ireq.variables = varStruct
          } else {
            // always provide an empty struct otherwise request fails.
            ireq.variables = Google_Protobuf_Struct()
          }

          ireq.name = connectorName
        }

      return internalRequest
    }
  }
}
