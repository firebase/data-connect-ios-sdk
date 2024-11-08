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

import NukeUI
import SwiftUI

struct MovieTileView: View {
  var title: String = "The Matrix"
  var imageUrl: String
  var averageRating: Double = 5.7
  var userRating: Double = 9

  let gradient = LinearGradient(
    colors: [.blue, .green],
    startPoint: .leading,
    endPoint: .trailing
  )

  private let star = Image(systemName: "star.fill")

  var body: some View {
    VStack(alignment: .leading) {
      if let imageUrl = URL(string: imageUrl) {
        LazyImage(url: imageUrl) { state in
          if let image = state.image {
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 150, height: 200)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          } else if state.error != nil {
            Color.red
              .frame(width: 150, height: 200)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
              .redacted(if: true)
          } else {
            Image(systemName: "photo.artframe")
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 150, height: 200)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
              .redacted(reason: .placeholder)
          }
        }
        .frame(width: 150, height: 200)
      }
      Text(title)
        .lineLimit(1)
        .font(.headline)
      HStack {
        Text(star)
          .foregroundColor(.yellow) + Text(" ") + Text("\(averageRating, specifier: "%.1f")") +
          Text(" ") + Text(star)
          .foregroundColor(.blue) + Text(" ") + Text("\(userRating, specifier: "%.1f")")
      }
    }
  }
}

#Preview {
  ScrollView(.horizontal) {
    LazyHStack {
      ForEach(Movie.featured) { movie in
        MovieTileView(title: movie.title,
                      imageUrl: movie.imageUrl,
                      averageRating: 8,
                      userRating: 10)
          .frame(width: 200, height: 300)
      }
    }
  }
}
