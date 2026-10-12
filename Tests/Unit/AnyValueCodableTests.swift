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
import XCTest

@testable import FirebaseDataConnect

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class AnyValueCodableTests: XCTestCase {
  override func setUpWithError() throws {}

  override func tearDownWithError() throws {}

  func testAnyValueStringCodable() throws {
    let stringVal = "Hello World \(Int.random(in: 1 ... 1000))"
    let anyValue = try AnyValue(codableValue: stringVal)
    let stringDecoded = try anyValue.decodeValue(String.self)
    XCTAssert(stringVal == stringDecoded)
  }

  func testAnyValueDoubleRandomCodable() throws {
    let doubleVal = Double
      .random(in: Double.leastNormalMagnitude ... Double.greatestFiniteMagnitude)
    let anyValue = try AnyValue(codableValue: doubleVal)
    let doubleDecoded = try anyValue.decodeValue(Double.self)
    XCTAssertEqual(doubleVal, doubleDecoded)
  }

  func testAnyValueDoubleMaxCodable() throws {
    let doubleValMax = Double.greatestFiniteMagnitude
    let anyValue = try AnyValue(codableValue: doubleValMax)
    let doubleDecoded = try anyValue.decodeValue(Double.self)
    XCTAssertEqual(doubleValMax, doubleDecoded)
  }

  func testAnyValueDoubleMinCodable() throws {
    let doubleValMin = Double.leastNormalMagnitude
    let anyValue = try AnyValue(codableValue: doubleValMin)
    let doubleDecoded = try anyValue.decodeValue(Double.self)
    XCTAssertEqual(doubleValMin, doubleDecoded)
  }

  func testAnyValueInt64RandomCodable() throws {
    let int64 = Int64.random(in: Int64.min ... Int64.max)
    let anyValue = try AnyValue(codableValue: int64)
    let int64Decoded = try anyValue.decodeValue(Int64.self)
    XCTAssertEqual(int64, int64Decoded)
  }

  func testAnyValueInt64MaxCodable() throws {
    let int64 = Int64.max
    let anyValue = try AnyValue(codableValue: int64)
    let int64Decoded = try anyValue.decodeValue(Int64.self)
    XCTAssertEqual(int64, int64Decoded)
  }

  func testAnyValueInt64MinCodable() throws {
    let int64 = Int64.min
    let anyValue = try AnyValue(codableValue: int64)
    let int64Decoded = try anyValue.decodeValue(Int64.self)
    XCTAssertEqual(int64, int64Decoded)
  }

  func testAnyCodableValueInfersCanonicalStrings() throws {
    XCTAssertEqual(try decodeAnyCodableValue("42"), .int64(42))
    XCTAssertEqual(try decodeAnyCodableValue("-42"), .int64(-42))

    let uuidString = "d41d8cd98f00b204e9800998ecf8427e"
    guard case .uuid = try decodeAnyCodableValue(uuidString) else {
      return XCTFail("Expected .uuid for \(uuidString)")
    }

    let timestampString = "2026-05-04T09:10:45.387765Z"
    guard case .timestamp = try decodeAnyCodableValue(timestampString) else {
      return XCTFail("Expected .timestamp for \(timestampString)")
    }
  }

  func testAnyCodableValuePreservesNonCanonicalStrings() throws {
    let strings = [
      "08001",
      "00012688",
      "0012345678",
      "+5",
      "-0",
      "D41D8CD98F00B204E9800998ECF8427E",
      "2026-05-04T11:10:45+02:00",
      "2026-05-04T09:10:45.1Z",
    ]
    for string in strings {
      let value = try decodeAnyCodableValue(string)
      XCTAssertEqual(value, .string(string))
      let reencoded = try JSONDecoder().decode(String.self, from: JSONEncoder().encode(value))
      XCTAssertEqual(reencoded, string)
    }
  }

  private func decodeAnyCodableValue(_ string: String) throws -> AnyCodableValue {
    let json = try JSONEncoder().encode(string)
    return try JSONDecoder().decode(AnyCodableValue.self, from: json)
  }
}
