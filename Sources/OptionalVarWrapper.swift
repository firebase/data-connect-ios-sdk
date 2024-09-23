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

@available(iOS 15.0, macOS 11.0, tvOS 15.0, watchOS 8.0, *)
@propertyWrapper
public struct OptionalVariable<Value> where Value: Encodable {
  public private(set) var isSet = false

  public var wrappedValue: Value? {
    didSet {
      isSet = true
    }
  }

  // init called when var isn't initialized
  // it is important to define this otherwise the var gets initialized with nil value

  public init() {
    wrappedValue = nil
    isSet = false
  }

  // init called with explicit initialization either with nil or value
  public init(wrappedValue initialValue: Value?) {
    wrappedValue = initialValue
    isSet = true
  }

  public var projectedValue: Self {
    return self
  }
}

@available(iOS 15.0, macOS 11.0, tvOS 15.0, watchOS 8.0, *)
extension OptionalVariable: Encodable {
  public func encode(to encoder: Encoder) throws {
    if isSet {
      var container = encoder.singleValueContainer()
      try container.encode(wrappedValue)
    }
  }
}
