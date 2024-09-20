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

@available(macOS 10.15, iOS 13, tvOS 13, watchOS 6, *)
struct Version {
  static let sdkVersion = "11.3.0-beta"

  // returns value of form gl-PLATFORM_NAME/PLATFORM_VERSION
  static func platformVersionHeader() -> String {
    let version = ProcessInfo.processInfo.operatingSystemVersion
    let versionString = "\(version.majorVersion).\(version.minorVersion).\(version.patchVersion)"
    #if os(iOS)
      return "gl-ios/\(versionString)"
    #elseif os(watchOS)
      return "gl-watchos/\(versionString)"
    #elseif os(tvOS)
      return "gl-tvos/\(versionString)"
    #elseif os(macOS)
      return "gl-macos/\(versionString)"
    #else
      return ""
    #endif
  }

  // returns the build time major version of swift
  static func swiftMajorVersion() -> String {
    #if swift(>=6)
      return "6"
    #elseif swift(>=5)
      return "5"
    #elseif swift(>=4)
      return "4"
    #elseif swift(>=3)
      return "3"
    #elseif swift(>=2)
      return "2"
    #elseif swift(>=1)
      return "1"
    #else
      return ""
    #endif
  }
}
