//
//  MovieReviewCard.swift
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

struct MovieReviewCard: View {
  var title: String
  var rating: Double
  var reviewerName: String
  var review: String

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      Text(title)
        .font(.headline)
      HStack {
        StarRatingView(rating: rating)
        Text("·")
        Text(reviewerName)
        Spacer()
      }
      .font(.subheadline)
      Text(review)
      Spacer()
    }
    .padding(16)
    .frame(height: 200)
    .background(Color(UIColor.secondarySystemBackground))
    .clipShape(
      UnevenRoundedRectangle(
        cornerRadii: .init(
          topLeading: 16,
          bottomLeading: 16,
          bottomTrailing: 16,
          topTrailing: 16),
        style: .continuous))
  }
}

#Preview {
  ScrollView {
    MovieReviewCard(
      title: "Really great",
      rating: 4.5,
      reviewerName: "John Doe",
      review:
        "Velit officia quis ut ut dolor velit voluptate magna Lorem. Sint do ex adipisicing laboris magna et duis aute fugiat culpa minim id culpa nulla do. Occaecat in anim ad Lorem eu aute consectetur excepteur fugiat laboris eiusmod. Et tempor Lorem quis eu magna cillum adipisicing consectetur."
    )
    .padding()
  }
}
