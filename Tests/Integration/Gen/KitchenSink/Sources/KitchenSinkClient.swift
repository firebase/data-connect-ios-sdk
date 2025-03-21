
import Foundation

import FirebaseCore
import FirebaseDataConnect

public extension DataConnect {
  static let kitchenSinkConnector: KitchenSinkConnector = {
    let dc = DataConnect.dataConnect(
      connectorConfig: KitchenSinkConnector.connectorConfig,
      callerSDKType: .generated
    )
    return KitchenSinkConnector(dataConnect: dc)
  }()
}

public class KitchenSinkConnector {
  let dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(
    serviceId: "fdc-kitchensink",
    location: "us-central1",
    connector: "kitchen-sink"
  )

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect

    // init operations
    createTestIdMutation = CreateTestIdMutation(dataConnect: dataConnect)
    createTestAutoIdMutation = CreateTestAutoIdMutation(dataConnect: dataConnect)
    createStandardScalarMutation = CreateStandardScalarMutation(dataConnect: dataConnect)
    createScalarBoundaryMutation = CreateScalarBoundaryMutation(dataConnect: dataConnect)
    createLargeNumMutation = CreateLargeNumMutation(dataConnect: dataConnect)
    createLocalDateMutation = CreateLocalDateMutation(dataConnect: dataConnect)
    createAnyValueTypeMutation = CreateAnyValueTypeMutation(dataConnect: dataConnect)
    insertMultiplePeopleMutation = InsertMultiplePeopleMutation(dataConnect: dataConnect)
    deleteNonExistentPeopleMutation = DeleteNonExistentPeopleMutation(dataConnect: dataConnect)
    getStandardScalarQuery = GetStandardScalarQuery(dataConnect: dataConnect)
    getScalarBoundaryQuery = GetScalarBoundaryQuery(dataConnect: dataConnect)
    getLargeNumQuery = GetLargeNumQuery(dataConnect: dataConnect)
    getLocalDateTypeQuery = GetLocalDateTypeQuery(dataConnect: dataConnect)
    getAnyValueTypeQuery = GetAnyValueTypeQuery(dataConnect: dataConnect)
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host,
                          port: Int = DataConnect.EmulatorDefaults.port) {
    dataConnect.useEmulator(host: host, port: port)
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
  public let deleteNonExistentPeopleMutation: DeleteNonExistentPeopleMutation
  public let getStandardScalarQuery: GetStandardScalarQuery
  public let getScalarBoundaryQuery: GetScalarBoundaryQuery
  public let getLargeNumQuery: GetLargeNumQuery
  public let getLocalDateTypeQuery: GetLocalDateTypeQuery
  public let getAnyValueTypeQuery: GetAnyValueTypeQuery
}
