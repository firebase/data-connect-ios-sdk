//
//  DataConnectPath.swift
//  FirebaseDataConnect
//
//  Created by Aashish Patil on 1/9/26.
//

// Represents a path within the result data
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct DataConnectPath: Codable {
  enum CodingKeys: String, CodingKey {
    case components = "path"
  }

  let components: [DataConnectPathSegment]

  init(components: [DataConnectPathSegment] = []) {
    self.components = components
  }

  func appending(_ component: DataConnectPathSegment) -> DataConnectPath {
    var nc = components
    nc.append(component)
    return DataConnectPath(components: nc)
  }
}

extension DataConnectPath: Hashable {
  public func hash(into hasher: inout Hasher) {
    hasher.combine(components)
  }

  public static func == (lhs: DataConnectPath, rhs: DataConnectPath) -> Bool {
    return lhs.components == rhs.components
  }
}

extension DataConnectPath: CustomStringConvertible {
  public var description: String {
    return "DataConnectPath(\(components))"
  }
}
