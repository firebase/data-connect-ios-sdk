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

import Foundation

// MARK: Base Error Definitions

/// Protocol representing an error returned by the DataConnect service
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol DataConnectError: Error, CustomDebugStringConvertible, CustomStringConvertible {
  var message: String? { get }
  var cause: Error? { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension DataConnectError {
  var debugDescription: String {
    return "{\(Self.self), message: \(message ?? "nil"), cause: \(String(describing: cause))}"
  }

  var description: String {
    return debugDescription
  }
}

/// Type erased DataConnectError
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnyDataConnectError: DataConnectError {
  private let dataConnectError: DataConnectError

  init<E: DataConnectError>(dataConnectError: E) {
    self.dataConnectError = dataConnectError
  }

  public var message: String? {
    return dataConnectError.message
  }

  public var cause: (any Error)? {
    return dataConnectError.cause
  }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
/// Represents an error domain which can have more granular error codes
public protocol DataConnectDomainError: DataConnectError {
  associatedtype ErrorCode: DataConnectErrorCode

  var code: ErrorCode { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension DataConnectDomainError {
  var debugDescription: String {
    return "{\(Self.self), code: \(code), message: \(message ?? "nil"), cause: \(String(describing: cause))}"
  }

  var description: String {
    return debugDescription
  }
}

/// Error code within an error domain
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol DataConnectErrorCode: CustomStringConvertible, Equatable, Sendable, CaseIterable {}

// MARK: Data Connect Initialization Errors

/// Error initializing Data Connect
public struct DataConnectInitError: DataConnectDomainError {
  public struct Code: DataConnectErrorCode {
    private let code: String
    private init(_ code: String) { self.code = code }

    public static let appNotConfigured = Code("appNotConfigured")
    public static let grpcNotConfigured = Code("grpcNotConfigured")

    public static var allCases: [DataConnectInitError.Code] {
      return [appNotConfigured, grpcNotConfigured]
    }

    public var description: String { return code }
  }

  public let code: Code

  public let message: String?

  public let cause: Error?

  private init(code: Code, message: String? = nil, cause: Error? = nil) {
    self.code = code
    self.cause = cause
    self.message = message
  }

  static func appNotConfigured(message: String? = nil,
                               cause: Error? = nil) -> DataConnectInitError {
    return DataConnectInitError(code: .appNotConfigured, message: message, cause: cause)
  }

  static func grpcNotConfigured(message: String? = nil,
                                cause: Error? = nil) -> DataConnectInitError {
    return DataConnectInitError(code: .grpcNotConfigured, message: message, cause: cause)
  }
}

// MARK: Data Codec Errors

/// Data Encoding / Decoding Error
public struct DataConnectCodecError: DataConnectDomainError {
  public struct Code: DataConnectErrorCode {
    private let code: String

    private init(_ code: String) { self.code = code }

    public static let encodingFailed = Code("encodingFailed")
    public static let decodingFailed = Code("decodingFailed")
    public static let invalidUUID = Code("invalidUUID")
    public static let invalidTimestampFormat = Code("invalidTimestampFormat")
    public static let invalidLocalDateFormat = Code("invalidLocalDateFormat")

    public static var allCases: [DataConnectCodecError.Code] {
      return [
        encodingFailed,
        decodingFailed,
        invalidUUID,
        invalidTimestampFormat,
        invalidLocalDateFormat,
      ]
    }

    public var description: String { return code }
  }

  public let code: Code

  public let message: String?

  public let cause: (any Error)?

  private init(code: Code, message: String? = nil, cause: Error? = nil) {
    self.code = code
    self.message = message
    self.cause = cause
  }

  static func encodingFailed(message: String? = nil, cause: Error? = nil) -> DataConnectCodecError {
    return DataConnectCodecError(code: .encodingFailed, message: message, cause: cause)
  }

  static func decodingFailed(message: String? = nil, cause: Error? = nil) -> DataConnectCodecError {
    return DataConnectCodecError(code: .decodingFailed, message: message, cause: cause)
  }

  static func invalidUUID(message: String? = nil, cause: Error? = nil) -> DataConnectCodecError {
    return DataConnectCodecError(code: .invalidUUID, message: message, cause: cause)
  }

  static func invalidTimestampFormat(message: String? = nil,
                                     cause: Error? = nil) -> DataConnectCodecError {
    return DataConnectCodecError(code: .invalidTimestampFormat, message: message, cause: cause)
  }

  static func invalidLocalDateFormat(message: String? = nil,
                                     cause: Error? = nil) -> DataConnectCodecError {
    return DataConnectCodecError(code: .invalidLocalDateFormat, message: message, cause: cause)
  }
}

// MARK: Operation Execution Error including Partial Errors

/// Data Connect Operation Failed
public struct DataConnectOperationError: DataConnectError {
  public let message: String?
  public let cause: (any Error)?
  public let response: OperationFailureResponse?

  private init(message: String? = nil, cause: Error? = nil, response: OperationFailureResponse? = nil) {
    self.response = response
    self.cause = cause
    self.message = message
  }

  static func executionFailed(message: String? = nil, cause: Error? = nil,
                              response: OperationFailureResponse? = nil)
    -> DataConnectOperationError {
    return DataConnectOperationError(message: message, cause: cause, response: response)
  }
}

// The data and errors sent to us from the backend in its response.
// New struct, that contains the data and errors sent to us
// from the backend in its response.
public struct OperationFailureResponse: Sendable {
  // JSON string whose value is the "data" property provided by the backend in
  // its response payload; may be `nil` if the "data" property was not provided
  // in the backend response and/or was `null` in the backend response.
  public let rawJsonData: String?

  // The list of errors in the "error" property provided by the backend in
  // its response payload; may be empty if the "errors" property was not
  // provided in the backend response and/or was an empty list in the backend response.
  public let errors: [ErrorInfo]

  // (Partially) decoded data
  private let data: Sendable?

  // Returns `jsonData` string decoded into the given type, if decoding was
  // successful when the operation was executed. Returns `nil` if `jsonData`
  // is `nil`, if `jsonData` was _not_ able to be decoded when the operation
  // was executed, or if the given type is _not_ equal to the `Data` type that
  // was used when the operation was executed.
  //
  // This function does _not_ do the decoding itself, but simply returns
  // the decoded data, if any, that was decoded at the time of the
  // operation's execution.
  func data<Data: Decodable>(asType: Data.Type = Data.self) -> Data? {
    return data as? Data
  }

  init(rawJsonData: String? = nil,
       errors: [ErrorInfo],
       data: Sendable?) {
    self.rawJsonData = rawJsonData
    self.errors = errors
    self.data = data
  }

  public struct ErrorInfo: Codable, Sendable {
    // The error message.
    public let message: String
    // The path to the field to which this error applies.
    public let path: [DataConnectPathSegment]
  }
}
