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
import CryptoKit

import Firebase

/// A QueryRequest is used to get a QueryRef to a Data Connect query using the specified query name
/// and input variables to the query
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct QueryRequest<Variable: OperationVariable>: OperationRequest, Hashable, Equatable {
  private(set) var operationName: String
  private(set) var variables: Variable?
  
  // Computed requestId
  lazy var requestId: String = {
    var keyIdData = Data()
    if let nameData = operationName.data(using: .utf8) {
      keyIdData.append(nameData)
    }
    
    if let variables {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      do {
        let jsonData = try encoder.encode(variables)
        keyIdData.append(jsonData)
      } catch {
        DataConnectLogger.logger
          .warning("Error encoding variables to compute request identifier: \(error)")
      }
    }
    
    let hashDigest = SHA256.hash(data: keyIdData)
    let hashString = hashDigest.compactMap{ String(format: "%02x", $0) }.joined()
    
    return hashString
  }()

  init(operationName: String, variables: Variable? = nil) {
    self.operationName = operationName
    self.variables = variables
  }

  // Hashable and Equatable implementation
  func hash(into hasher: inout Hasher) {
    hasher.combine(operationName)
    if let variables {
      hasher.combine(variables)
    }
  }

  static func == (lhs: QueryRequest, rhs: QueryRequest) -> Bool {
    guard lhs.operationName == rhs.operationName else {
      return false
    }

    if lhs.variables == nil && rhs.variables == nil {
      return true
    }

    guard let lhsVar = lhs.variables,
          let rhsVar = rhs.variables,
          lhsVar == rhsVar else {
      return false
    }

    return true
  }
}
