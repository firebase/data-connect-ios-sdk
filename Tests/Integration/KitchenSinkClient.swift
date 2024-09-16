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

import FirebaseDataConnect
import Foundation

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public extension DataConnect {
  static var kitchenSinkClient: KitchenSinkClient = {
    let dc = DataConnect.dataConnect(connectorConfig: KitchenSinkClient.connectorConfig)
    return KitchenSinkClient(dataConnect: dc)
  }()
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public class KitchenSinkClient {
  var dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(
    serviceId: "fdc-kitchensink",
    location: "us-central1",
    connector: "kitchen-sink"
  )

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host,
                          port: Int = DataConnect.EmulatorDefaults.port) {
    dataConnect.useEmulator(host: host, port: port)
  }
}
