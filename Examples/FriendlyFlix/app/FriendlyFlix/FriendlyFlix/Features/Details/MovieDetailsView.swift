// Copyright © 2024 Google LLC. All rights reserved.
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
import NukeUI
import SwiftUI

struct MovieDetailsView: View {
  private var movie: Movie

  private var movieDetails: MovieDetails? {
    DataConnect.friendlyFlixConnector
      .getMovieByIdQuery
      .ref(id: movie.id)
      .data?.movie.map { movieDetails in
        MovieDetails(
          title: movieDetails.title,
          description: movieDetails.description ?? "",
          releaseYear: movieDetails.releaseYear,
          rating: movieDetails.rating ?? 0,
          imageUrl: movieDetails.imageUrl,
          mainActors: movieDetails.mainActors.map { mainActor in
            MovieActor(id: mainActor.id,
                       name: mainActor.name,
                       imageUrl: mainActor.imageUrl)
          },
          supportingActors: movieDetails.supportingActors.map { supportingActor in
            MovieActor(id: supportingActor.id,
                       name: supportingActor.name,
                       imageUrl: supportingActor.imageUrl)
          },
          reviews: movieDetails.reviews.map { review in
            Review(id: review.id,
                   reviewText: review.reviewText ?? "",
                   rating: review.rating ?? 0,
                   userName: review.user.username)
          }
        )
      }
  }

  public init(movie: Movie) {
    self.movie = movie
  }
}

extension MovieDetailsView {
  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // description
      VStack(alignment: .leading, spacing: 10) {
        Text("About")
          .font(.title2)
          .bold()
          .unredacted()

        Text(movie.description)
          .font(.body)
        HStack {
          Spacer()
        }
      }

      if let movieDetails {
        if !movieDetails.mainActors.isEmpty {
          actorsSection(title: "Main actors", actors: movieDetails.mainActors)
        }
        if !movieDetails.supportingActors.isEmpty {
          actorsSection(title: "Supporting actors", actors: movieDetails.supportingActors)
        }

        // Reviews
        DetailsSection("Ratings & Reviews") {
          VStack(alignment: .leading) {
            HStack(alignment: .center) {
              Text("\(movieDetails.rating, specifier: "%.1f")")
                .font(.system(size: 64, weight: .bold))
              Spacer()
              VStack(alignment: .trailing) {
                StarRatingView(rating: Double(movieDetails.rating))
                Text("23 Ratings")
                  .font(.title)
                  .bold()
              }
            }
            Text("Most Helpful Reviews")
              .font(.title3)
              .bold()
            ScrollView(.horizontal) {
              LazyHStack {
                ForEach(movieDetails.reviews) { review in
                  MovieReviewCard(title: "Feedback",
                                  rating: Double(review.rating),
                                  reviewerName: review.userName,
                                  review: review.reviewText)
                    .frame(width: 350)
                }
              }
              .scrollTargetLayout()
            }
            .scrollTargetBehavior(.viewAligned)
            .scrollIndicators(.hidden)
          }
        }
      }
    }
    .padding()
  }
}

extension MovieDetailsView {
  func actorsSection(title: String, actors: [MovieActor]) -> some View {
    DetailsSection(title) {
      ScrollView(.horizontal) {
        LazyHStack {
          ForEach(actors, id: \.id) { actor in
            VStack(alignment: .center) {
              if let imageUrl = URL(string: actor.imageUrl) {
                LazyImage(url: imageUrl) { state in
                  if let image = state.image {
                    image
                      .resizable()
                      .scaledToFill()
                      .frame(width: 96, height: 96, alignment: .center)
                      .clipShape(Circle())
                  } else if state.error != nil {
                    Color.red
                      .redacted(if: true)
                  } else {
                    Image(systemName: "person.circle.fill")
                      .resizable()
                      .scaledToFit()
                      .frame(width: 96, height: 96, alignment: .center)
                      .redacted(reason: .placeholder)
                      .clipShape(Circle())
                  }
                }
              }
              Text(actor.name)
                .font(.headline)
            }
            .padding(.horizontal, 8)
          }
        }
      }
    }
  }
}

#Preview {
  MovieDetailsView(movie: Movie.mock)
}
