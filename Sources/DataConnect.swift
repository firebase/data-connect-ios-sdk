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

import FirebaseAppCheck
import FirebaseAuth
import FirebaseCore
import OSLog

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public class DataConnect {
  private var connectorConfig: ConnectorConfig
  private var app: FirebaseApp
  private var settings: DataConnectSettings

  private(set) var grpcClient: GrpcClient
  private var operationsManager: OperationsManager

  private var callerSDKType: CallerSDKType = .base

  private static var instanceStore = InstanceStore()

  public enum EmulatorDefaults {
    public static let host = "127.0.0.1"
    public static let port = 9399
  }

  public static var logLevel = LogLevel.WARN

  // MARK: Static Creation

  /// Returns an instance of DataConnect matching the parameters.
  /// If a matching instance is found that is returned, otherwise a new instance is created.
  public class func dataConnect(app: FirebaseApp? = FirebaseApp.app(),
                                connectorConfig: ConnectorConfig,
                                settings: DataConnectSettings = DataConnectSettings(),
                                callerSDKType: CallerSDKType = .base)
    -> DataConnect {
    guard let app = app else {
      fatalError("No Firebase App present")
    }

    return instanceStore
      .instance(
        for: app,
        config: connectorConfig,
        settings: settings,
        callerSDKType: callerSDKType
      )
  }

  // MARK: Emulator

  public func useEmulator(host: String = EmulatorDefaults.host,
                          port: Int = EmulatorDefaults.port) {
    settings = DataConnectSettings(host: host, port: port, sslEnabled: false)

    // TODO: - shutdown grpc client
    // self.grpcClient.close
    // self.operations.close

    guard app.options.projectID != nil else {
      fatalError("Firebase DataConnect requires the projectID to be set in the app options")
    }

    grpcClient = GrpcClient(
      app: app,
      settings: settings,
      connectorConfig: connectorConfig,
      auth: Auth.auth(app: app),
      appCheck: AppCheck.appCheck(app: app),
      callerSDKType: callerSDKType
    )

    operationsManager = OperationsManager(grpcClient: grpcClient)
  }

  // MARK: Init

  init(app: FirebaseApp, connectorConfig: ConnectorConfig, settings: DataConnectSettings,
       callerSDKType: CallerSDKType = .base) {
    guard app.options.projectID != nil else {
      fatalError("Firebase DataConnect requires the projectID to be set in the app options")
    }

    self.app = app
    self.settings = settings
    self.connectorConfig = connectorConfig
    self.callerSDKType = callerSDKType

    grpcClient = GrpcClient(
      app: self.app,
      settings: settings,
      connectorConfig: connectorConfig,
      auth: Auth.auth(app: app),
      appCheck: AppCheck.appCheck(app: app),
      callerSDKType: self.callerSDKType
    )
    operationsManager = OperationsManager(grpcClient: grpcClient)
  }

  // MARK: Operations

  /// Returns a query ref matching the name and variables.
  public func query<ResultData: Decodable,
    Variable: OperationVariable>(name: String,
                                 variables: Variable,
                                 resultsDataType: ResultData
                                   .Type,
                                 publisher: ResultsPublisherType = .observableObject)
    -> any ObservableQueryRef {
    let request = QueryRequest(operationName: name, variables: variables)
    return operationsManager.queryRef(for: request, with: resultsDataType, publisher: publisher)
  }

  /// Returns a Mutation Ref matching the name and specified variables.
  public func mutation<ResultData: Decodable,
    Variable: OperationVariable>(name: String,
                                 variables: Variable,
                                 resultsDataType: ResultData
                                   .Type)
    -> MutationRef<ResultData,
      Variable> {
    let request = MutationRequest(operationName: name, variables: variables)
    return operationsManager.mutationRef(for: request, with: resultsDataType)
  }
}

// This enum is public so the gen sdk can access it
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum CallerSDKType {
  case base // base sdk is directly used
  case generated // generated sdk is calling the base
}

// MARK: Instance Creation

// Support for creating or reusing DataConnect instances.
// Instances are keyed by ConnectorConfig and FirebaseApp (projectID)
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private struct InstanceKey: Hashable, Equatable {
  let config: ConnectorConfig
  let app: FirebaseApp

  init(app: FirebaseApp, config: ConnectorConfig) {
    self.app = app
    self.config = config
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(app.name)
    hasher.combine(app.options.projectID)
    hasher.combine(config)
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
private class InstanceStore {
  let accessQ = DispatchQueue(
    label: "firebase.dataconnect.instanceQ",
    autoreleaseFrequency: .workItem
  )

  var instances = [InstanceKey: DataConnect]()

  func instance(for app: FirebaseApp, config: ConnectorConfig,
                settings: DataConnectSettings, callerSDKType: CallerSDKType) -> DataConnect {
    accessQ.sync {
      let key = InstanceKey(app: app, config: config)
      if let inst = instances[key] {
        return inst
      } else {
        let dc = DataConnect(
          app: app,
          connectorConfig: config,
          settings: settings,
          callerSDKType: callerSDKType
        )
        instances[key] = dc
        return dc
      }
    }
  }
}
