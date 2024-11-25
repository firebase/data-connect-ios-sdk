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

import SwiftUI

extension Color {
  init(hex: String, opacity: Double = 1.0) {
    var hexFormatted: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
      .uppercased()

    if hexFormatted.hasPrefix("#") {
      hexFormatted = String(hexFormatted.dropFirst())
    }

    assert(hexFormatted.count == 6 || hexFormatted.count == 8, "Invalid hex code")

    var rgbValue: UInt64 = 0
    Scanner(string: hexFormatted).scanHexInt64(&rgbValue)

    var alpha: Double = opacity
    if hexFormatted.count == 8 {
      alpha = Double((rgbValue & 0xFF00_0000) >> 24) / 255.0
    }

    let red = Double((rgbValue & 0x00FF_0000) >> 16) / 255.0
    let green = Double((rgbValue & 0x0000_FF00) >> 8) / 255.0
    let blue = Double(rgbValue & 0x0000_00FF) / 255.0

    self
      .init(.sRGB, red: red, green: green, blue: blue,
            opacity: alpha) // Use alpha instead of opacity
  }
}
