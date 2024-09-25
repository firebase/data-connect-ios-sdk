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

  struct VariableTypeOne: OperationVariable {
    var email: String
    var handle: String
    var someNumber: Int
  }

  // same query name, same variables, should return same instance
  func testSameQueryRefInstance() throws {
    let dc = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let queryName = "someQuery"
    let variableOne = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)
    let variableTwo = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)

    let refOne = dc.query(
      name: queryName,
      variables: variableOne,
      resultsDataType: Int.self,
      publisher: .observableObject
    ) as! QueryRefObservableObject<Int, VariableTypeOne>

    let refTwo = dc.query(
      name: queryName,
      variables: variableTwo,
      resultsDataType: Int.self,
      publisher: .observableObject
    ) as! QueryRefObservableObject<Int, VariableTypeOne>

    let isSameInstance = refOne === refTwo
    XCTAssertTrue(isSameInstance)
  }

  // same query name but different variable values (same variable type).
  // should return different instances
  func testQueryDifferentVariablesDifferentRefInstance() throws {
    let dc = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let queryName = "someQuery"
    let variableOne = VariableTypeOne(email: "aa1@g.com", handle: "aa@", someNumber: 12345)
    let variableTwo = VariableTypeOne(email: "aa2@g.com", handle: "aa@", someNumber: 12345)

    let refOne = dc.query(
      name: queryName,
      variables: variableOne,
      resultsDataType: Int.self,
      publisher: .observableObject
    ) as! QueryRefObservableObject<Int, VariableTypeOne>

    let refTwo = dc.query(
      name: queryName,
      variables: variableTwo,
      resultsDataType: Int.self,
      publisher: .observableObject
    ) as! QueryRefObservableObject<Int, VariableTypeOne>

    let isDifferentInstance = refOne !== refTwo
    XCTAssertTrue(isDifferentInstance)
  }

  // different query names, same variables values
  // should return different instances
  func testDifferentQueryNamesSameVariables() throws {
    let dc = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let queryNameOne = "someQueryOne"
    let queryNameTwo = "someQueryTwo"
    let variableOne = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)
    let variableTwo = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)

    let refOne = dc.query(
      name: queryNameOne,
      variables: variableOne,
      resultsDataType: Int.self,
      publisher: .observableObject
    ) as! QueryRefObservableObject<Int, VariableTypeOne>

    let refTwo = dc.query(
      name: queryNameTwo,
      variables: variableTwo,
      resultsDataType: Int.self,
      publisher: .observableObject
    ) as! QueryRefObservableObject<Int, VariableTypeOne>

    let isDifferentInstance = refOne !== refTwo
    XCTAssertTrue(isDifferentInstance)
  }

  // same query name, same variables, should return same instance
  func testSameMutationRefInstance() throws {
    let dc = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let name = "someMutation"
    let variableOne = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)
    let variableTwo = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)

    let refOne = dc.mutation(name: name, variables: variableOne, resultsDataType: Int.self)

    let refTwo = dc.mutation(
      name: name,
      variables: variableTwo,
      resultsDataType: Int.self
    )

    let isSameInstance = refOne === refTwo
    XCTAssertTrue(isSameInstance)
  }

  // same mutation name but different variable values (same variable type).
  // should return different instances
  func testMutationDifferentVariablesDifferentRefInstance() throws {
    let dc = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let name = "someQuery"
    let variableOne = VariableTypeOne(email: "aa1@g.com", handle: "aa@", someNumber: 12345)
    let variableTwo = VariableTypeOne(email: "aa2@g.com", handle: "aa@", someNumber: 12345)

    let refOne = dc.mutation(
      name: name,
      variables: variableOne,
      resultsDataType: Int.self
    )

    let refTwo = dc.mutation(
      name: name,
      variables: variableTwo,
      resultsDataType: Int.self
    )

    let isDifferentInstance = refOne !== refTwo
    XCTAssertTrue(isDifferentInstance)
  }

  // different mutation names, same variables values
  // should return different instances
  func testDifferentMutationNamesSameVariables() throws {
    let dc = DataConnect.dataConnect(connectorConfig: fakeConnectorConfigOne)

    let nameOne = "someNameOne"
    let nameTwo = "someNameTwo"
    let variableOne = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)
    let variableTwo = VariableTypeOne(email: "aa@g.com", handle: "aa@", someNumber: 12345)

    let refOne = dc.mutation(
      name: nameOne,
      variables: variableOne,
      resultsDataType: Int.self
    )

    let refTwo = dc.mutation(
      name: nameTwo,
      variables: variableTwo,
      resultsDataType: Int.self
    )

    let isDifferentInstance = refOne !== refTwo
    XCTAssertTrue(isDifferentInstance)
  }
}
