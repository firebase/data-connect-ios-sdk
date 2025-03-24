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

import XCTest

import FirebaseCore
@testable import FirebaseDataConnect

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class PartialErrorTests: IntegrationTestBase {
  override func setUp(completion: @escaping ((any Error)?) -> Void) {
    Task {
      do {
        try await ProjectConfigurator.shared.configureProject()
        completion(nil)
      } catch {
        completion(error)
      }
    }
  }

  // Tests for insertion of duplicate primary keys.
  // Second insert should fail
  // Decode should fail so there isn't any partially encoded data
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  func testDuplicatePrimaryKeys() async throws {
    let id = UUID()

    do {
      let results = try await DataConnect.kitchenSinkConnector.insertMultiplePeopleMutation.execute(
        id: id, name1: "name1", name2: "name2"
      ).data
      print("results \(results)")
    } catch let dcError as DataConnectOperationError {
      guard let response = dcError.response else {
        XCTAssertFalse(false, "No response received from partial error")
        throw dcError
      }

      let foo1Path = [DataConnectPathSegment.field("person2")]
      let error = response.errors.first(where: { $0.path == foo1Path })
      XCTAssertNotNil(error)

    } catch {
      XCTFail("Did not throw OperationError \(error)")
    }
  }

  // Test for partially decoded data
  // Second delete fails but first succeeds and returns data
  // We test for existence and equality of first key.
  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  func testPartiallyDecodedData() async throws {
    let id = UUID()
    do {
      _ = try await DataConnect.kitchenSinkConnector.deleteNonExistentPeopleMutation.execute(id: id)
    } catch let dcError as DataConnectOperationError {
      guard let response = dcError.response else {
        XCTAssertFalse(false, "No response received from partial error")
        throw dcError
      }

      if let data = response.data(
        asType: DeleteNonExistentPeopleMutation.Data.self
      ) {
        XCTAssertNil(data.person2)
        XCTAssertTrue(data.person1?.id == id)
      } else {
        XCTFail("Partial Data is nil. We should have got back partially decoded data")
      }
    }
  }
}
