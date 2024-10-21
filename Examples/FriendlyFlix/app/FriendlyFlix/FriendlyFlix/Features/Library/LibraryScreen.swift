//
// ProfileScreen.swift
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

struct LibraryScreen: View {
  @Namespace var namespace
  @Environment(AuthenticationService.self) var authenticationViewModel

  var body: some View {
    @Bindable var authenticationViewModel = authenticationViewModel
    NavigationStack {
      ScrollView {
        if authenticationViewModel.authenticationState == .authenticated {
          Group {
            MovieListSection(namespace: namespace, title: "Watch List", movies: Movie.watchList)
            MovieListSection(namespace: namespace, title: "Favourites", movies: Movie.featured)
          }
          .padding()
        }
      }
      .navigationTitle("Library")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          AuthenticationToolbarButton()
        }
      }
      .navigationDestination(for: Movie.self) { movie in
        MovieCardView(showDetails: true, movie: movie)
          .navigationTransition(.zoom(sourceID: movie.id, in: namespace))
      }
      .navigationDestination(for: [Movie].self) { movies in
        MovieListScreen(namespace: namespace, movies: movies)
      }
      .navigationDestination(for: SectionedMovie.self) { sectionedMovie in
        MovieCardView(showDetails: true, movie: sectionedMovie.movie)
          .navigationTransition(.zoom(sourceID: sectionedMovie.id, in: namespace))
      }
    }
    .overlay {
      if authenticationViewModel.authenticationState == .unauthenticated {
        ContentUnavailableView {
          Label("Your library is empty", systemImage: "rectangle.on.rectangle.slash")
        } description: {
          Text("Your watch list and favourites will appear here.")
        }
      }
    }
  }
}

#Preview {
  LibraryScreen()
    .environment(AuthenticationService())
}
