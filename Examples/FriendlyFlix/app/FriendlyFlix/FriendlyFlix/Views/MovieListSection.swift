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

struct SectionedMovie: Identifiable, Hashable {
  var id = UUID()
  var movie: Movie

  static func == (lhs: SectionedMovie, rhs: SectionedMovie) -> Bool {
    lhs.id == rhs.id && lhs.movie.id == rhs.movie.id // Assuming MovieRepresentable has an id
  }

  func hash(into hasher: inout Hasher) {
    hasher.combine(id)
  }
}

struct MovieListSection: View {
  // pass namespace from parent view, see https://forums.developer.apple.com/forums/thread/651996
  var namespace: Namespace.ID
  var title: String
  var movies: [Movie]

  private var sectionedMovies: [SectionedMovie] {
    movies.map { movie in
      SectionedMovie(movie: movie)
    }
  }

  var body: some View {
    DetailsSection {
      NavigationLink(value: movies) {
        Text(title)
      }
      .buttonStyle(.noHighlight)
    } content: {
      ScrollView(.horizontal) {
        LazyHStack {
          ForEach(sectionedMovies) { sectionedMovie in
            NavigationLink(value: sectionedMovie) {
              MovieTileView(
                title: sectionedMovie.movie.title,
                imageUrl: sectionedMovie.movie.imageUrl,
                averageRating: sectionedMovie.movie.rating ?? 0,
                userRating: 10
              )
              .frame(maxWidth: 150, maxHeight: 300)
              .matchedTransitionSource(id: sectionedMovie.id, in: namespace)
            }
            .buttonStyle(.noHighlight)
          }
        }
      }
      .scrollIndicators(.never)
    }
  }
}

#Preview {
  @Previewable @Namespace var namespace
  NavigationStack {
    MovieListSection(namespace: namespace, title: "Top Movies", movies: Movie.topMovies)
  }
}
