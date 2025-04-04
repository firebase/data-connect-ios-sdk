// DO NOT EDIT.
// swift-format-ignore-file
//
// Generated by the Swift generator plugin for the protocol buffer compiler.
// Source: connector_service.proto
//
// For information on using the generated types, please see the documentation:
//   https://github.com/apple/swift-protobuf/

// Copyright 2025 Google LLC
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

///adopted from third_party/firebase/dataconnect/emulator/server/api/connector_service.proto

import Foundation
import SwiftProtobuf

// If the compiler emits an error on this type, it is because this file
// was generated by a version of the `protoc` Swift plug-in that is
// incompatible with the version of SwiftProtobuf to which you are linking.
// Please ensure that you are building against the same version of the API
// that was used to generate this file.
fileprivate struct _GeneratedWithProtocGenSwiftVersion: SwiftProtobuf.ProtobufAPIVersionCheck {
  struct _2: SwiftProtobuf.ProtobufAPIVersion_2 {}
  typealias Version = _2
}

/// The ExecuteQuery request to Firebase Data Connect.
public struct Google_Firebase_Dataconnect_V1_ExecuteQueryRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The resource name of the connector to find the predefined query, in
  /// the format:
  /// ```
  /// projects/{project}/locations/{location}/services/{service}/connectors/{connector}
  /// ```
  public var name: String = String()

  /// The name of the GraphQL operation name.
  /// Required because all Connector operations must be named.
  /// See https://graphql.org/learn/queries/#operation-name.
  /// (-- api-linter: core::0122::name-suffix=disabled
  ///     aip.dev/not-precedent: Must conform to GraphQL HTTP spec standard. --)
  public var operationName: String = String()

  /// Values for GraphQL variables provided in this request.
  public var variables: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _variables ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_variables = newValue}
  }
  /// Returns true if `variables` has been explicitly set.
  public var hasVariables: Bool {return self._variables != nil}
  /// Clears the value of `variables`. Subsequent reads from it will return its default value.
  public mutating func clearVariables() {self._variables = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _variables: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

/// The ExecuteMutation request to Firebase Data Connect.
public struct Google_Firebase_Dataconnect_V1_ExecuteMutationRequest {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The resource name of the connector to find the predefined mutation, in
  /// the format:
  /// ```
  /// projects/{project}/locations/{location}/services/{service}/connectors/{connector}
  /// ```
  public var name: String = String()

  /// The name of the GraphQL operation name.
  /// Required because all Connector operations must be named.
  /// See https://graphql.org/learn/queries/#operation-name.
  /// (-- api-linter: core::0122::name-suffix=disabled
  ///     aip.dev/not-precedent: Must conform to GraphQL HTTP spec standard. --)
  public var operationName: String = String()

  /// Values for GraphQL variables provided in this request.
  public var variables: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _variables ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_variables = newValue}
  }
  /// Returns true if `variables` has been explicitly set.
  public var hasVariables: Bool {return self._variables != nil}
  /// Clears the value of `variables`. Subsequent reads from it will return its default value.
  public mutating func clearVariables() {self._variables = nil}

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _variables: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

/// The ExecuteQuery response from Firebase Data Connect.
public struct Google_Firebase_Dataconnect_V1_ExecuteQueryResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The result of executing the requested operation.
  public var data: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _data ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_data = newValue}
  }
  /// Returns true if `data` has been explicitly set.
  public var hasData: Bool {return self._data != nil}
  /// Clears the value of `data`. Subsequent reads from it will return its default value.
  public mutating func clearData() {self._data = nil}

  /// Errors of this response.
  public var errors: [Google_Firebase_Dataconnect_V1_GraphqlError] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _data: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

/// The ExecuteMutation response from Firebase Data Connect.
public struct Google_Firebase_Dataconnect_V1_ExecuteMutationResponse {
  // SwiftProtobuf.Message conformance is added in an extension below. See the
  // `Message` and `Message+*Additions` files in the SwiftProtobuf library for
  // methods supported on all messages.

  /// The result of executing the requested operation.
  public var data: SwiftProtobuf.Google_Protobuf_Struct {
    get {return _data ?? SwiftProtobuf.Google_Protobuf_Struct()}
    set {_data = newValue}
  }
  /// Returns true if `data` has been explicitly set.
  public var hasData: Bool {return self._data != nil}
  /// Clears the value of `data`. Subsequent reads from it will return its default value.
  public mutating func clearData() {self._data = nil}

  /// Errors of this response.
  public var errors: [Google_Firebase_Dataconnect_V1_GraphqlError] = []

  public var unknownFields = SwiftProtobuf.UnknownStorage()

  public init() {}

  fileprivate var _data: SwiftProtobuf.Google_Protobuf_Struct? = nil
}

#if swift(>=5.5) && canImport(_Concurrency)
extension Google_Firebase_Dataconnect_V1_ExecuteQueryRequest: @unchecked Sendable {}
extension Google_Firebase_Dataconnect_V1_ExecuteMutationRequest: @unchecked Sendable {}
extension Google_Firebase_Dataconnect_V1_ExecuteQueryResponse: @unchecked Sendable {}
extension Google_Firebase_Dataconnect_V1_ExecuteMutationResponse: @unchecked Sendable {}
#endif  // swift(>=5.5) && canImport(_Concurrency)

// MARK: - Code below here is support for the SwiftProtobuf runtime.

fileprivate let _protobuf_package = "google.firebase.dataconnect.v1"

extension Google_Firebase_Dataconnect_V1_ExecuteQueryRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExecuteQueryRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .standard(proto: "operation_name"),
    3: .same(proto: "variables"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.operationName) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._variables) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.operationName.isEmpty {
      try visitor.visitSingularStringField(value: self.operationName, fieldNumber: 2)
    }
    try { if let v = self._variables {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Google_Firebase_Dataconnect_V1_ExecuteQueryRequest, rhs: Google_Firebase_Dataconnect_V1_ExecuteQueryRequest) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.operationName != rhs.operationName {return false}
    if lhs._variables != rhs._variables {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Google_Firebase_Dataconnect_V1_ExecuteMutationRequest: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExecuteMutationRequest"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "name"),
    2: .standard(proto: "operation_name"),
    3: .same(proto: "variables"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularStringField(value: &self.name) }()
      case 2: try { try decoder.decodeSingularStringField(value: &self.operationName) }()
      case 3: try { try decoder.decodeSingularMessageField(value: &self._variables) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    if !self.name.isEmpty {
      try visitor.visitSingularStringField(value: self.name, fieldNumber: 1)
    }
    if !self.operationName.isEmpty {
      try visitor.visitSingularStringField(value: self.operationName, fieldNumber: 2)
    }
    try { if let v = self._variables {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 3)
    } }()
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Google_Firebase_Dataconnect_V1_ExecuteMutationRequest, rhs: Google_Firebase_Dataconnect_V1_ExecuteMutationRequest) -> Bool {
    if lhs.name != rhs.name {return false}
    if lhs.operationName != rhs.operationName {return false}
    if lhs._variables != rhs._variables {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Google_Firebase_Dataconnect_V1_ExecuteQueryResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExecuteQueryResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "data"),
    2: .same(proto: "errors"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._data) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.errors) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._data {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.errors.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.errors, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Google_Firebase_Dataconnect_V1_ExecuteQueryResponse, rhs: Google_Firebase_Dataconnect_V1_ExecuteQueryResponse) -> Bool {
    if lhs._data != rhs._data {return false}
    if lhs.errors != rhs.errors {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}

extension Google_Firebase_Dataconnect_V1_ExecuteMutationResponse: SwiftProtobuf.Message, SwiftProtobuf._MessageImplementationBase, SwiftProtobuf._ProtoNameProviding {
  public static let protoMessageName: String = _protobuf_package + ".ExecuteMutationResponse"
  public static let _protobuf_nameMap: SwiftProtobuf._NameMap = [
    1: .same(proto: "data"),
    2: .same(proto: "errors"),
  ]

  public mutating func decodeMessage<D: SwiftProtobuf.Decoder>(decoder: inout D) throws {
    while let fieldNumber = try decoder.nextFieldNumber() {
      // The use of inline closures is to circumvent an issue where the compiler
      // allocates stack space for every case branch when no optimizations are
      // enabled. https://github.com/apple/swift-protobuf/issues/1034
      switch fieldNumber {
      case 1: try { try decoder.decodeSingularMessageField(value: &self._data) }()
      case 2: try { try decoder.decodeRepeatedMessageField(value: &self.errors) }()
      default: break
      }
    }
  }

  public func traverse<V: SwiftProtobuf.Visitor>(visitor: inout V) throws {
    // The use of inline closures is to circumvent an issue where the compiler
    // allocates stack space for every if/case branch local when no optimizations
    // are enabled. https://github.com/apple/swift-protobuf/issues/1034 and
    // https://github.com/apple/swift-protobuf/issues/1182
    try { if let v = self._data {
      try visitor.visitSingularMessageField(value: v, fieldNumber: 1)
    } }()
    if !self.errors.isEmpty {
      try visitor.visitRepeatedMessageField(value: self.errors, fieldNumber: 2)
    }
    try unknownFields.traverse(visitor: &visitor)
  }

  public static func ==(lhs: Google_Firebase_Dataconnect_V1_ExecuteMutationResponse, rhs: Google_Firebase_Dataconnect_V1_ExecuteMutationResponse) -> Bool {
    if lhs._data != rhs._data {return false}
    if lhs.errors != rhs.errors {return false}
    if lhs.unknownFields != rhs.unknownFields {return false}
    return true
  }
}
