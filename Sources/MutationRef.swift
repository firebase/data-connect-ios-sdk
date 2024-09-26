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
struct MutationRequest<Variable: OperationVariable>: OperationRequest {
  private(set) var operationName: String
  private(set) var variables: Variable?

  init(operationName: String, variables: Variable? = nil) {
    self.operationName = operationName
    self.variables = variables
  }
}

/// Represents a predefined graphql mutation identified by name and variables.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class MutationRef<ResultData: Decodable, Variable: OperationVariable>: OperationRef {
  private var request: any OperationRequest

  private var grpcClient: GrpcClient

  init(request: any OperationRequest, grpcClient: GrpcClient) {
    self.request = request
    self.grpcClient = grpcClient
  }

  public func execute() async throws -> OperationResult<ResultData> {
    let results = try await grpcClient.executeMutation(
      request: request as! MutationRequest<Variable>,
      resultType: ResultData.self
    )
    return results
  }
}
