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

struct MovieCardView: View {
  var showDetails: Bool = false

  var movie: ListMoviesQuery.Data.Movie

  var body: some View {
    CardView(showDetails: showDetails) {
      if let imageUrl = URL(string: movie.imageUrl) {
        AsyncImage(url: imageUrl) { phase in
          if let image = phase.image {
            image
              .resizable()
              .scaledToFit()
              .frame(maxWidth: .infinity)
              .clipped()
          } else if phase.error != nil {
            Color.red
              .redacted(if: true)
          } else {
            Image(systemName: "photo.artframe")
              .resizable()
              .scaledToFit()
              .frame(maxWidth: .infinity)
              .clipped()
              .redacted(reason: .placeholder)
          }
        }
      }
    } heroTitle: {
      VStack(alignment: .leading) {
        Spacer()
        HStack {
          VStack(alignment: .leading) {
            Text(movie.title)
              .multilineTextAlignment(.leading)
              .font(.title)
              .bold()
            if let releaseYear = movie.releaseYear {
              Text("Released: \(format: releaseYear, using: .none)")
            }
          }
          Spacer()
        }
        .padding()
        .background(.thinMaterial)
      }
    } details: {
      MovieDetailsView(movie: movie)
    }
  }
}

// #Preview {
//  MovieCardView(showDetails: true, gradientConfiguration: GradienConfiguration.sample)
// }
