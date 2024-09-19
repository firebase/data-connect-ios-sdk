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

import FirebaseCore
@testable import FirebaseDataConnect

final class UserAgentTests: XCTestCase {
  static var options: FirebaseOptions = {
    let options = FirebaseOptions(googleAppID: "0:0000000000000:ios:0000000000000000",
                                  gcmSenderID: "00000000000000000-00000000000-000000000")
    options.projectID = "user-agent-test"
    options.apiKey = "testUserAgentDummyApiKey"
    return options
  }()

  override class func setUp() {
    FirebaseApp.configure(name: "user-agent", options: options)
  }

  /// Confirm that Data Connect gets added to the user agent.
  func testUserAgent() {
    let userAgent = FirebaseApp.firebaseUserAgent()
    let version = Version.version
    XCTAssertTrue(userAgent.contains("fire-dc/\(version)"))
  }
}
