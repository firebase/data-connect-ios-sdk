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

import OSLog

class DataConnectLogger {
  private static let logger = Logger(
    subsystem: "com.google.firebase",
    category: "[FirebaseDataConnect]"
  )

  private static let logPrefix = "\(Version.sdkVersion) - [FirebaseDataConnect]"

  static func debug(_ message: String, code: MessageCode = .placeHolder) {
    if DataConnect.logLevel.rawValue <= LogLevel.DEBUG.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.debug("\(logPrefix)[\(messageCode)] \(message)")
    }
  }

  static func warning(_ message: String, code: MessageCode = .placeHolder) {
    if DataConnect.logLevel.rawValue <= LogLevel.WARN.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.warning("\(logPrefix)[\(messageCode)] \(message)")
    }
  }

  static func error(_ message: String, code: MessageCode = .placeHolder) {
    if DataConnect.logLevel.rawValue <= LogLevel.WARN.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.error("\(logPrefix)[\(messageCode)] \(message)")
    }
  }
}

enum LogPrivacy: Int {
  case `public` = 0

  case `private` = 1
}

extension DefaultStringInterpolation {
  mutating func appendInterpolation(_ value: String, privacy: LogPrivacy = .public) {
    switch privacy {
    case .private:
      appendLiteral("<private>")
    default:
      appendLiteral(value)
    }
  }
}
