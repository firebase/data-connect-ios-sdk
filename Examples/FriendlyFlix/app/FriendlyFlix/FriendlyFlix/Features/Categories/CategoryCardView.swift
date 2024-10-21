//
// CategoryCardView.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 15.10.24.
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

struct CategoryCardView<Hero: View, Title: View>: View {
  var background: () -> Hero
  var title: () -> Title

  public init(@ViewBuilder background: @escaping () -> Hero,
              @ViewBuilder title: @escaping () -> Title) {
    self.background = background
    self.title = title
  }


  var body: some View {
    VStack(spacing: 0) {
      ZStack(alignment: .topLeading) {
        background()
        title()
      }
      .clipShape(
        UnevenRoundedRectangle(
          cornerRadii: .init(
            topLeading: 16,
            bottomLeading: 16,
            bottomTrailing: 16,
            topTrailing: 16
          ),
          style: .continuous
        )
      )
    }
  }
}

#Preview {
  CategoryCardView {
    GradientView(configuration: .sample)
  } title: {
    VStack(alignment: .leading) {
      Spacer()
      Text("Science Fiction")
        .font(.title)
    }
    .foregroundColor(Color(UIColor.systemGroupedBackground))
    .padding()
  }
}

#Preview {
  let columns = [
    GridItem(.flexible(), spacing: 12),
    GridItem(.flexible()),
  ]
  NavigationStack {
    ScrollView {
      LazyVGrid(columns: columns, spacing: 12) {
        ForEach(0..<16) { index in
          CategoryCardView {
            GradientView(configuration: .samples[index % 3])
          } title: {
            VStack(alignment: .leading) {
              Spacer()
              Text("Free for Everyone")
                .font(.system(size: UIFontMetrics.default.scaledValue(for: 18), weight: .semibold))
            }
            .foregroundColor(Color(UIColor.systemGroupedBackground))
            .padding()
          }
          .frame(height: 100)
        }
      }
    }
    .padding(.horizontal, 16)
    .navigationTitle("Categories")
  }
}
