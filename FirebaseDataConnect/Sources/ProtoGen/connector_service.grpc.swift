//
// DO NOT EDIT.
//
// Generated by the protocol buffer compiler.
// Source: connector_service.proto
//

//
// Copyright 2018, gRPC Authors All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
import GRPC
import NIO
import NIOConcurrencyHelpers
import SwiftProtobuf


/// Firebase Data Connect provides means to deploy a set of predefined GraphQL
/// operations (queries and mutations) as a Connector.
///
/// Firebase developers can build mobile and web apps that uses Connectors
/// to access Data Sources directly. Connectors allow operations without
/// admin credentials and help Firebase customers control the API exposure.
///
/// Note: `ConnectorService` doesn't check IAM permissions and instead developers
/// must define auth policies on each pre-defined operation to secure this
/// connector. The auth policies typically define rules on the Firebase Auth
/// token.
///
/// Usage: instantiate `Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClient`, then call methods of this protocol to make API calls.
public protocol Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientProtocol: GRPCClient {
  var serviceName: String { get }
  var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? { get }

  func executeQuery(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>

  func executeMutation(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest,
    callOptions: CallOptions?
  ) -> UnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>
}

extension Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientProtocol {
  public var serviceName: String {
    return "google.firebase.dataconnect.v1alpha.ConnectorService"
  }

  /// Execute a predefined query in a Connector.
  ///
  /// - Parameters:
  ///   - request: Request to send to ExecuteQuery.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func executeQuery(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse> {
    return self.makeUnaryCall(
      path: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeQuery.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeExecuteQueryInterceptors() ?? []
    )
  }

  /// Execute a predefined mutation in a Connector.
  ///
  /// - Parameters:
  ///   - request: Request to send to ExecuteMutation.
  ///   - callOptions: Call options.
  /// - Returns: A `UnaryCall` with futures for the metadata, status and response.
  public func executeMutation(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest,
    callOptions: CallOptions? = nil
  ) -> UnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse> {
    return self.makeUnaryCall(
      path: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeMutation.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeExecuteMutationInterceptors() ?? []
    )
  }
}

#if compiler(>=5.6)
@available(*, deprecated)
extension Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClient: @unchecked Sendable {}
#endif // compiler(>=5.6)

@available(*, deprecated, renamed: "Google_Firebase_Dataconnect_V1alpha_ConnectorServiceNIOClient")
public final class Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClient: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientProtocol {
  private let lock = Lock()
  private var _defaultCallOptions: CallOptions
  private var _interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol?
  public let channel: GRPCChannel
  public var defaultCallOptions: CallOptions {
    get { self.lock.withLock { return self._defaultCallOptions } }
    set { self.lock.withLockVoid { self._defaultCallOptions = newValue } }
  }
  public var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? {
    get { self.lock.withLock { return self._interceptors } }
    set { self.lock.withLockVoid { self._interceptors = newValue } }
  }

  /// Creates a client for the google.firebase.dataconnect.v1alpha.ConnectorService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self._defaultCallOptions = defaultCallOptions
    self._interceptors = interceptors
  }
}

public struct Google_Firebase_Dataconnect_V1alpha_ConnectorServiceNIOClient: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientProtocol {
  public var channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol?

  /// Creates a client for the google.firebase.dataconnect.v1alpha.ConnectorService service.
  ///
  /// - Parameters:
  ///   - channel: `GRPCChannel` to the service host.
  ///   - defaultCallOptions: Options to use for each service call if the user doesn't provide them.
  ///   - interceptors: A factory providing interceptors for each RPC.
  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#if compiler(>=5.6)
/// Firebase Data Connect provides means to deploy a set of predefined GraphQL
/// operations (queries and mutations) as a Connector.
///
/// Firebase developers can build mobile and web apps that uses Connectors
/// to access Data Sources directly. Connectors allow operations without
/// admin credentials and help Firebase customers control the API exposure.
///
/// Note: `ConnectorService` doesn't check IAM permissions and instead developers
/// must define auth policies on each pre-defined operation to secure this
/// connector. The auth policies typically define rules on the Firebase Auth
/// token.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncClientProtocol: GRPCClient {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? { get }

  func makeExecuteQueryCall(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>

  func makeExecuteMutationCall(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest,
    callOptions: CallOptions?
  ) -> GRPCAsyncUnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncClientProtocol {
  public static var serviceDescriptor: GRPCServiceDescriptor {
    return Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.serviceDescriptor
  }

  public var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? {
    return nil
  }

  public func makeExecuteQueryCall(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse> {
    return self.makeAsyncUnaryCall(
      path: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeQuery.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeExecuteQueryInterceptors() ?? []
    )
  }

  public func makeExecuteMutationCall(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest,
    callOptions: CallOptions? = nil
  ) -> GRPCAsyncUnaryCall<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse> {
    return self.makeAsyncUnaryCall(
      path: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeMutation.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeExecuteMutationInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncClientProtocol {
  public func executeQuery(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse {
    return try await self.performAsyncUnaryCall(
      path: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeQuery.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeExecuteQueryInterceptors() ?? []
    )
  }

  public func executeMutation(
    _ request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest,
    callOptions: CallOptions? = nil
  ) async throws -> Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse {
    return try await self.performAsyncUnaryCall(
      path: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeMutation.path,
      request: request,
      callOptions: callOptions ?? self.defaultCallOptions,
      interceptors: self.interceptors?.makeExecuteMutationInterceptors() ?? []
    )
  }
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public struct Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncClient: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncClientProtocol {
  public var channel: GRPCChannel
  public var defaultCallOptions: CallOptions
  public var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol?

  public init(
    channel: GRPCChannel,
    defaultCallOptions: CallOptions = CallOptions(),
    interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol? = nil
  ) {
    self.channel = channel
    self.defaultCallOptions = defaultCallOptions
    self.interceptors = interceptors
  }
}

#endif // compiler(>=5.6)

public protocol Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientInterceptorFactoryProtocol: GRPCSendable {

  /// - Returns: Interceptors to use when invoking 'executeQuery'.
  func makeExecuteQueryInterceptors() -> [ClientInterceptor<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>]

  /// - Returns: Interceptors to use when invoking 'executeMutation'.
  func makeExecuteMutationInterceptors() -> [ClientInterceptor<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>]
}

public enum Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata {
  public static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ConnectorService",
    fullName: "google.firebase.dataconnect.v1alpha.ConnectorService",
    methods: [
      Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeQuery,
      Google_Firebase_Dataconnect_V1alpha_ConnectorServiceClientMetadata.Methods.executeMutation,
    ]
  )

  public enum Methods {
    public static let executeQuery = GRPCMethodDescriptor(
      name: "ExecuteQuery",
      path: "/google.firebase.dataconnect.v1alpha.ConnectorService/ExecuteQuery",
      type: GRPCCallType.unary
    )

    public static let executeMutation = GRPCMethodDescriptor(
      name: "ExecuteMutation",
      path: "/google.firebase.dataconnect.v1alpha.ConnectorService/ExecuteMutation",
      type: GRPCCallType.unary
    )
  }
}

/// Firebase Data Connect provides means to deploy a set of predefined GraphQL
/// operations (queries and mutations) as a Connector.
///
/// Firebase developers can build mobile and web apps that uses Connectors
/// to access Data Sources directly. Connectors allow operations without
/// admin credentials and help Firebase customers control the API exposure.
///
/// Note: `ConnectorService` doesn't check IAM permissions and instead developers
/// must define auth policies on each pre-defined operation to secure this
/// connector. The auth policies typically define rules on the Firebase Auth
/// token.
///
/// To build a server, implement a class that conforms to this protocol.
public protocol Google_Firebase_Dataconnect_V1alpha_ConnectorServiceProvider: CallHandlerProvider {
  var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerInterceptorFactoryProtocol? { get }

  /// Execute a predefined query in a Connector.
  func executeQuery(request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>

  /// Execute a predefined mutation in a Connector.
  func executeMutation(request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, context: StatusOnlyCallContext) -> EventLoopFuture<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>
}

extension Google_Firebase_Dataconnect_V1alpha_ConnectorServiceProvider {
  public var serviceName: Substring {
    return Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  /// Determines, calls and returns the appropriate request handler, depending on the request's method.
  /// Returns nil for methods not handled by this service.
  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "ExecuteQuery":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest>(),
        responseSerializer: ProtobufSerializer<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>(),
        interceptors: self.interceptors?.makeExecuteQueryInterceptors() ?? [],
        userFunction: self.executeQuery(request:context:)
      )

    case "ExecuteMutation":
      return UnaryServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest>(),
        responseSerializer: ProtobufSerializer<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>(),
        interceptors: self.interceptors?.makeExecuteMutationInterceptors() ?? [],
        userFunction: self.executeMutation(request:context:)
      )

    default:
      return nil
    }
  }
}

#if compiler(>=5.6)

/// Firebase Data Connect provides means to deploy a set of predefined GraphQL
/// operations (queries and mutations) as a Connector.
///
/// Firebase developers can build mobile and web apps that uses Connectors
/// to access Data Sources directly. Connectors allow operations without
/// admin credentials and help Firebase customers control the API exposure.
///
/// Note: `ConnectorService` doesn't check IAM permissions and instead developers
/// must define auth policies on each pre-defined operation to secure this
/// connector. The auth policies typically define rules on the Firebase Auth
/// token.
///
/// To implement a server, implement an object which conforms to this protocol.
@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
public protocol Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncProvider: CallHandlerProvider {
  static var serviceDescriptor: GRPCServiceDescriptor { get }
  var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerInterceptorFactoryProtocol? { get }

  /// Execute a predefined query in a Connector.
  @Sendable func executeQuery(
    request: Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse

  /// Execute a predefined mutation in a Connector.
  @Sendable func executeMutation(
    request: Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest,
    context: GRPCAsyncServerCallContext
  ) async throws -> Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse
}

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
extension Google_Firebase_Dataconnect_V1alpha_ConnectorServiceAsyncProvider {
  public static var serviceDescriptor: GRPCServiceDescriptor {
    return Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerMetadata.serviceDescriptor
  }

  public var serviceName: Substring {
    return Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerMetadata.serviceDescriptor.fullName[...]
  }

  public var interceptors: Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerInterceptorFactoryProtocol? {
    return nil
  }

  public func handle(
    method name: Substring,
    context: CallHandlerContext
  ) -> GRPCServerHandlerProtocol? {
    switch name {
    case "ExecuteQuery":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest>(),
        responseSerializer: ProtobufSerializer<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>(),
        interceptors: self.interceptors?.makeExecuteQueryInterceptors() ?? [],
        wrapping: self.executeQuery(request:context:)
      )

    case "ExecuteMutation":
      return GRPCAsyncServerHandler(
        context: context,
        requestDeserializer: ProtobufDeserializer<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest>(),
        responseSerializer: ProtobufSerializer<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>(),
        interceptors: self.interceptors?.makeExecuteMutationInterceptors() ?? [],
        wrapping: self.executeMutation(request:context:)
      )

    default:
      return nil
    }
  }
}

#endif // compiler(>=5.6)

public protocol Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerInterceptorFactoryProtocol {

  /// - Returns: Interceptors to use when handling 'executeQuery'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeExecuteQueryInterceptors() -> [ServerInterceptor<Google_Firebase_Dataconnect_V1alpha_ExecuteQueryRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteQueryResponse>]

  /// - Returns: Interceptors to use when handling 'executeMutation'.
  ///   Defaults to calling `self.makeInterceptors()`.
  func makeExecuteMutationInterceptors() -> [ServerInterceptor<Google_Firebase_Dataconnect_V1alpha_ExecuteMutationRequest, Google_Firebase_Dataconnect_V1alpha_ExecuteMutationResponse>]
}

public enum Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerMetadata {
  public static let serviceDescriptor = GRPCServiceDescriptor(
    name: "ConnectorService",
    fullName: "google.firebase.dataconnect.v1alpha.ConnectorService",
    methods: [
      Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerMetadata.Methods.executeQuery,
      Google_Firebase_Dataconnect_V1alpha_ConnectorServiceServerMetadata.Methods.executeMutation,
    ]
  )

  public enum Methods {
    public static let executeQuery = GRPCMethodDescriptor(
      name: "ExecuteQuery",
      path: "/google.firebase.dataconnect.v1alpha.ConnectorService/ExecuteQuery",
      type: GRPCCallType.unary
    )

    public static let executeMutation = GRPCMethodDescriptor(
      name: "ExecuteMutation",
      path: "/google.firebase.dataconnect.v1alpha.ConnectorService/ExecuteMutation",
      type: GRPCCallType.unary
    )
  }
}
