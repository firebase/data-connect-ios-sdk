//
//  DetailsSection.swift
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

import SwiftUI

struct DetailsSection<Details: View>: View {
  var title: String
  var content: () -> Details

  init(title: String, @ViewBuilder content: @escaping () -> Details) {
    self.title = title
    self.content = content
  }

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      HStack(alignment: .center) {
        Text(title)
          .font(.title2)
          .bold()
        Image(systemName: "chevron.right")
          .font(.title2)
          .bold()
      }
      .padding(.bottom, 8)

      content()
    }
    .padding(.bottom, 20)
  }
}

#Preview {
  ScrollView {
    DetailsSection(title: "Details Section") {
      Text("Content goes here")
    }
    .padding()
  }
}

#Preview {
  ScrollView {
    DetailsSection(title: "Ratings & Reviews") {
      HStack(alignment: .center) {
        Text("4.7")
          .font(.system(size: 64, weight: .bold))
        Spacer()
        VStack(alignment: .trailing) {
          StarRatingView(rating: 4.7)
          Text("23 Ratings")
            .font(.title)
            .bold()
        }
      }
      Text("Most Helpful Reviews")
        .font(.title3)
        .bold()
      ScrollView(.horizontal) {
        LazyHStack {
          ForEach(0 ..< 10) { i in
            MovieReviewCard(
              title: "Great stuff",
              rating: 4.5,
              reviewerName: "John Doe",
              review:
              "Incididunt reprehenderit ad elit et commodo. Sint magna Lorem eiusmod. Ea ut culpa cupidatat Lorem culpa ad cupidatat excepteur voluptate consectetur nostrud eu laborum."
            )
            .frame(width: 350)
          }
        }
        .scrollTargetLayout()
      }
      .scrollTargetBehavior(.viewAligned)
    }
  }
}
