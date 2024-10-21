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

struct HomeScreen: View {
  @Namespace private var namespace

  var body: some View {
    NavigationStack {
      ScrollView {
        TabView {
          ForEach(Movie.featured) { movie in
            NavigationLink(value: movie) {
              MovieTeaserView(title: movie.title, subtitle: movie.subtitle, imageUrl: movie.imageUrl)
                .matchedTransitionSource(id: movie.id, in: namespace)
            }

          }
        }
        .navigationDestination(for: Movie.self) { movie in
          MovieCardView(showDetails: true, movie: movie)
            .navigationTransition(.zoom(sourceID: movie.id, in: namespace))
        }
        .frame(height: 600)
        .tabViewStyle(.page)
        .tabViewStyle(.page(indexDisplayMode: .always))

        Group {
          MovieListSection(namespace: namespace, title: "Top Movies", movies: Movie.topMovies)
          MovieListSection(namespace: namespace, title: "Watch List", movies: Movie.watchList)
          MovieListSection(namespace: namespace, title: "Featured", movies: Movie.featured)
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
    .environment(AuthenticationViewModel())
}
