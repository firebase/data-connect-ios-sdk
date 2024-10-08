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
import Foundation

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class TimestampTests: XCTestCase {
  override func setUpWithError() throws {}

  override func tearDownWithError() throws {}

  func testSecondsEquals0AndNanosecondsEquals0() throws {
    try verifyEncodeDecodeRoundTrip(Timestamp(seconds: 0, nanoseconds: 0))
  }

  func testSmallestValue() throws {
    try verifyEncodeDecodeRoundTrip(Timestamp(seconds: -62_135_596_800, nanoseconds: 0))
  }

  func testLargestValue() throws {
    try verifyEncodeDecodeRoundTrip(Timestamp(seconds: -62_135_596_800, nanoseconds: 999_999_999))
  }

  func testMillisecondPrecision() throws {
    try verifyEncodeDecodeRoundTrip(Timestamp(seconds: 130_804, nanoseconds: 642))
  }

  func testMicrosecondPrecision() throws {
    try verifyEncodeDecodeRoundTrip(Timestamp(seconds: 130_804, nanoseconds: 642))
  }

  func testWhenTimeSecfracIsOmitted() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05Z"),
      Timestamp(seconds: 1_136_214_245, nanoseconds: 0)
    )
  }

  func testWhenTimeSecfracHasMillisecondPrecision() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05.123Z"),
      Timestamp(seconds: 1_136_214_245, nanoseconds: 123_000_000)
    )
  }

  func testWhenTimeSecfracHasMicrosecondPrecision() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05.123456Z"),
      Timestamp(seconds: 1_136_214_245, nanoseconds: 123_456_000)
    )
  }

  func testWhenTimeSecfracHasNanosecondPrecision() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05.123456789Z"),
      Timestamp(seconds: 1_136_214_245, nanoseconds: 123_456_789)
    )
  }

  func testDecodeWhenTimeOffsetIs0() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05-00:00"),
      decodeTimestamp("2006-01-02T15:04:05Z")
    )

    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05+00:00"),
      decodeTimestamp("2006-01-02T15:04:05Z")
    )
  }

  func testDecodeWhenTimeOffsetIsPositive() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05+07:00"),
      decodeTimestamp("2006-01-02T08:04:05Z")
    )
  }

  func testDecodeWhenTimeOffsetIsNegative() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02T15:04:05-05:10"),
      decodeTimestamp("2006-01-02T20:14:05Z")
    )
  }

  func testDecodeWithBothTimeSecFracAndTimeOffset() throws {
    try XCTAssertEqual(
      decodeTimestamp("2023-05-21T11:04:05.462-12:07"),
      decodeTimestamp("2023-05-21T23:11:05.462Z")
    )

    try XCTAssertEqual(
      decodeTimestamp("2053-11-02T15:04:05.743393-05:10"),
      decodeTimestamp("2053-11-02T20:14:05.743393Z")
    )

    try XCTAssertEqual(
      decodeTimestamp("1538-03-05T15:04:05.653498752-03:01"),
      decodeTimestamp("1538-03-05T18:05:05.653498752Z")
    )

    try XCTAssertEqual(
      decodeTimestamp("2023-05-21T11:04:05.662+10:01"),
      decodeTimestamp("2023-05-21T01:03:05.662Z")
    )

    try XCTAssertEqual(
      decodeTimestamp("2144-01-02T15:04:05.753493+01:00"),
      decodeTimestamp("2144-01-02T14:04:05.753493Z")
    )

    try XCTAssertEqual(
      decodeTimestamp("1358-03-05T15:04:05.527094582+13:03"),
      decodeTimestamp("1358-03-05T02:01:05.527094582Z")
    )
  }

  func testDecodeIsCaseInsensitive() throws {
    try XCTAssertEqual(
      decodeTimestamp("2006-01-02t15:04:05.123456789z"),
      decodeTimestamp("2006-01-02t15:04:05.123456789Z")
    )
  }

  func testMinimumValueInDataConnect() throws {
    try XCTAssertEqual(
      decodeTimestamp("1583-01-01T00:00:00.000000Z"),
      Timestamp(seconds: -12_212_553_600, nanoseconds: 0)
    )
  }

  func testMaximumValueInDataConnect() throws {
    try XCTAssertEqual(
      decodeTimestamp("9999-12-31T23:59:59.999999999Z"),
      Timestamp(seconds: 253_402_300_799, nanoseconds: 999_999_999)
    )
  }

  func testInvalidFormatShouldThrow() throws {
    for invalidText in invalidTimestampStrs {
      XCTAssertThrowsError(try decodeTimestamp(invalidText))
    }
  }

  func verifyEncodeDecodeRoundTrip(_ timestamp: Timestamp) throws {
    do {
      let jsonEncoder = JSONEncoder()
      let jsonData = try jsonEncoder.encode(timestamp)

      let jsonDecoder = JSONDecoder()
      let decodedTimestamp = try jsonDecoder.decode(Timestamp.self, from: jsonData)

      XCTAssertEqual(timestamp, decodedTimestamp)
    }
  }

  func decodeTimestamp(_ text: String) throws -> Timestamp {
    let jsonEncoder = JSONEncoder()
    let jsonData = try jsonEncoder.encode(text)

    let jsonDecoder = JSONDecoder()
    let decodedTimestamp = try jsonDecoder.decode(Timestamp.self, from: jsonData)
    return decodedTimestamp
  }

  // These strings were generated by Gemini
  let invalidTimestampStrs: [String] =
    [
      "",
      "1985-04-12T23:20:50.123456789",
      "1985-04-12T23:20:50.123456789X",
      "1985-04-12T23:20:50.123456789+",
      "1985-04-12T23:20:50.123456789+07",
      "1985-04-12T23:20:50.123456789+07:",
      "1985-04-12T23:20:50.123456789+07:0",
      "1985-04-12T23:20:50.123456789+07:000",
      "1985-04-12T23:20:50.123456789+07:00a",
      "1985-04-12T23:20:50.123456789+07:a0",
      "1985-04-12T23:20:50.123456789+07::00",
      "1985-04-12T23:20:50.123456789+0:00",
      "1985-04-12T23:20:50.123456789+00:",
      "1985-04-12T23:20:50.123456789+00:0",
      "1985-04-12T23:20:50.123456789+00:a",
      "1985-04-12T23:20:50.123456789+00:0a",
      "1985-04-12T23:20:50.123456789+0:0a",
      "1985-04-12T23:20:50.123456789+0:a0",
      "1985-04-12T23:20:50.123456789+0::00",
      "1985-04-12T23:20:50.123456789-07:0a",
      "1985-04-12T23:20:50.123456789-07:a0",
      "1985-04-12T23:20:50.123456789-07::00",
      "1985-04-12T23:20:50.123456789-0:0a",
      "1985-04-12T23:20:50.123456789-0:a0",
      "1985-04-12T23:20:50.123456789-0::00",
      "1985-04-12T23:20:50.123456789-00:0a",
      "1985-04-12T23:20:50.123456789-00:a0",
      "1985-04-12T23:20:50.123456789-00::00",
      "1985-04-12T23:20:50.123456789-0:00",
      "1985-04-12T23:20:50.123456789-00:",
      "1985-04-12T23:20:50.123456789-00:0",
      "1985-04-12T23:20:50.123456789-00:a",
      "1985-04-12T23:20:50.123456789-00:0a",
      "1985-04-12T23:20:50.123456789-0:0a",
      "1985-04-12T23:20:50.123456789-0:a0",
      "1985-04-12T23:20:50.123456789-0::00",
      "1985/04/12T23:20:50.123456789Z",
      "1985-04-12T23:20:50.123456789Z.",
      "1985-04-12T23:20:50.123456789Z..",
      "1985-04-12T23:20:50.123456789Z...",
      "1985-04-12T23:20:50.123456789+07:00.",
      "1985-04-12T23:20:50.123456789+07:00..",
      "1985-04-12T23:20:50.123456789+07:00...",
      "1985-04-12T23:20:50.123456789-07:00.",
      "1985-04-12T23:20:50.123456789-07:00..",
      "1985-04-12T23:20:50.123456789-07:00...",
      "1985-04-12T23:20:50.1234567890Z",
      "1985-04-12T23:20:50.12345678900Z",
      "1985-04-12T23:20:50.123456789000Z",
      "1985-04-12T23:20:50.1234567890000Z",
      "1985-04-12T23:20:50.12345678900000Z",
      "1985-04-12T23:20:50.123456789000000Z",
      "1985-04-12T23:20:50.1234567890000000Z",
      "1985-04-12T23:20:50.12345678900000000Z",
      "1985-04-12T23:20:50.1234567891Z",
      "1985-04-12T23:20:50.12345678911Z",
      "1985-04-12T23:20:50.123456789111Z",
      "1985-04-12T23:20:50.1234567891111Z",
      "1985-04-12T23:20:50.12345678911111Z",
      "1985-04-12T23:20:50.123456789111111Z",
      "1985-04-12T23:20:50.1234567891111111Z",
      "1985-04-12T23:20:50.12345678911111111Z",
      "1985-04-12T23:20:50.123456789000000000Z",
      "1985-04-12T23:20:50.1234567890000000000Z",
      "1985-04-12T23:20:50.12345678900000000000Z",
    ]
}
