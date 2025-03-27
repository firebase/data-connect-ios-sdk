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

import GoogleUtilities_Environment

@available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *)
struct Version {
  static let sdkVersion = "11.7.0"

  // returns value of form gl-PLATFORM_NAME/PLATFORM_VERSION
  static func platformVersionHeader() -> String {
    let versionString = GULAppEnvironmentUtil.systemVersion()
    let platformName = GULAppEnvironmentUtil.applePlatform()

    return "gl-\(platformName)/\(versionString)"
  }

  // returns the build time major version of swift
  static func swiftVersion() -> String {
    #if swift(>=6)
      return "6"
    #elseif swift(>=5.10)
      return "5.10"
    #elseif swift(>=5.9)
      return "5.9"
    #elseif swift(>=5.8)
      return "5.8"
    #elseif swift(>=5.7)
      return "5.7"
    #elseif swift(>=5.6)
      return "5.6"
    #elseif swift(>=5.5)
      return "5.5"
    #elseif swift(>=5.4)
      return "5.4"
    #elseif swift(>=5.2)
      return "5.2"
    #elseif swift(>=5.1)
      return "5.1"
    #elseif swift(>=5.0)
      return "5.0"
    #elseif swift(>=4.2)
      return "4.2"
    #elseif swift(>=4.1)
      return "4.1"
    #elseif swift(>=4.0)
      return "4.0"
    #elseif swift(>=3.1)
      return "3.1"
    #elseif swift(>=3.0)
      return "3.0"
    #elseif swift(>=2.2)
      return "2.2"
    #elseif swift(>=2.1)
      return "2.1"
    #elseif swift(>=2.0)
      return "2.0"
    #elseif swift(>=1.2)
      return "1.2"
    #elseif swift(>=1.1)
      return "1.1"
    #elseif swift(>=1.0)
      return "1.0"
    #else
      return ""
    #endif
  }
}
