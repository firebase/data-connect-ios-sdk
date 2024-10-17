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

// Introduce a common protocol for movie actors, so we can use the same
// view for ActorMainActors and ActorSupportingActors
protocol MovieActor {
  var id: UUID { get set }
  var name: String { get set }
  var imageUrl: String { get set }
}

extension GetMovieByIdQuery.Data.Movie.ActorMainActors: MovieActor {}
extension GetMovieByIdQuery.Data.Movie.ActorSupportingActors: MovieActor {}

struct MovieDetailsView: View {
  var movie: ListMoviesQuery.Data.Movie
  let movieDetailsRef: GetMovieByIdQuery.Ref

  init(movie: ListMoviesQuery.Data.Movie) {
    self.movie = movie
    movieDetailsRef = DataConnect.friendlyFlixConnector.getMovieByIdQuery.ref(id: movie.id)
  }

//  var movieRef: GetMovieByIdQuery

  var body: some View {
    VStack(alignment: .leading, spacing: 10) {
      // description
      VStack(alignment: .leading, spacing: 10) {
        Text("About")
          .font(.title2)
          .bold()
          .unredacted()

        Text(movieDetailsRef.data?.movie?.description ?? .placeholder(length: 150))
          .font(.body)
          .redacted(reason: movieDetailsRef.data?.movie == nil ? .placeholder : [])
        HStack {
          Spacer()
        }
      }
      .redacted(if: movieDetailsRef.data == nil)

      // Actors
      if let mainActors = movieDetailsRef.data?.movie?.mainActors, mainActors.count > 0 {
        actorsSection(title: "Main actors", actors: mainActors)
      }
      if let supportingActors = movieDetailsRef.data?.movie?.supportingActors,
         supportingActors.count > 0 {
        actorsSection(title: "Supporting actors", actors: supportingActors)
      }

      // Reviews
      DetailsSection(title: "Ratings & Reviews") {
        HStack(alignment: .center) {
          Text("4.7")
            .font(.system(size: 64, weight: .bold))
          Spacer()
          VStack(alignment: .trailing) {
            StarRatingView(rating: 4.7)
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
            if let reviews = movieDetailsRef.data?.movie?.reviews {
              ForEach(reviews, id: \.id) { review in
                if let rating = review.rating, let feedback = review.reviewText {
                  MovieReviewCard(
                    title: "Feedback",
                    rating: Double(rating),
                    reviewerName: review.user.username,
                    review: feedback
                  )
                  .frame(width: 350)
                }
              }
            }
          }
          .scrollTargetLayout()
        }
        .scrollTargetBehavior(.viewAligned)
        .scrollIndicators(.hidden)
      }

      // Similar Movies
      // if let movie = movieRef.data?.movie {
      //   let metadata = "\(movie.description) \nGenres: \(movie.genres.joined(separator: " "))"
      //   RelatedSection(similarMoviesRef: DataConnect.moviesClient.listSimilarMoviesQueryRef(to: movie.id, metadata: metadata))
      // }
    }
    .padding(8)
  }
}

extension MovieDetailsView {
  func actorsSection(title: String, actors: [any MovieActor]) -> some View {
    DetailsSection(title: title) {
      ScrollView(.horizontal) {
        LazyHStack {
          ForEach(actors, id: \.id) { actor in
            VStack(alignment: .center) {
              if let imageUrl = URL(string: actor.imageUrl) {
                AsyncImage(url: imageUrl) { phase in
                  if let image = phase.image {
                    image
                      .resizable()
                      .scaledToFill()
                      .frame(width: 96, height: 96, alignment: .center)
                      .clipShape(Circle())
                  } else if phase.error != nil {
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

// #Preview {
//  MovieDetailsView(for: UUID())
// }
