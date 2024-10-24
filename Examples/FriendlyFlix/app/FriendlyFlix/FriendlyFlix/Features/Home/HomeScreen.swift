//
// HomeScreen.swift
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

struct HomeScreen: View {
  @Namespace private var namespace
  @Environment(AuthenticationService.self) var authenticationService

  private var connector = DataConnect.friendlyFlixConnector

  private func mapMovie(_ listMovie: ListMoviesQuery.Data.Movie) -> Movie {
    .init(
      title: listMovie.title,
      description: listMovie.description ?? "",
      releaseYear: listMovie.releaseYear,
      rating: listMovie.rating,
      imageUrl: listMovie.imageUrl
    )
  }

  private var heroMovies: [Movie] {
    connector.listMoviesQuery
      .ref({ optionalVars in
        optionalVars.limit = 3
        optionalVars.orderByReleaseYear = .DESC
      })
      .data?.movies.map(Movie.init) ?? []
  }

  private var topMovies: [Movie] {
    connector.listMoviesQuery
      .ref({ optionalVars in
        optionalVars.limit = 5
        optionalVars.orderByRating = .DESC
      })
      .data?.movies.map(Movie.init) ?? []
  }

  private var watchList: [Movie] {
    /// TODO: build a query that retrieves the user's watch list
    connector.listMoviesQuery.ref().data?.movies.map(Movie.init) ?? []
  }

  private var featuredMovies: [Movie] {
    /// TODO: build query that retrieves movies that are marked as "featured"
    connector.listMoviesQuery
      .ref({ optionalVars in
        optionalVars.limit = 5
        optionalVars.orderByRating = .DESC
      })
      .data?.movies.map(Movie.init) ?? []
  }
}

extension HomeScreen {
  var body: some View {
    NavigationStack {
      ScrollView {
        TabView {
          ForEach(heroMovies) { movie in
            NavigationLink(value: movie) {
              MovieTeaserView(title: movie.title, subtitle: movie.description, imageUrl: movie.imageUrl)
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
          MovieListSection(namespace: namespace, title: "Watch List", movies: watchList)
          MovieListSection(namespace: namespace, title: "Featured", movies: featuredMovies)
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
