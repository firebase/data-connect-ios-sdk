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
import GRPC

import XCTest

final class HeaderTests: XCTestCase {
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
    FirebaseApp.configure(options: options)
    defaultApp = FirebaseApp.app()
  }

  func testGmpAppIdHeader() async throws {
    let dcOne = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)
    let callOptions = await dcOne.grpcClient.createCallOptions()
    let values = callOptions.customMetadata.values(
      forHeader: GrpcClient.RequestHeaders.firebaseAppId, canonicalForm: false
    )
    let contains = values.contains { $0 == HeaderTests.defaultApp!.options.googleAppID }
    XCTAssertTrue(contains)
  }
}
