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

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
final class AnyScalarTests: IntegrationTestBase {
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

  func testAnyValueString() async throws {
    let testData = "Test String Data \(Int.random(in: 1 ... 10000))"
    let anyTestData = try AnyValue(codableValue: testData)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyTestData
    ).execute()
    print(anyValueId)

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(String.self)
    print(decodedResult)

    XCTAssertEqual(testData, decodedResult)
  }

  func testAnyValueInt() async throws {
    let testNumber = Int.random(in: 1 ... 9999)
    print("testNumber \(testNumber)")
    let anyTestData = try AnyValue(codableValue: testNumber)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyTestData
    ).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Int.self)
    print("decodedNumber \(decodedResult)")
    XCTAssertEqual(testNumber, decodedResult)
  }

  func testAnyValueDouble() async throws {
    let testDouble = Double
      .random(in: Double.leastNormalMagnitude ... Double.greatestFiniteMagnitude)
    let anyTestData = try AnyValue(codableValue: testDouble)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyTestData
    ).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Double.self)

    XCTAssertEqual(testDouble, decodedResult)
  }

  func testAnyValueInt64() async throws {
    let testInt64 = Int64.random(in: Int64.min ... Int64.max)
    let anyTestData = try AnyValue(codableValue: testInt64)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyTestData
    ).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Int64.self)

    XCTAssertEqual(testInt64, decodedResult)
  }

  func testAnyValueInt64Max() async throws {
    let int64Max = Int64.max
    let anyTestData = try AnyValue(codableValue: int64Max)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient
      .createAnyValueTypeMutationRef(id: anyValueId, props: anyTestData).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Int64.self)

    XCTAssertEqual(int64Max, decodedResult)
  }

  func testAnyValueInt64Min() async throws {
    let int64Min = Int64.min
    let anyTestData = try AnyValue(codableValue: int64Min)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient
      .createAnyValueTypeMutationRef(id: anyValueId, props: anyTestData).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Int64.self)

    XCTAssertEqual(int64Min, decodedResult)
  }

  func testAnyValueDoubleMax() async throws {
    let testDouble = Double.greatestFiniteMagnitude
    let anyTestData = try AnyValue(codableValue: testDouble)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyTestData
    ).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Double.self)

    XCTAssertEqual(testDouble, decodedResult)
  }

  func testAnyValueDoubleMin() async throws {
    let testDouble = Double.leastNormalMagnitude
    let anyTestData = try AnyValue(codableValue: testDouble)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyTestData
    ).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(Double.self)

    XCTAssertEqual(testDouble, decodedResult)
  }

  struct AnyValueEmbeddedStruct: Codable, Equatable {
    var stringVal = "Hello World \(Int.random(in: 1 ... 1000))"
    var doubleVal = Double.random(in: 1 ... 10000)
    var dictValInt: [String: Int] = [
      "keyOne": Int.random(in: 1 ... 1000),
      "KeyTwo": Int.random(in: 1 ... 100_000),
    ]

    static func == (lhs: AnyValueEmbeddedStruct, rhs: AnyValueEmbeddedStruct) -> Bool {
      return lhs.stringVal == rhs.stringVal &&
        lhs.doubleVal == rhs.doubleVal &&
        lhs.dictValInt == rhs.dictValInt
    }
  }

  struct AnyValueTestStruct: Codable, Equatable {
    var stringVal = "Test Data \(Int.random(in: 10 ... 1000))"
    var intVal = Int.random(in: 1 ... 10000)
    var doubleVal = Double.random(in: 1 ... 1000)
    var dictVal: [String: String] = ["key1": "val1", "key2": "val2"]
    var dictValDouble: [String: Double] = [
      "key1": Double.random(in: 1 ... 1000),
      "key2": Double.random(in: 1 ... 10000),
    ]
    var structVal = AnyValueEmbeddedStruct()

    static func == (lhs: AnyValueTestStruct, rhs: AnyValueTestStruct) -> Bool {
      return lhs.stringVal == rhs.stringVal &&
        lhs.intVal == rhs.intVal &&
        lhs.doubleVal == rhs.doubleVal &&
        lhs.dictVal == rhs.dictVal &&
        lhs.dictValDouble == rhs.dictValDouble
    }
  }

  func testAnyValueStruct() async throws {
    let structVal = AnyValueTestStruct()
    let anyValStruct = try AnyValue(codableValue: structVal)

    let anyValueId = UUID()
    _ = try await DataConnect.kitchenSinkClient.createAnyValueTypeMutationRef(
      id: anyValueId,
      props: anyValStruct
    ).execute()

    let result = try await DataConnect.kitchenSinkClient.getAnyValueTypeQueryRef(id: anyValueId)
      .execute()
    let anyValueResult = result.data.anyValueType?.props
    let decodedResult = try anyValueResult?.decodeValue(AnyValueTestStruct.self)

    XCTAssertEqual(structVal, decodedResult)
  }
}
