//
// MovieTeaserView.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 28.09.24.
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

struct MovieTeaserView: View {
  var title: String
  var subtitle: String
  var imageUrl: String

  var body: some View {
    ZStack(alignment: .bottom) {
      if let imageUrl = URL(string: imageUrl) {
        AsyncImage(url: imageUrl) { phase in
          if let image = phase.image {
            image
              .resizable()
              .scaledToFill()
          } else if phase.error != nil {
            Color.red
              .redacted(if: true)
          } else {
            Image(systemName: "photo.artframe")
              .resizable()
              .scaledToFill()
              .redacted(reason: .placeholder)
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
    subtitle: movie.subtitle,
    imageUrl: movie.imageUrl
  )
}
