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
import Combine
import XCTest

import FirebaseCore
@testable import FirebaseDataConnect

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
final class ErrorTypesTests: XCTestCase {

  private var pubCancellable: AnyCancellable?
  private let errPublisher = PassthroughSubject<Result<String, AnyDataConnectError>, Never>()

  func throwInitError() throws  {
    throw DataConnectInitError.appNotConfigured()
  }

  func testCatchAsGenericTypes() throws {
    do {
      try throwInitError()
    } catch let dcerr as DataConnectError {
      XCTAssertTrue(true)
    }
  }

  func testPublisherErrorType() throws {

    let errExpectation = XCTestExpectation(description: "Expect a Domain Erro")

    pubCancellable = errPublisher.sink( receiveValue: { result in
      switch result {
      case .success(_):
        XCTFail("Unexpectedly got success. We expect a failure with error")
      case let .failure(dcerror):
        if let initErr = dcerror.dataConnectError as? DataConnectInitError,
           initErr.code == .appNotConfigured
        {
          // got Init domain error
          errExpectation.fulfill()
        } else {
          XCTFail("Did not get DataConnectInitError.appNotConfigured as expected")
        }
      }
    })

    errPublisher
      .send(
        .failure(AnyDataConnectError(dataConnectError: DataConnectInitError.appNotConfigured()))
      )

    wait(for: [errExpectation], timeout: 1.0)
  }
}
