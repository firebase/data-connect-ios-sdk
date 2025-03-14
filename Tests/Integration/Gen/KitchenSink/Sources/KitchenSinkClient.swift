
import Foundation

import FirebaseCore
import FirebaseDataConnect








public extension DataConnect {

  static let kitchenSinkConnector: KitchenSinkConnector = {
    let dc = DataConnect.dataConnect(connectorConfig: KitchenSinkConnector.connectorConfig, callerSDKType: .generated)
    return KitchenSinkConnector(dataConnect: dc)
  }()

}

public class KitchenSinkConnector {

  let dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(serviceId: "fdc-kitchensink", location: "us-central1", connector: "kitchen-sink")

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect

    // init operations 
    self.createTestIdMutation = CreateTestIdMutation(dataConnect: dataConnect)
    self.createTestAutoIdMutation = CreateTestAutoIdMutation(dataConnect: dataConnect)
    self.createStandardScalarMutation = CreateStandardScalarMutation(dataConnect: dataConnect)
    self.createScalarBoundaryMutation = CreateScalarBoundaryMutation(dataConnect: dataConnect)
    self.createLargeNumMutation = CreateLargeNumMutation(dataConnect: dataConnect)
    self.createLocalDateMutation = CreateLocalDateMutation(dataConnect: dataConnect)
    self.createAnyValueTypeMutation = CreateAnyValueTypeMutation(dataConnect: dataConnect)
    self.insertMultiplePeopleMutation = InsertMultiplePeopleMutation(dataConnect: dataConnect)
    self.getStandardScalarQuery = GetStandardScalarQuery(dataConnect: dataConnect)
    self.getScalarBoundaryQuery = GetScalarBoundaryQuery(dataConnect: dataConnect)
    self.getLargeNumQuery = GetLargeNumQuery(dataConnect: dataConnect)
    self.getLocalDateTypeQuery = GetLocalDateTypeQuery(dataConnect: dataConnect)
    self.getAnyValueTypeQuery = GetAnyValueTypeQuery(dataConnect: dataConnect)
    
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host, port: Int = DataConnect.EmulatorDefaults.port) {
    self.dataConnect.useEmulator(host: host, port: port)
  }

  // MARK: Operations
public let createTestIdMutation: CreateTestIdMutation
public let createTestAutoIdMutation: CreateTestAutoIdMutation
public let createStandardScalarMutation: CreateStandardScalarMutation
public let createScalarBoundaryMutation: CreateScalarBoundaryMutation
public let createLargeNumMutation: CreateLargeNumMutation
public let createLocalDateMutation: CreateLocalDateMutation
public let createAnyValueTypeMutation: CreateAnyValueTypeMutation
public let insertMultiplePeopleMutation: InsertMultiplePeopleMutation
public let getStandardScalarQuery: GetStandardScalarQuery
public let getScalarBoundaryQuery: GetScalarBoundaryQuery
public let getLargeNumQuery: GetLargeNumQuery
public let getLocalDateTypeQuery: GetLocalDateTypeQuery
public let getAnyValueTypeQuery: GetAnyValueTypeQuery


}
