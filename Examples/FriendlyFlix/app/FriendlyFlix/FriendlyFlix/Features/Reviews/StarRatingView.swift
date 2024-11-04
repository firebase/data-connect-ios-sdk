// Copyright © 2024 Google LLC. All rights reserved.
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

struct StarRatingView: View {
  var rating: Double

  var body: some View {
    HStack(spacing: 4) {
      ForEach(0..<5) { index in
        Image(systemName: self.starType(for: index))
          .foregroundColor(.yellow)
      }
    }
  }

  func starType(for index: Int) -> String {
    if rating > Double(index) + 0.75 {
      return "star.fill"
    } else if rating > Double(index) + 0.25 {
      return "star.lefthalf.fill"
    } else {
      return "star"
    }
  }
}
