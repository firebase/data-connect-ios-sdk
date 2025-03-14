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

/// Represents an error returned by the DataConnect service
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public enum DataConnectError: Error {
  /// no firebase app specified. configure not complete
  case appNotConfigured

  /// failed to configure gRPC
  case grpcNotConfigured

  /// Invalid uuid format during encoding / decoding of data
  case invalidUUID

  /// date components specified to initialize LocalDate are invalid
  case invalidLocalDateFormat

  /// timestamp components specified to initialize Timestamp are invalid
  case invalidTimestampFormat

  /// generic operation execution error
  case operationExecutionFailed(messages: String?, response: OperationFailureResponse)
}

// The data and errors sent to us from the backend in its response.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol OperationFailureResponse {
  // JSON string whose value is the "data" property provided by the backend in its response
  // payload; may be `nil` if the "data" property was not provided in the backend response and/or
  // was `null` in the backend response.
  var jsonData: String? { get }

  // The list of errors in the "error" property provided by the backend in its response payload;
  // may be empty if the "errors" property was not provided in the backend response and/or was an
  // empty list in the backend response.
  var errorInfoList: [OperationFailureResponseErrorInfo] { get }

  // Returns `jsonData` string decoded into the given type, if decoding was successful when the
  // operation was executed. Returns `nil` if `jsonData` is `nil`, if `jsonData` was _not_ able to
  // be decoded when the operation was executed, or if the given type is _not_ equal to the `Data`
  // type that was used when the operation was executed.
  //
  // This function does _not_ do the decoding itself, but simply returns the decoded data, if any,
  // that was decoded at the time of the operation's execution.
  func decodedData<Data: Decodable>(asType: Data.Type) -> Data?
}

struct OperationFailureResponseImpl : OperationFailureResponse {
  public let jsonData: String?

  public let errorInfoList: [OperationFailureResponseErrorInfo]

  func decodedData<Data: Decodable>(asType: Data.Type = Data.self) -> Data? {
    return nil;
  }
}

// Information about an error provided by the backend in its response.
@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct OperationFailureResponseErrorInfo: Codable {
  // The error message.
  public let message: String

  // The path to the field to which this error applies.
  public let path: [PathSegment]

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public enum PathSegment: Codable, Equatable {
    case field(String)
    case listIndex(Int)
  }
}

