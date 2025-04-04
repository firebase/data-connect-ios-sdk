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
class IntegrationTestBase: XCTestCase {
  static var defaultApp: FirebaseApp?

  static var options: FirebaseOptions = {
    let options = FirebaseOptions(googleAppID: "0:0000000000000:ios:testAppId",
                                  gcmSenderID: "00000000000000000-00000000000-000000000")
    options.projectID = "fdc-test"
    options.apiKey = "testDummyApiKey"
    return options
  }()

  var fakeConnectorConfigOne = ConnectorConfig(
    serviceId: "dataconnect",
    location: "us-central1",
    connector: "kitchensink"
  )

  override class func setUp() {
    if defaultApp == nil {
      FirebaseApp.configure(options: options)
      defaultApp = FirebaseApp.app()
      FirebaseConfiguration.shared.setLoggerLevel(.debug)
    }
    DataConnect.kitchenSinkConnector.useEmulator(port: 3628)
  }
}
