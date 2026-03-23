// Copyright 2026 Google LLC
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

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
enum OperationUtils {
  static func computeRequestId<Variable: OperationVariable>(operationName: String,
                                                            variables: Variable?) -> String {
    var keyIdData = Data()
    if let nameData = operationName.data(using: .utf8) {
      keyIdData.append(nameData)
    }

    if let variables {
      let encoder = JSONEncoder()
      encoder.outputFormatting = .sortedKeys
      do {
        let jsonData = try encoder.encode(variables)
        keyIdData.append(jsonData)
      } catch {
        DataConnectLogger
          .warning("Error encoding variables to compute request identifier: \(error)")
      }
    }

    return keyIdData.sha256String
  }
}
