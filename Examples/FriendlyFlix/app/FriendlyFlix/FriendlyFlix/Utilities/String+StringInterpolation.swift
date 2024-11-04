//
//  String+StringInterpolation.swift
//  FriendlyFlix
//
//  Created by Peter Friese on 28.08.24.
//  Copyright © 2024 Google LLC. All rights reserved.
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

extension String.StringInterpolation {
  mutating func appendInterpolation(format value: Int, using style: NumberFormatter.Style) {
    let formatter = NumberFormatter()
    formatter.numberStyle = style

    if let result = formatter.string(from: value as NSNumber) {
      appendLiteral(result)
    }
  }
}