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

import FirebaseCore
@testable import FirebaseDataConnect
import Foundation
import XCTest

@available(iOS 15.0, macOS 11.0, tvOS 15.0, watchOS 8.0, *)
class InstanceTests: XCTestCase {
  static var defaultApp: FirebaseApp?
  static var appTwo: FirebaseApp?

  static var options: FirebaseOptions = {
    let options = FirebaseOptions(googleAppID: "0:0000000000000:ios:0000000000000000",
                                  gcmSenderID: "00000000000000000-00000000000-000000000")
    options.projectID = "fdc-test"
    options.apiKey = "testDummyApiKey"
    return options
  }()

  static var optionsTwo: FirebaseOptions = {
    let optionsTwo = FirebaseOptions(
      googleAppID: "0:0000000000001:ios:0000000000000001",
      gcmSenderID: "00000000000000000-00000000000-000000001"
    )
    optionsTwo.projectID = "fdc-test"
    optionsTwo.apiKey = "testDummyApiKey2"
    return optionsTwo
  }()

  var fakeConnectorConfigOne = ConnectorConfig(
    serviceId: "dataconnect",
    location: "us-central1",
    connector: "kitchensink"
  )
  var fakeConnectorConfigTwo = ConnectorConfig(
    serviceId: "dataconnect",
    location: "us-central1",
    connector: "blogs"
  )

  override class func setUp() {
    FirebaseApp.configure(options: options)
    defaultApp = FirebaseApp.app()

    FirebaseApp.configure(name: "app-two", options: optionsTwo)
    appTwo = FirebaseApp.app(name: "app-two")
  }

  // same connector config, same app, instance returned should be same
  func testSameInstance() throws {
    let dcOne = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let dcTwo = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let isSameInstance = dcOne === dcTwo
    XCTAssertTrue(isSameInstance)
  }

  // same connector config, different apps, instances should be different
  func testDifferentInstanceDifferentApps() throws {
    let dcOne = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)
    let dcTwo = DataConnect.dataConnect(
      app: InstanceTests.appTwo,
      connectorConfig: fakeConnectorConfigTwo
    )

    let isDifferent = dcOne !== dcTwo
    XCTAssertTrue(isDifferent)
  }
}
