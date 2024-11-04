//
// MovieListRowView.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 01.10.24.
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

struct MovieListRowView: View {
  var title: String
  var subtitle: String
  var imageUrl: String

  var body: some View {
    HStack(alignment: .top) {
      if let imageUrl = URL(string: imageUrl) {
        LazyImage(url: imageUrl) { state in
          if let image = state.image {
            image
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 150, height: 75)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
          } else if state.error != nil {
            Color.red
              .frame(width: 150, height: 75)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
              .redacted(if: true)
          } else {
            Image(systemName: "photo.artframe")
              .resizable()
              .aspectRatio(contentMode: .fill)
              .frame(width: 150, height: 75)
              .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
              .redacted(reason: .placeholder)
          }
        }
        .frame(width: 150, height: 75)
      }
      VStack(alignment: .leading, spacing: 4) {
        Text(title)
          .lineLimit(2)
          .font(.headline)
        Text(subtitle)
          .lineLimit(2)
          .font(.subheadline)
      }
      Spacer()
    }
    .contentShape(Rectangle()) // ensure entire frame is clickable
  }
}

#Preview {
  let movie = Movie.mock
  MovieListRowView(title: movie.title, subtitle: movie.description, imageUrl: movie.imageUrl)
}

#Preview {
  NavigationStack {
    List(Movie.mockList) { movie in
      MovieListRowView(title: movie.title, subtitle: movie.description, imageUrl: movie.imageUrl)
    }
    .listStyle(.plain)
    .navigationTitle("Movies")
  }
}
