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

import FirebaseDataConnect
import FriendlyFlixSDK
import SwiftUI

struct HomeScreen: View {
  @Namespace private var namespace
  @Environment(AuthenticationService.self) var authenticationService

  private var connector = DataConnect.friendlyFlixConnector

  private var isSignedIn: Bool {
    authenticationService.user != nil
  }

  private func mapMovie(_ listMovie: ListMoviesQuery.Data.Movie) -> Movie {
    .init(
      title: listMovie.title,
      description: listMovie.description ?? "",
      releaseYear: listMovie.releaseYear,
      rating: listMovie.rating,
      imageUrl: listMovie.imageUrl
    )
  }

  let heroMoviesRef: QueryRefObservation<ListMoviesQuery.Data, ListMoviesQuery.Variables>
  private var heroMovies: [Movie] {
    heroMoviesRef
      .data?.movies.map(Movie.init) ?? []
  }

  let topMoviesRef: QueryRefObservation<ListMoviesQuery.Data, ListMoviesQuery.Variables>
  private var topMovies: [Movie] {
    topMoviesRef.data?.movies.map(Movie.init) ?? []
  }

  let watchListRef:
    QueryRefObservation<
      GetUserFavoriteMoviesQuery.Data,
      GetUserFavoriteMoviesQuery.Variables
    >
  private var watchList: [Movie] {
    watchListRef.data?.user?.favoriteMovies.map(Movie.init) ?? []
  }

  private var isEmpty: Bool {
    heroMovies.count == 0
  }

  private func refresh() async {
    async let _ = heroMoviesRef.execute()
    async let _ = topMoviesRef.execute()
    async let _ = watchListRef.execute()
  }

  init() {
    heroMoviesRef = connector.listMoviesQuery
      .ref { optionalVars in
        optionalVars.limit = 3
        optionalVars.orderByReleaseYear = .DESC
      }
    topMoviesRef = connector.listMoviesQuery
      .ref { optionalVars in
        optionalVars.limit = 5
        optionalVars.orderByRating = .DESC
      }
    watchListRef = connector.getUserFavoriteMoviesQuery.ref()
  }
}

extension HomeScreen {
  var body: some View {
    NavigationStack {
      ScrollView {
        if isEmpty {
          GeometryReader { geometry in
            ContentUnavailableView {
              Label("No movies available", systemImage: "rectangle.on.rectangle.slash")
            } description: {
              VStack {
                Text("Follow the instructions in the README.md file to get started.")
              }
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
          }
          .frame(height: UIScreen.main.bounds.height)
        } else {
          TabView {
            ForEach(heroMovies) { movie in
              NavigationLink(value: movie) {
                MovieTeaserView(
                  title: movie.title,
                  subtitle: movie.description,
                  imageUrl: movie.imageUrl
                )
                .matchedTransitionSource(id: movie.id, in: namespace)
              }
              .buttonStyle(.noHighlight)
            }
          }
          .frame(height: 600)
          .navigationDestination(for: Movie.self) { movie in
            MovieCardView(showDetails: true, movie: movie)
              .navigationTransition(.zoom(sourceID: movie.id, in: namespace))
          }
          .tabViewStyle(.page(indexDisplayMode: .always))

          Group {
            MovieListSection(namespace: namespace, title: "Top Movies", movies: topMovies)
            if isSignedIn {
              MovieListSection(namespace: namespace, title: "Watch List", movies: watchList)
                .onAppear {
                  Task {
                    try await watchListRef.execute()
                  }
                }
            }
          }
          .navigationDestination(for: [Movie].self) { movies in
            MovieListScreen(namespace: namespace, movies: movies)
          }
          .navigationDestination(for: SectionedMovie.self) { sectionedMovie in
            MovieCardView(showDetails: true, movie: sectionedMovie.movie)
              .navigationTransition(.zoom(sourceID: sectionedMovie.id, in: namespace))
          }
          .padding()
        }
      }
      .refreshable {
        await refresh()
      }
      .navigationTitle("Home")
      .toolbar {
        ToolbarItem(placement: .topBarTrailing) {
          AuthenticationToolbarButton()
        }
      }
      .ignoresSafeArea()
    }
  }
}

#Preview {
  HomeScreen()
    .environment(AuthenticationService())
}
