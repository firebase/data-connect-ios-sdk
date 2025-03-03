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

  /// failed to decode results from server
  case decodeFailed(response: AnyOperationFailureResponse)

  /// Invalid uuid format during encoding / decoding of data
  case invalidUUID

  /// date components specified to initialize LocalDate are invalid
  case invalidLocalDateFormat

  /// timestamp components specified to initialize Timestamp are invalid
  case invalidTimestampFormat

  /// generic operation execution error
  case operationExecutionFailed(response: AnyOperationFailureResponse)
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public protocol AnyOperationFailureResponse {
  // JSON string
  var data: String? { get }

  var errors: [OperationFailureResponse.ErrorInfo] { get }
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
public struct OperationFailureResponse<T> : AnyOperationFailureResponse {
  // JSON string
  public let data: String?

  public let errors: [ErrorInfo]

  public let decodedData: T?

  @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
  public struct ErrorInfo: Codable {
    public let message: String
    public let path: [PathSegment]

    @available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
    public enum PathSegment: Codable {
      case field(String)
      case listIndex(Int)
    }

  }
}
