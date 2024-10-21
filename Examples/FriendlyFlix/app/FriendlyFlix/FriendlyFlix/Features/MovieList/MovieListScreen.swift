//
// MovieListView.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 30.09.24.
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

struct MovieListScreen: View {
  var namespace: Namespace.ID
  var movies: [Movie]

  var body: some View {
    List {
      ForEach(movies) { movie in
        MovieListRowView(
          title: movie.title,
          subtitle: movie.subtitle,
          imageUrl: movie.imageUrl
        )
        .matchedTransitionSource(id: movie.id, in: namespace)
        .navigationLink(value: movie, hideChevron: true)
      }

    }
    .listStyle(.plain)
  }
}

#Preview {
  @Previewable @Namespace var namespace
  NavigationStack {
    MovieListScreen(namespace: namespace, movies: Movie.mockList)
      .navigationTitle("Continue watching?")
      .navigationBarTitleDisplayMode(.inline)
  }
}
