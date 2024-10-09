//
//  MoviesList.swift
//  FriendlyFlix
//
//  Created by Peter Friese on 27.08.24.
//  Copyright © 2024 Google LLC. All rights reserved.
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

struct MoviesList: View {
  @Namespace var namespace
  var listMovies = DataConnect.friendlyFlixConnector.listMoviesQuery.ref()

  var body: some View {
    NavigationStack {
      ScrollView {
        if let movies = listMovies.data?.movies {
          ForEach(movies) { movie in
            NavigationLink(value: movie) {
              MovieCardView(showDetails: false, movie: movie)
                .matchedTransitionSource(id: "card\(movie.id)", in: namespace)
            }
          }
        }
      }
      .navigationTitle("Friendly Flix")
      .navigationDestination(for: ListMoviesQuery.Data.Movie.self) { movie in
        MovieCardView(showDetails: true, movie: movie)
          .navigationTransition(.zoom(sourceID: "card\(movie.id)", in: namespace))
      }
      .refreshable {
        do {
          let _ = try await listMovies.execute()
        } catch {}
      }
    }
    .overlay {
      if listMovies.data?.movies == nil {
        ContentUnavailableView {
          Label("No Movies", systemImage: "video.slash")
        } description: {
          Text("Movies will appear here.")
        }
      }
    }
  }
}

#Preview {
  MoviesList()
}
