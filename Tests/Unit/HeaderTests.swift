//
//  HeaderTests.swift
//  FirebaseDataConnect
//
//  Created by Aashish Patil on 9/18/24.
//

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
    let contains = values.contains { $0 == HeaderTests.defaultApp!.options.googleAppID}
    XCTAssertTrue(contains)
  }

}
