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

import XCTest

import FirebaseCore
@testable import FirebaseDataConnect

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
func demo(id: UUID, connector: KitchenSinkConnector) async throws
    -> InsertMultiplePeopleMutation.Data {

  do {
    return try await connector.insertMultiplePeopleMutation.execute(
      id: id, name1: "name1", name2: "name2").data
  } catch let dcError {
    guard let dcError = dcError as? DataConnectError else {
      throw dcError
    }

    let response = switch dcError {
      case .operationExecutionFailed(_, let response): response
      default: throw dcError
    }

    let foo1Path = [OperationFailureResponseErrorInfo.PathSegment.field("foo1")]
    if let error = response.errorInfoList.first(where: { $0.path == foo1Path }) {
      print("Inserting 1st entry with ID \(id) failed: \(error.message)")
    } else {
      print("Inserting 1st entry with ID \(id) succeeded")
    }

    let foo2Path = [OperationFailureResponseErrorInfo.PathSegment.field("foo2")]
    if let error = response.errorInfoList.first(where: { $0.path == foo2Path }) {
      print("Inserting 2nd entry with ID \(id) failed: \(error.message)")
    } else {
      print("Inserting 2nd entry with ID \(id) succeeded")
    }

    if let decodedData = response.decodedData(asType: InsertMultiplePeopleMutation.Data.self) {
      print("Even though there was an error, decoding the data was successful:")
      print("person1=\(decodedData.person1) person2=\(decodedData.person2)")
      return decodedData
    }

    throw dcError
  }
}

