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
import FirebaseCore

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
class DataConnectLogger {
  private static let logger = Logger(
    subsystem: "com.google.firebase",
    category: "[FirebaseDataConnect]"
  )

  private static let logPrefix = "\(Version.sdkVersion) - [FirebaseDataConnect]"
  
  static let logLevel = FirebaseConfiguration.shared.loggerLevel()
  
  static func error(_ message: String, code: MessageCode = .placeHolder) {
    if logLevel.rawValue <= FirebaseLoggerLevel.debug.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.error("\(logPrefix)[\(messageCode)] \(message)")
    }
  }
  
  static func warning(_ message: String, code: MessageCode = .placeHolder) {
    if logLevel.rawValue <= FirebaseLoggerLevel.warning.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.warning("\(logPrefix)[\(messageCode)] \(message)")
    }
  }
  
  static func notice(_ message: String, code: MessageCode = .placeHolder) {
    if logLevel.rawValue <= FirebaseLoggerLevel.notice.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.notice("\(logPrefix)[\(messageCode)] \(message)")
    }
  }
  
  static func info(_ message: String, code: MessageCode = .placeHolder) {
    if logLevel.rawValue <= FirebaseLoggerLevel.info.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.info("\(logPrefix)[\(messageCode)] \(message)")
    }
  }
  
  static func debug(_ message: String, code: MessageCode = .placeHolder) {
    if logLevel.rawValue <= FirebaseLoggerLevel.debug.rawValue {
      let messageCode = String(format: "I-FDC%06d", code.rawValue)
      logger.debug("\(logPrefix)[\(messageCode)] \(message)")
    }
  }
}

enum LogPrivacy: Int {
  case `public` = 0

  case `private` = 1
}

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
extension DefaultStringInterpolation {
  mutating func appendInterpolation(_ value: String, privacy: LogPrivacy = .public) {
    if privacy == .private, DataConnect.ArgumentFlag.enablePrivacyLogging {
      appendLiteral(" <private>")
    } else {
      appendLiteral(value)
    }
  }
}
