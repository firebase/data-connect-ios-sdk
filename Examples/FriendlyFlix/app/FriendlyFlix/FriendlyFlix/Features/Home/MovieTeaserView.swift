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

struct MovieTeaserView: View {
  var title: String
  var subtitle: String
  var imageUrl: String

  var body: some View {
    ZStack(alignment: .bottom) {
      GeometryReader { geometry in
        if let imageUrl = URL(string: imageUrl) {
          LazyImage(url: imageUrl) { state in
            if let image = state.image {
              image
                .resizable()
                .scaledToFill()
                .frame(width: geometry.size.width)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            } else if state.error != nil {
              Color.red
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .redacted(if: true)
            } else {
              Image(systemName: "photo.artframe")
                .resizable()
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                .redacted(reason: .placeholder)
            }
          }
        }
      }
      VStack {
        Text(title)
          .font(.largeTitle)
          .foregroundStyle(.white)
        Text(subtitle)
          .font(.body)
          .foregroundStyle(.white)
      }
      .padding(.horizontal)
      .padding(.vertical, 60)
      .background {
        LinearGradient(
          gradient: Gradient(colors: [.clear, .black.opacity(0.9)]),
          startPoint: .top,
          endPoint: .bottom
        )
      }
    }
  }
}

#Preview {
  var movie = Movie.mock
  MovieTeaserView(
    title: movie.title,
    subtitle: movie.description,
    imageUrl: movie.imageUrl
  )
  .frame(maxHeight: 400)
}
