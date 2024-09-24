import Foundation
import FirebaseDataConnect







public extension DataConnect {

  static var friendlyFlixClient: FriendlyFlixClient = {
    let dc = DataConnect.dataConnect(connectorConfig: FriendlyFlixClient.connectorConfig)
    return FriendlyFlixClient(dataConnect: dc)
  }()

}

public class FriendlyFlixClient {

  var dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(serviceId: "friendly-flix-service", location: "us-central1", connector: "friendly-flix")

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host, port: Int = DataConnect.EmulatorDefaults.port) {
    self.dataConnect.useEmulator(host: host, port: port)
  }

}
