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

extension View {
  @ViewBuilder
  func redacted(if condition: @autoclosure () -> Bool) -> some View {
    redacted(reason: condition() ? .placeholder : [])
  }
}

extension View {
  @ViewBuilder
  func navigationLink(value: any Hashable, hideChevron: Bool = false) -> some View {
    if hideChevron {
      // If hideChevron is true, apply the overlay trick to hide the chevron
      // Put the NavigationLink into an overlay, and set its opacity to zero. By using this trick,
      // we can hide the chevron.
      // Source: https://www.reddit.com/r/SwiftUI/comments/13rhg02/how_can_i_use_navigationlink_inside_list_without/jlkqbkz/
      overlay {
        NavigationLink(value: value) {
          EmptyView()
        }
        .opacity(0)
      }
    } else {
      // If hideChevron is false, return the original view without modification
      self
    }
  }
}
