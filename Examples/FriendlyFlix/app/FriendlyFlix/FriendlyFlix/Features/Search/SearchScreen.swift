//
// SearchScreen.swift
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
import FirebaseDataConnect
import FriendlyFlixSDK

struct SearchedView: View {
  @Environment(\.isSearching) private var isSearching
  var namespace: Namespace.ID
  var filteredMovies = [Movie]()
  var connector = DataConnect.friendlyFlixConnector

  private var topMovies: [Movie] {
    connector.listMoviesQuery
      .ref({ optionalVars in
        optionalVars.limit = 5
        optionalVars.orderByRating = .DESC
      })
      .data?.movies.map(Movie.init) ?? []
  }

  var body: some View {
    if !isSearching {
      MovieListSection(namespace: namespace, title: "Top Movies", movies: topMovies)
      CategoriesView()
    } else {
      ForEach(filteredMovies) { movie in
        NavigationLink(value: movie) {
          MovieListRowView(
            title: movie.title,
            subtitle: movie.description,
            imageUrl: movie.imageUrl
          )
          .matchedTransitionSource(id: movie.id, in: namespace)
        }
        .buttonStyle(.noHighlight)
      }
    }
  }
}

struct SearchScreen: View {
  @State private var searchText: String = ""
  @State private var isStatusBarHidden = false
  @Namespace private var namespace

  var connector = DataConnect.friendlyFlixConnector

  private var filteredMovies: [Movie] {
    connector.listMoviesByPartialTitleQuery
      .ref(searchTerm: searchText)
      .data?.movies.map(Movie.init) ?? []
  }

}

extension SearchScreen {
  var body: some View {
    NavigationStack {
      ScrollView {
        SearchedView(namespace: namespace, filteredMovies: filteredMovies)
          .searchable(text: $searchText)
          .textInputAutocapitalization(.never)
      }
      .padding()
      .navigationTitle("Search")
      .navigationDestination(for: Movie.self) { movie in
        MovieCardView(showDetails: true, movie: movie)
          .navigationTransition(.zoom(sourceID: movie.id, in: namespace))
          .task {
            // NavigationStack requires `.statusBarHidden` to be applied to the navigationstack itself, not on any children.
            // See https://danielsaidi.com/blog/2023/03/14/handling-status-bar-color-scheme-and-visibility-in-swiftui
            isStatusBarHidden = true
          }
      }
      .navigationDestination(for: [Movie].self) { movies in
        MovieListScreen(namespace: namespace, movies: movies)
      }
      .navigationDestination(for: SectionedMovie.self) { sectionedMovie in
        MovieCardView(showDetails: true, movie: sectionedMovie.movie)
          .navigationTransition(.zoom(sourceID: sectionedMovie.id, in: namespace))
      }
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          AuthenticationToolbarButton()
        }
      }
    }
    .statusBarHidden(isStatusBarHidden)
  }
}

#Preview {
  SearchScreen()
    .environment(AuthenticationService())
}
