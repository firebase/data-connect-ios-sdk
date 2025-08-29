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

// MARK: - Base Error Definitions

/// A type representing an error returned by the DataConnect service
///
/// - SeeAlso: ``DataConnectError`` for the base error type.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol DataConnectError: Error, CustomDebugStringConvertible, CustomStringConvertible {
  var message: String? { get }
  var underlyingError: Error? { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension DataConnectError {
  var debugDescription: String {
    return "{\(Self.self), message: \(message ?? "nil"), underlyingError: \(String(describing: underlyingError))}"
  }

  var description: String {
    return debugDescription
  }
}

/// A structure representing a type-erased ``DataConnectError``.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct AnyDataConnectError: Error {
  /// Contained ``DataConnectError``
  public let dataConnectError: DataConnectError

  init<E: DataConnectError>(dataConnectError: E) {
    self.dataConnectError = dataConnectError
  }
}

/// A type that represents an error domain with granular error codes.
/// - SeeAlso: ``DataConnectError`` for the base error type.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol DataConnectDomainError: DataConnectError {
  associatedtype ErrorCode: DataConnectErrorCode
  var code: ErrorCode { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public extension DataConnectDomainError {
  var debugDescription: String {
    return "{\(Self.self), code: \(code), message: \(message ?? "nil"), underlyingError: \(String(describing: underlyingError))}"
  }

  var description: String {
    return debugDescription
  }
}

/// A type that represents an error code within an error domain.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol DataConnectErrorCode: CustomStringConvertible, Equatable, Sendable, CaseIterable {} 

// MARK: - Data Connect Initialization Errors

/// An error that occurs during the initialization of the Data Connect service.
///
/// This error can arise due to various reasons, such as missing configurations or
/// issues with the underlying gRPC setup. It provides specific error codes
/// to pinpoint the cause of the initialization failure.
///
/// - SeeAlso: ``DataConnectDomainError`` for the base error type.
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

  public let underlyingError: Error?

  private init(code: Code, message: String? = nil, cause: Error? = nil) {
    self.code = code
    underlyingError = cause
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

// MARK: - Data Codec Errors

/// An error that occurs during the encoding or decoding of data within the Data Connect service.
///
/// This error can arise due to various reasons, such as invalid data formats,
/// incorrect UUIDs, or issues with timestamp/date formats. It provides specific error codes
/// to pinpoint the cause of the encoding/decoding failure.
///
/// - SeeAlso: ``DataConnectDomainError`` for the base error type.
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

  public let underlyingError: (any Error)?

  private init(code: Code, message: String? = nil, cause: Error? = nil) {
    self.code = code
    self.message = message
    underlyingError = cause
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

// MARK: - Operation Execution Error including Partial Errors

/// An error that occurs during the execution of a Data Connect operation.
///
/// This error can arise due to various reasons, such as network issues, server-side errors,
/// or problems with the operation itself. It may include an optional underlying error,
/// a message describing the failure, and an optional response from the failed operation.
///
/// When available, the ``response`` will contain more error information and any partially decoded
/// result
///
/// - SeeAlso: `DataConnectError` for the base error type.
///

public struct DataConnectOperationError: DataConnectError {
  public let message: String?
  public let underlyingError: (any Error)?
  public let response: OperationFailureResponse?

  private init(message: String? = nil, cause: Error? = nil,
               response: OperationFailureResponse? = nil) {
    self.response = response
    underlyingError = cause
    self.message = message
  }

  static func executionFailed(message: String? = nil, cause: Error? = nil,
                              response: OperationFailureResponse? = nil)
    -> DataConnectOperationError {
    return DataConnectOperationError(message: message, cause: cause, response: response)
  }

  // include the underlying errors from errorInfo list in the description
  public var debugDescription: String {
    let errorInfos = response?.errors.compactMap {
      $0.message
    }.joined(separator: "\n")

    return "{\(Self.self), \nerrors: \(errorInfos) \noriginatingError: \(String(describing: underlyingError))}"
  }
}

/// Contains the data and errors sent to us from the backend in its response.
/// The ``OperationFailureResponse`` if present, is available as part of the
/// ``DataConnectOperationError``
public struct OperationFailureResponse: Sendable {
  /// JSON string whose value is the "data" property provided by the backend in
  /// its response payload; may be `nil` if the "data" property was not provided
  /// in the backend response and/or was `null` in the backend response.
  public let rawJsonData: String?

  /// The list of errors in the "error" property provided by the backend in
  /// its response payload; may be empty if the "errors" property was not
  /// provided in the backend response and/or was an empty list in the backend response.
  public let errors: [ErrorInfo]

  // (Partially) decoded data
  private let data: Sendable?

  /// Returns `rawJsonData` string decoded into the given type, if decoding was
  /// successful when the operation was executed.
  ///
  /// - Parameter asType: The type to decode the `rawJsonData` into (defaults to the inferred
  /// generic parameter).
  /// - Returns: The decoded data of type `Data` (generic parameter), if decoding to the
  /// generic parameter was successful when the operation was executed, `nil` otherwise.
  public func data<Data: Decodable>(asType: Data.Type = Data.self) -> Data? {
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
    /// The error message (if available)
    public let message: String
    /// The path to the field to which this error applies.
    public let path: [DataConnectPathSegment]
  }
}

// MARK: - Internal Errors

public struct DataConnectInternalError: DataConnectDomainError {
  public struct Code: DataConnectErrorCode {
    private let code: String
    private init(_ code: String) { self.code = code }

    public static let internalError = Code("internalError")
    public static let sqliteError = Code("sqliteError")

    public static var allCases: [DataConnectInternalError.Code] {
      return [internalError, sqliteError]
    }

    public var description: String { return code }
  }

  public let code: Code
  public let message: String?
  public let underlyingError: Error?

  private init(code: Code, message: String? = nil, cause: Error? = nil) {
    self.code = code
    self.message = message
    underlyingError = cause
  }

  static func internalError(message: String? = nil,
                               cause: Error? = nil) -> DataConnectInternalError {
    return DataConnectInternalError(code: .internalError, message: message, cause: cause)
  }

  static func sqliteError(message: String? = nil,
                               cause: Error? = nil) -> DataConnectInternalError {
    return DataConnectInternalError(code: .sqliteError, message: message, cause: cause)
  }
}
