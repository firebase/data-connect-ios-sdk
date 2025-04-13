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
}
