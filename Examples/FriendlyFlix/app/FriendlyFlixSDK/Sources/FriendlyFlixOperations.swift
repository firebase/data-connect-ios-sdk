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

import Foundation

import FirebaseCore
import FirebaseDataConnect

// MARK: Common Enums

public enum OrderDirection: String, Codable, Sendable {
  case ASC
  case DESC
}

// End enum definitions

public class UpsertUserMutation {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "UpsertUser"

  public typealias Ref = MutationRef<UpsertUserMutation.Data, UpsertUserMutation.Variables>

  public struct Variables: OperationVariable {
    public var
      username: String

    public init(username: String) {
      self.username = username
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.username == rhs.username
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(username)
    }

    enum CodingKeys: String, CodingKey {
      case username
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(username, forKey: .username, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public var
      user_upsert: UserKey
  }

  public func ref(username: String) -> MutationRef<
    UpsertUserMutation.Data,
    UpsertUserMutation.Variables
  > {
    var variables = UpsertUserMutation.Variables(username: username)

    let ref = dataConnect.mutation(
      name: "UpsertUser",
      variables: variables,
      resultsDataType: UpsertUserMutation.Data.self
    )
    return ref as MutationRef<UpsertUserMutation.Data, UpsertUserMutation.Variables>
  }

  @MainActor
  public func execute(username: String) async throws -> OperationResult<UpsertUserMutation.Data> {
    var variables = UpsertUserMutation.Variables(username: username)

    let ref = dataConnect.mutation(
      name: "UpsertUser",
      variables: variables,
      resultsDataType: UpsertUserMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class AddFavoritedMovieMutation {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "AddFavoritedMovie"

  public typealias Ref = MutationRef<
    AddFavoritedMovieMutation.Data,
    AddFavoritedMovieMutation.Variables
  >

  public struct Variables: OperationVariable {
    public var
      movieId: UUID

    public init(movieId: UUID) {
      self.movieId = movieId
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.movieId == rhs.movieId
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(movieId)
    }

    enum CodingKeys: String, CodingKey {
      case movieId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public var
      favorite_movie_upsert: FavoriteMovieKey
  }

  public func ref(movieId: UUID) -> MutationRef<
    AddFavoritedMovieMutation.Data,
    AddFavoritedMovieMutation.Variables
  > {
    var variables = AddFavoritedMovieMutation.Variables(movieId: movieId)

    let ref = dataConnect.mutation(
      name: "AddFavoritedMovie",
      variables: variables,
      resultsDataType: AddFavoritedMovieMutation.Data.self
    )
    return ref as MutationRef<
      AddFavoritedMovieMutation.Data,
      AddFavoritedMovieMutation.Variables
    >
  }

  @MainActor
  public func execute(movieId: UUID) async throws
    -> OperationResult<AddFavoritedMovieMutation.Data> {
    var variables = AddFavoritedMovieMutation.Variables(movieId: movieId)

    let ref = dataConnect.mutation(
      name: "AddFavoritedMovie",
      variables: variables,
      resultsDataType: AddFavoritedMovieMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class DeleteFavoritedMovieMutation {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "DeleteFavoritedMovie"

  public typealias Ref = MutationRef<
    DeleteFavoritedMovieMutation.Data,
    DeleteFavoritedMovieMutation.Variables
  >

  public struct Variables: OperationVariable {
    public var
      movieId: UUID

    public init(movieId: UUID) {
      self.movieId = movieId
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.movieId == rhs.movieId
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(movieId)
    }

    enum CodingKeys: String, CodingKey {
      case movieId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public var
      favorite_movie_delete: FavoriteMovieKey?
  }

  public func ref(movieId: UUID)
    -> MutationRef<DeleteFavoritedMovieMutation.Data,
      DeleteFavoritedMovieMutation.Variables> {
    var variables = DeleteFavoritedMovieMutation.Variables(movieId: movieId)

    let ref = dataConnect.mutation(
      name: "DeleteFavoritedMovie",
      variables: variables,
      resultsDataType: DeleteFavoritedMovieMutation.Data.self
    )
    return ref as MutationRef<
      DeleteFavoritedMovieMutation.Data,
      DeleteFavoritedMovieMutation.Variables
    >
  }

  @MainActor
  public func execute(movieId: UUID) async throws
    -> OperationResult<DeleteFavoritedMovieMutation.Data> {
    var variables = DeleteFavoritedMovieMutation.Variables(movieId: movieId)

    let ref = dataConnect.mutation(
      name: "DeleteFavoritedMovie",
      variables: variables,
      resultsDataType: DeleteFavoritedMovieMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class AddReviewMutation {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "AddReview"

  public typealias Ref = MutationRef<AddReviewMutation.Data, AddReviewMutation.Variables>

  public struct Variables: OperationVariable {
    public var
      movieId: UUID

    public var
      rating: Int

    public var
      reviewText: String

    public init(movieId: UUID,

                rating: Int,

                reviewText: String) {
      self.movieId = movieId
      self.rating = rating
      self.reviewText = reviewText
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.movieId == rhs.movieId &&
        lhs.rating == rhs.rating &&
        lhs.reviewText == rhs.reviewText
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(movieId)

      hasher.combine(rating)

      hasher.combine(reviewText)
    }

    enum CodingKeys: String, CodingKey {
      case movieId

      case rating

      case reviewText
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(movieId, forKey: .movieId, container: &container)

      try codecHelper.encode(rating, forKey: .rating, container: &container)

      try codecHelper.encode(reviewText, forKey: .reviewText, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public var
      review_insert: ReviewKey
  }

  public func ref(movieId: UUID,

                  rating: Int,

                  reviewText: String)
    -> MutationRef<AddReviewMutation.Data, AddReviewMutation.Variables> {
    var variables = AddReviewMutation.Variables(
      movieId: movieId,
      rating: rating,
      reviewText: reviewText
    )

    let ref = dataConnect.mutation(
      name: "AddReview",
      variables: variables,
      resultsDataType: AddReviewMutation.Data.self
    )
    return ref as MutationRef<AddReviewMutation.Data, AddReviewMutation.Variables>
  }

  @MainActor
  public func execute(movieId: UUID,

                      rating: Int,

                      reviewText: String) async throws -> OperationResult<AddReviewMutation.Data> {
    var variables = AddReviewMutation.Variables(
      movieId: movieId,
      rating: rating,
      reviewText: reviewText
    )

    let ref = dataConnect.mutation(
      name: "AddReview",
      variables: variables,
      resultsDataType: AddReviewMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class UpdateReviewMutation {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "UpdateReview"

  public typealias Ref = MutationRef<UpdateReviewMutation.Data, UpdateReviewMutation.Variables>

  public struct Variables: OperationVariable {
    public var
      movieId: UUID

    public var
      rating: Int

    public var
      reviewText: String

    public init(movieId: UUID,

                rating: Int,

                reviewText: String) {
      self.movieId = movieId
      self.rating = rating
      self.reviewText = reviewText
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.movieId == rhs.movieId &&
        lhs.rating == rhs.rating &&
        lhs.reviewText == rhs.reviewText
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(movieId)

      hasher.combine(rating)

      hasher.combine(reviewText)
    }

    enum CodingKeys: String, CodingKey {
      case movieId

      case rating

      case reviewText
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(movieId, forKey: .movieId, container: &container)

      try codecHelper.encode(rating, forKey: .rating, container: &container)

      try codecHelper.encode(reviewText, forKey: .reviewText, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public var
      review_update: ReviewKey?
  }

  public func ref(movieId: UUID,

                  rating: Int,

                  reviewText: String)
    -> MutationRef<UpdateReviewMutation.Data, UpdateReviewMutation.Variables> {
    var variables = UpdateReviewMutation.Variables(
      movieId: movieId,
      rating: rating,
      reviewText: reviewText
    )

    let ref = dataConnect.mutation(
      name: "UpdateReview",
      variables: variables,
      resultsDataType: UpdateReviewMutation.Data.self
    )
    return ref as MutationRef<UpdateReviewMutation.Data, UpdateReviewMutation.Variables>
  }

  @MainActor
  public func execute(movieId: UUID,

                      rating: Int,

                      reviewText: String) async throws
    -> OperationResult<UpdateReviewMutation.Data> {
    var variables = UpdateReviewMutation.Variables(
      movieId: movieId,
      rating: rating,
      reviewText: reviewText
    )

    let ref = dataConnect.mutation(
      name: "UpdateReview",
      variables: variables,
      resultsDataType: UpdateReviewMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class DeleteReviewMutation {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "DeleteReview"

  public typealias Ref = MutationRef<DeleteReviewMutation.Data, DeleteReviewMutation.Variables>

  public struct Variables: OperationVariable {
    public var
      movieId: UUID

    public init(movieId: UUID) {
      self.movieId = movieId
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.movieId == rhs.movieId
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(movieId)
    }

    enum CodingKeys: String, CodingKey {
      case movieId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public var
      review_delete: ReviewKey?
  }

  public func ref(movieId: UUID) -> MutationRef<
    DeleteReviewMutation.Data,
    DeleteReviewMutation.Variables
  > {
    var variables = DeleteReviewMutation.Variables(movieId: movieId)

    let ref = dataConnect.mutation(
      name: "DeleteReview",
      variables: variables,
      resultsDataType: DeleteReviewMutation.Data.self
    )
    return ref as MutationRef<DeleteReviewMutation.Data, DeleteReviewMutation.Variables>
  }

  @MainActor
  public func execute(movieId: UUID) async throws -> OperationResult<DeleteReviewMutation.Data> {
    var variables = DeleteReviewMutation.Variables(movieId: movieId)

    let ref = dataConnect.mutation(
      name: "DeleteReview",
      variables: variables,
      resultsDataType: DeleteReviewMutation.Data.self
    )

    return try await ref.execute()
  }
}

public class ListMoviesQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "ListMovies"

  public typealias Ref = QueryRefObservation<ListMoviesQuery.Data, ListMoviesQuery.Variables>

  public struct Variables: OperationVariable {
    @OptionalVariable
    public var
      orderByRating: OrderDirection?

    @OptionalVariable
    public var
      orderByReleaseYear: OrderDirection?

    @OptionalVariable
    public var
      limit: Int?

    public init(_ optionalVars: ((inout Variables) -> Void)? = nil) {
      if let optionalVars {
        optionalVars(&self)
      }
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.orderByRating == rhs.orderByRating &&
        lhs.orderByReleaseYear == rhs.orderByReleaseYear &&
        lhs.limit == rhs.limit
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(orderByRating)

      hasher.combine(orderByReleaseYear)

      hasher.combine(limit)
    }

    enum CodingKeys: String, CodingKey {
      case orderByRating

      case orderByReleaseYear

      case limit
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      if $orderByRating.isSet {
        try codecHelper.encode(orderByRating, forKey: .orderByRating, container: &container)
      }

      if $orderByReleaseYear.isSet {
        try codecHelper.encode(
          orderByReleaseYear,
          forKey: .orderByReleaseYear,
          container: &container
        )
      }

      if $limit.isSet {
        try codecHelper.encode(limit, forKey: .limit, container: &container)
      }
    }
  }

  public struct Data: Decodable, Sendable {
    public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        title: String

      public var
        imageUrl: String

      public var
        releaseYear: Int?

      public var
        genre: String?

      public var
        rating: Double?

      public var
        tags: [String]?

      public var
        description: String?

      public var movieKey: MovieKey {
        return MovieKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case title

        case imageUrl

        case releaseYear

        case genre

        case rating

        case tags

        case description
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        title = try codecHelper.decode(String.self, forKey: .title, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)

        releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)

        genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

        rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

        tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)

        description = try codecHelper.decode(
          String?.self,
          forKey: .description,
          container: &container
        )
      }
    }

    public var
      movies: [Movie]
  }

  public func ref(_ optionalVars: ((inout ListMoviesQuery.Variables) -> Void)? = nil)
    -> QueryRefObservation<
      ListMoviesQuery.Data,
      ListMoviesQuery.Variables
    > {
    var variables = ListMoviesQuery.Variables()

    if let optionalVars {
      optionalVars(&variables)
    }

    let ref = dataConnect.query(
      name: "ListMovies",
      variables: variables,
      resultsDataType: ListMoviesQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<ListMoviesQuery.Data, ListMoviesQuery.Variables>
  }

  @MainActor
  public func execute(_ optionalVars: (@MainActor (inout ListMoviesQuery.Variables) -> Void)? =
    nil) async throws -> OperationResult<ListMoviesQuery.Data> {
    var variables = ListMoviesQuery.Variables()

    if let optionalVars {
      optionalVars(&variables)
    }

    let ref = dataConnect.query(
      name: "ListMovies",
      variables: variables,
      resultsDataType: ListMoviesQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<ListMoviesQuery.Data, ListMoviesQuery.Variables>
    return try await refCast.execute()
  }
}

public class GetMovieByIdQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetMovieById"

  public typealias Ref = QueryRefObservation<GetMovieByIdQuery.Data, GetMovieByIdQuery.Variables>

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        title: String

      public var
        imageUrl: String

      public var
        releaseYear: Int?

      public var
        genre: String?

      public var
        rating: Double?

      public var
        description: String?

      public var
        tags: [String]?

      public struct MovieMetadataMetadata: Decodable, Sendable {
        public var
          director: String?

        enum CodingKeys: String, CodingKey {
          case director
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          director = try codecHelper.decode(String?.self, forKey: .director, container: &container)
        }
      }

      public var
        metadata: [MovieMetadataMetadata]

      public struct ActorMainActors: Decodable, Sendable, Hashable, Equatable, Identifiable {
        public var
          id: UUID

        public var
          name: String

        public var
          imageUrl: String

        public var actorMainActorsKey: ActorKey {
          return ActorKey(
            id: id
          )
        }

        public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
        }

        public static func == (lhs: ActorMainActors, rhs: ActorMainActors) -> Bool {
          return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
          case id

          case name

          case imageUrl
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          name = try codecHelper.decode(String.self, forKey: .name, container: &container)

          imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
        }
      }

      public var
        mainActors: [ActorMainActors]

      public struct ActorSupportingActors: Decodable, Sendable, Hashable, Equatable, Identifiable {
        public var
          id: UUID

        public var
          name: String

        public var
          imageUrl: String

        public var actorSupportingActorsKey: ActorKey {
          return ActorKey(
            id: id
          )
        }

        public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
        }

        public static func == (lhs: ActorSupportingActors, rhs: ActorSupportingActors) -> Bool {
          return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
          case id

          case name

          case imageUrl
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          name = try codecHelper.decode(String.self, forKey: .name, container: &container)

          imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
        }
      }

      public var
        supportingActors: [ActorSupportingActors]

      public struct ReviewReviews: Decodable, Sendable {
        public var
          id: UUID

        public var
          reviewText: String?

        public var
          reviewDate: LocalDate

        public var
          rating: Int?

        public struct User: Decodable, Sendable, Hashable, Equatable, Identifiable {
          public var
            id: String

          public var
            username: String

          public var userKey: UserKey {
            return UserKey(
              id: id
            )
          }

          public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
          }

          public static func == (lhs: User, rhs: User) -> Bool {
            return lhs.id == rhs.id
          }

          enum CodingKeys: String, CodingKey {
            case id

            case username
          }

          public init(from decoder: any Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            let codecHelper = CodecHelper<CodingKeys>()

            id = try codecHelper.decode(String.self, forKey: .id, container: &container)

            username = try codecHelper.decode(String.self, forKey: .username, container: &container)
          }
        }

        public var
          user: User

        enum CodingKeys: String, CodingKey {
          case id

          case reviewText

          case reviewDate

          case rating

          case user
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          reviewText = try codecHelper.decode(
            String?.self,
            forKey: .reviewText,
            container: &container
          )

          reviewDate = try codecHelper.decode(
            LocalDate.self,
            forKey: .reviewDate,
            container: &container
          )

          rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)

          user = try codecHelper.decode(User.self, forKey: .user, container: &container)
        }
      }

      public var
        reviews: [ReviewReviews]

      public var movieKey: MovieKey {
        return MovieKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case title

        case imageUrl

        case releaseYear

        case genre

        case rating

        case description

        case tags

        case metadata

        case mainActors

        case supportingActors

        case reviews
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        title = try codecHelper.decode(String.self, forKey: .title, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)

        releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)

        genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

        rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

        description = try codecHelper.decode(
          String?.self,
          forKey: .description,
          container: &container
        )

        tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)

        metadata = try codecHelper.decode(
          [MovieMetadataMetadata].self,
          forKey: .metadata,
          container: &container
        )

        mainActors = try codecHelper.decode(
          [ActorMainActors].self,
          forKey: .mainActors,
          container: &container
        )

        supportingActors = try codecHelper.decode(
          [ActorSupportingActors].self,
          forKey: .supportingActors,
          container: &container
        )

        reviews = try codecHelper.decode(
          [ReviewReviews].self,
          forKey: .reviews,
          container: &container
        )
      }
    }

    public var
      movie: Movie?
  }

  public func ref(id: UUID) -> QueryRefObservation<
    GetMovieByIdQuery.Data,
    GetMovieByIdQuery.Variables
  > {
    var variables = GetMovieByIdQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetMovieById",
      variables: variables,
      resultsDataType: GetMovieByIdQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<GetMovieByIdQuery.Data, GetMovieByIdQuery.Variables>
  }

  @MainActor
  public func execute(id: UUID) async throws -> OperationResult<GetMovieByIdQuery.Data> {
    var variables = GetMovieByIdQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetMovieById",
      variables: variables,
      resultsDataType: GetMovieByIdQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<
      GetMovieByIdQuery.Data,
      GetMovieByIdQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetActorByIdQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetActorById"

  public typealias Ref = QueryRefObservation<GetActorByIdQuery.Data, GetActorByIdQuery.Variables>

  public struct Variables: OperationVariable {
    public var
      id: UUID

    public init(id: UUID) {
      self.id = id
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(id)
    }

    enum CodingKeys: String, CodingKey {
      case id
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(id, forKey: .id, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public struct Actor: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        name: String

      public var
        imageUrl: String

      public struct MovieMainActors: Decodable, Sendable, Hashable, Equatable, Identifiable {
        public var
          id: UUID

        public var
          title: String

        public var
          genre: String?

        public var
          tags: [String]?

        public var
          imageUrl: String

        public var movieMainActorsKey: MovieKey {
          return MovieKey(
            id: id
          )
        }

        public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
        }

        public static func == (lhs: MovieMainActors, rhs: MovieMainActors) -> Bool {
          return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
          case id

          case title

          case genre

          case tags

          case imageUrl
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          title = try codecHelper.decode(String.self, forKey: .title, container: &container)

          genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

          tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)

          imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
        }
      }

      public var
        mainActors: [MovieMainActors]

      public struct MovieSupportingActors: Decodable, Sendable, Hashable, Equatable, Identifiable {
        public var
          id: UUID

        public var
          title: String

        public var
          genre: String?

        public var
          tags: [String]?

        public var
          imageUrl: String

        public var movieSupportingActorsKey: MovieKey {
          return MovieKey(
            id: id
          )
        }

        public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
        }

        public static func == (lhs: MovieSupportingActors, rhs: MovieSupportingActors) -> Bool {
          return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
          case id

          case title

          case genre

          case tags

          case imageUrl
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          title = try codecHelper.decode(String.self, forKey: .title, container: &container)

          genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

          tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)

          imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
        }
      }

      public var
        supportingActors: [MovieSupportingActors]

      public var actorKey: ActorKey {
        return ActorKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: Actor, rhs: Actor) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case name

        case imageUrl

        case mainActors

        case supportingActors
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        name = try codecHelper.decode(String.self, forKey: .name, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)

        mainActors = try codecHelper.decode(
          [MovieMainActors].self,
          forKey: .mainActors,
          container: &container
        )

        supportingActors = try codecHelper.decode(
          [MovieSupportingActors].self,
          forKey: .supportingActors,
          container: &container
        )
      }
    }

    public var
      actor: Actor?
  }

  public func ref(id: UUID) -> QueryRefObservation<
    GetActorByIdQuery.Data,
    GetActorByIdQuery.Variables
  > {
    var variables = GetActorByIdQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetActorById",
      variables: variables,
      resultsDataType: GetActorByIdQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<GetActorByIdQuery.Data, GetActorByIdQuery.Variables>
  }

  @MainActor
  public func execute(id: UUID) async throws -> OperationResult<GetActorByIdQuery.Data> {
    var variables = GetActorByIdQuery.Variables(id: id)

    let ref = dataConnect.query(
      name: "GetActorById",
      variables: variables,
      resultsDataType: GetActorByIdQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<
      GetActorByIdQuery.Data,
      GetActorByIdQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetCurrentUserQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetCurrentUser"

  public typealias Ref = QueryRefObservation<
    GetCurrentUserQuery.Data,
    GetCurrentUserQuery.Variables
  >

  public struct Variables: OperationVariable {}

  public struct Data: Decodable, Sendable {
    public struct User: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: String

      public var
        username: String

      public struct ReviewReviews: Decodable, Sendable {
        public var
          id: UUID

        public var
          rating: Int?

        public var
          reviewDate: LocalDate

        public var
          reviewText: String?

        public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
          public var
            id: UUID

          public var
            title: String

          public var movieKey: MovieKey {
            return MovieKey(
              id: id
            )
          }

          public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
          }

          public static func == (lhs: Movie, rhs: Movie) -> Bool {
            return lhs.id == rhs.id
          }

          enum CodingKeys: String, CodingKey {
            case id

            case title
          }

          public init(from decoder: any Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            let codecHelper = CodecHelper<CodingKeys>()

            id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

            title = try codecHelper.decode(String.self, forKey: .title, container: &container)
          }
        }

        public var
          movie: Movie

        enum CodingKeys: String, CodingKey {
          case id

          case rating

          case reviewDate

          case reviewText

          case movie
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)

          reviewDate = try codecHelper.decode(
            LocalDate.self,
            forKey: .reviewDate,
            container: &container
          )

          reviewText = try codecHelper.decode(
            String?.self,
            forKey: .reviewText,
            container: &container
          )

          movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
        }
      }

      public var
        reviews: [ReviewReviews]

      public struct FavoriteMovieFavoriteMovies: Decodable, Sendable {
        public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
          public var
            id: UUID

          public var
            title: String

          public var
            genre: String?

          public var
            imageUrl: String

          public var
            releaseYear: Int?

          public var
            rating: Double?

          public var
            description: String?

          public var
            tags: [String]?

          public struct MovieMetadataMetadata: Decodable, Sendable {
            public var
              director: String?

            enum CodingKeys: String, CodingKey {
              case director
            }

            public init(from decoder: any Decoder) throws {
              var container = try decoder.container(keyedBy: CodingKeys.self)
              let codecHelper = CodecHelper<CodingKeys>()

              director = try codecHelper.decode(
                String?.self,
                forKey: .director,
                container: &container
              )
            }
          }

          public var
            metadata: [MovieMetadataMetadata]

          public var movieKey: MovieKey {
            return MovieKey(
              id: id
            )
          }

          public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
          }

          public static func == (lhs: Movie, rhs: Movie) -> Bool {
            return lhs.id == rhs.id
          }

          enum CodingKeys: String, CodingKey {
            case id

            case title

            case genre

            case imageUrl

            case releaseYear

            case rating

            case description

            case tags

            case metadata
          }

          public init(from decoder: any Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            let codecHelper = CodecHelper<CodingKeys>()

            id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

            title = try codecHelper.decode(String.self, forKey: .title, container: &container)

            genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

            imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)

            releaseYear = try codecHelper.decode(
              Int?.self,
              forKey: .releaseYear,
              container: &container
            )

            rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

            description = try codecHelper.decode(
              String?.self,
              forKey: .description,
              container: &container
            )

            tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)

            metadata = try codecHelper.decode(
              [MovieMetadataMetadata].self,
              forKey: .metadata,
              container: &container
            )
          }
        }

        public var
          movie: Movie

        enum CodingKeys: String, CodingKey {
          case movie
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
        }
      }

      public var
        favoriteMovies: [FavoriteMovieFavoriteMovies]

      public var userKey: UserKey {
        return UserKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case username

        case reviews

        case favoriteMovies
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(String.self, forKey: .id, container: &container)

        username = try codecHelper.decode(String.self, forKey: .username, container: &container)

        reviews = try codecHelper.decode(
          [ReviewReviews].self,
          forKey: .reviews,
          container: &container
        )

        favoriteMovies = try codecHelper.decode(
          [FavoriteMovieFavoriteMovies].self,
          forKey: .favoriteMovies,
          container: &container
        )
      }
    }

    public var
      user: User?
  }

  public func ref(
  ) -> QueryRefObservation<GetCurrentUserQuery.Data, GetCurrentUserQuery.Variables> {
    var variables = GetCurrentUserQuery.Variables()

    let ref = dataConnect.query(
      name: "GetCurrentUser",
      variables: variables,
      resultsDataType: GetCurrentUserQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<GetCurrentUserQuery.Data, GetCurrentUserQuery.Variables>
  }

  @MainActor
  public func execute(
  ) async throws -> OperationResult<GetCurrentUserQuery.Data> {
    var variables = GetCurrentUserQuery.Variables()

    let ref = dataConnect.query(
      name: "GetCurrentUser",
      variables: variables,
      resultsDataType: GetCurrentUserQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<
      GetCurrentUserQuery.Data,
      GetCurrentUserQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetIfFavoritedMovieQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetIfFavoritedMovie"

  public typealias Ref = QueryRefObservation<
    GetIfFavoritedMovieQuery.Data,
    GetIfFavoritedMovieQuery.Variables
  >

  public struct Variables: OperationVariable {
    public var
      movieId: UUID

    public init(movieId: UUID) {
      self.movieId = movieId
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.movieId == rhs.movieId
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(movieId)
    }

    enum CodingKeys: String, CodingKey {
      case movieId
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public struct FavoriteMovie: Decodable, Sendable {
      public var
        movieId: UUID

      enum CodingKeys: String, CodingKey {
        case movieId
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        movieId = try codecHelper.decode(UUID.self, forKey: .movieId, container: &container)
      }
    }

    public var
      favorite_movie: FavoriteMovie?
  }

  public func ref(movieId: UUID)
    -> QueryRefObservation<GetIfFavoritedMovieQuery.Data,
      GetIfFavoritedMovieQuery.Variables> {
    var variables = GetIfFavoritedMovieQuery.Variables(movieId: movieId)

    let ref = dataConnect.query(
      name: "GetIfFavoritedMovie",
      variables: variables,
      resultsDataType: GetIfFavoritedMovieQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<
      GetIfFavoritedMovieQuery.Data,
      GetIfFavoritedMovieQuery.Variables
    >
  }

  @MainActor
  public func execute(movieId: UUID) async throws
    -> OperationResult<GetIfFavoritedMovieQuery.Data> {
    var variables = GetIfFavoritedMovieQuery.Variables(movieId: movieId)

    let ref = dataConnect.query(
      name: "GetIfFavoritedMovie",
      variables: variables,
      resultsDataType: GetIfFavoritedMovieQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<
      GetIfFavoritedMovieQuery.Data,
      GetIfFavoritedMovieQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class SearchAllQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "SearchAll"

  public typealias Ref = QueryRefObservation<SearchAllQuery.Data, SearchAllQuery.Variables>

  public struct Variables: OperationVariable {
    @OptionalVariable
    public var
      input: String?

    public var
      minYear: Int

    public var
      maxYear: Int

    public var
      minRating: Double

    public var
      maxRating: Double

    public var
      genre: String

    public init(minYear: Int,

                maxYear: Int,

                minRating: Double,

                maxRating: Double,

                genre: String,

                _ optionalVars: ((inout Variables) -> Void)? = nil) {
      self.minYear = minYear
      self.maxYear = maxYear
      self.minRating = minRating
      self.maxRating = maxRating
      self.genre = genre

      if let optionalVars {
        optionalVars(&self)
      }
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.input == rhs.input &&
        lhs.minYear == rhs.minYear &&
        lhs.maxYear == rhs.maxYear &&
        lhs.minRating == rhs.minRating &&
        lhs.maxRating == rhs.maxRating &&
        lhs.genre == rhs.genre
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(input)

      hasher.combine(minYear)

      hasher.combine(maxYear)

      hasher.combine(minRating)

      hasher.combine(maxRating)

      hasher.combine(genre)
    }

    enum CodingKeys: String, CodingKey {
      case input

      case minYear

      case maxYear

      case minRating

      case maxRating

      case genre
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      if $input.isSet {
        try codecHelper.encode(input, forKey: .input, container: &container)
      }

      try codecHelper.encode(minYear, forKey: .minYear, container: &container)

      try codecHelper.encode(maxYear, forKey: .maxYear, container: &container)

      try codecHelper.encode(minRating, forKey: .minRating, container: &container)

      try codecHelper.encode(maxRating, forKey: .maxRating, container: &container)

      try codecHelper.encode(genre, forKey: .genre, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public struct MovieMoviesMatchingTitle: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        title: String

      public var
        genre: String?

      public var
        rating: Double?

      public var
        imageUrl: String

      public var movieMoviesMatchingTitleKey: MovieKey {
        return MovieKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: MovieMoviesMatchingTitle, rhs: MovieMoviesMatchingTitle) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case title

        case genre

        case rating

        case imageUrl
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        title = try codecHelper.decode(String.self, forKey: .title, container: &container)

        genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

        rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
      }
    }

    public var
      moviesMatchingTitle: [MovieMoviesMatchingTitle]

    public struct MovieMoviesMatchingDescription: Decodable, Sendable, Hashable, Equatable,
      Identifiable {
      public var
        id: UUID

      public var
        title: String

      public var
        genre: String?

      public var
        rating: Double?

      public var
        imageUrl: String

      public var movieMoviesMatchingDescriptionKey: MovieKey {
        return MovieKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: MovieMoviesMatchingDescription,
                             rhs: MovieMoviesMatchingDescription) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case title

        case genre

        case rating

        case imageUrl
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        title = try codecHelper.decode(String.self, forKey: .title, container: &container)

        genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

        rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
      }
    }

    public var
      moviesMatchingDescription: [MovieMoviesMatchingDescription]

    public struct ActorActorsMatchingName: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        name: String

      public var
        imageUrl: String

      public var actorActorsMatchingNameKey: ActorKey {
        return ActorKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: ActorActorsMatchingName, rhs: ActorActorsMatchingName) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case name

        case imageUrl
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        name = try codecHelper.decode(String.self, forKey: .name, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
      }
    }

    public var
      actorsMatchingName: [ActorActorsMatchingName]

    public struct ReviewReviewsMatchingText: Decodable, Sendable {
      public var
        id: UUID

      public var
        rating: Int?

      public var
        reviewText: String?

      public var
        reviewDate: LocalDate

      public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
        public var
          id: UUID

        public var
          title: String

        public var movieKey: MovieKey {
          return MovieKey(
            id: id
          )
        }

        public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
        }

        public static func == (lhs: Movie, rhs: Movie) -> Bool {
          return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
          case id

          case title
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

          title = try codecHelper.decode(String.self, forKey: .title, container: &container)
        }
      }

      public var
        movie: Movie

      public struct User: Decodable, Sendable, Hashable, Equatable, Identifiable {
        public var
          id: String

        public var
          username: String

        public var userKey: UserKey {
          return UserKey(
            id: id
          )
        }

        public func hash(into hasher: inout Hasher) {
          hasher.combine(id)
        }

        public static func == (lhs: User, rhs: User) -> Bool {
          return lhs.id == rhs.id
        }

        enum CodingKeys: String, CodingKey {
          case id

          case username
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          id = try codecHelper.decode(String.self, forKey: .id, container: &container)

          username = try codecHelper.decode(String.self, forKey: .username, container: &container)
        }
      }

      public var
        user: User

      enum CodingKeys: String, CodingKey {
        case id

        case rating

        case reviewText

        case reviewDate

        case movie

        case user
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)

        reviewText = try codecHelper.decode(
          String?.self,
          forKey: .reviewText,
          container: &container
        )

        reviewDate = try codecHelper.decode(
          LocalDate.self,
          forKey: .reviewDate,
          container: &container
        )

        movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)

        user = try codecHelper.decode(User.self, forKey: .user, container: &container)
      }
    }

    public var
      reviewsMatchingText: [ReviewReviewsMatchingText]
  }

  public func ref(minYear: Int,

                  maxYear: Int,

                  minRating: Double,

                  maxRating: Double,

                  genre: String,

                  _ optionalVars: ((inout SearchAllQuery.Variables) -> Void)? = nil)
    -> QueryRefObservation<
      SearchAllQuery.Data,
      SearchAllQuery.Variables
    > {
    var variables = SearchAllQuery.Variables(
      minYear: minYear,
      maxYear: maxYear,
      minRating: minRating,
      maxRating: maxRating,
      genre: genre
    )

    if let optionalVars {
      optionalVars(&variables)
    }

    let ref = dataConnect.query(
      name: "SearchAll",
      variables: variables,
      resultsDataType: SearchAllQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<SearchAllQuery.Data, SearchAllQuery.Variables>
  }

  @MainActor
  public func execute(minYear: Int,

                      maxYear: Int,

                      minRating: Double,

                      maxRating: Double,

                      genre: String,

                      _ optionalVars: (@MainActor (inout SearchAllQuery.Variables) -> Void)? =
                        nil) async throws -> OperationResult<SearchAllQuery.Data> {
    var variables = SearchAllQuery.Variables(
      minYear: minYear,
      maxYear: maxYear,
      minRating: minRating,
      maxRating: maxRating,
      genre: genre
    )

    if let optionalVars {
      optionalVars(&variables)
    }

    let ref = dataConnect.query(
      name: "SearchAll",
      variables: variables,
      resultsDataType: SearchAllQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<SearchAllQuery.Data, SearchAllQuery.Variables>
    return try await refCast.execute()
  }
}

public class ListMoviesByPartialTitleQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "ListMoviesByPartialTitle"

  public typealias Ref = QueryRefObservation<
    ListMoviesByPartialTitleQuery.Data,
    ListMoviesByPartialTitleQuery.Variables
  >

  public struct Variables: OperationVariable {
    public var
      searchTerm: String

    public init(searchTerm: String) {
      self.searchTerm = searchTerm
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      return lhs.searchTerm == rhs.searchTerm
    }

    public func hash(into hasher: inout Hasher) {
      hasher.combine(searchTerm)
    }

    enum CodingKeys: String, CodingKey {
      case searchTerm
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()

      try codecHelper.encode(searchTerm, forKey: .searchTerm, container: &container)
    }
  }

  public struct Data: Decodable, Sendable {
    public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
      public var
        id: UUID

      public var
        title: String

      public var
        imageUrl: String

      public var
        releaseYear: Int?

      public var
        genre: String?

      public var
        rating: Double?

      public var
        description: String?

      public var movieKey: MovieKey {
        return MovieKey(
          id: id
        )
      }

      public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
      }

      public static func == (lhs: Movie, rhs: Movie) -> Bool {
        return lhs.id == rhs.id
      }

      enum CodingKeys: String, CodingKey {
        case id

        case title

        case imageUrl

        case releaseYear

        case genre

        case rating

        case description
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

        title = try codecHelper.decode(String.self, forKey: .title, container: &container)

        imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)

        releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)

        genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

        rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

        description = try codecHelper.decode(
          String?.self,
          forKey: .description,
          container: &container
        )
      }
    }

    public var
      movies: [Movie]
  }

  public func ref(searchTerm: String)
    -> QueryRefObservation<ListMoviesByPartialTitleQuery.Data,
      ListMoviesByPartialTitleQuery.Variables> {
    var variables = ListMoviesByPartialTitleQuery.Variables(searchTerm: searchTerm)

    let ref = dataConnect.query(
      name: "ListMoviesByPartialTitle",
      variables: variables,
      resultsDataType: ListMoviesByPartialTitleQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<
      ListMoviesByPartialTitleQuery.Data,
      ListMoviesByPartialTitleQuery.Variables
    >
  }

  @MainActor
  public func execute(searchTerm: String) async throws
    -> OperationResult<ListMoviesByPartialTitleQuery.Data> {
    var variables = ListMoviesByPartialTitleQuery.Variables(searchTerm: searchTerm)

    let ref = dataConnect.query(
      name: "ListMoviesByPartialTitle",
      variables: variables,
      resultsDataType: ListMoviesByPartialTitleQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<
      ListMoviesByPartialTitleQuery.Data,
      ListMoviesByPartialTitleQuery.Variables
    >
    return try await refCast.execute()
  }
}

public class GetUserFavoriteMoviesQuery {
  let dataConnect: DataConnect

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect
  }

  public static let OperationName = "GetUserFavoriteMovies"

  public typealias Ref = QueryRefObservation<
    GetUserFavoriteMoviesQuery.Data,
    GetUserFavoriteMoviesQuery.Variables
  >

  public struct Variables: OperationVariable {}

  public struct Data: Decodable, Sendable {
    public struct User: Decodable, Sendable {
      public struct FavoriteMovieFavoriteMovies: Decodable, Sendable {
        public struct Movie: Decodable, Sendable, Hashable, Equatable, Identifiable {
          public var
            id: UUID

          public var
            title: String

          public var
            genre: String?

          public var
            imageUrl: String

          public var
            releaseYear: Int?

          public var
            rating: Double?

          public var
            description: String?

          public var movieKey: MovieKey {
            return MovieKey(
              id: id
            )
          }

          public func hash(into hasher: inout Hasher) {
            hasher.combine(id)
          }

          public static func == (lhs: Movie, rhs: Movie) -> Bool {
            return lhs.id == rhs.id
          }

          enum CodingKeys: String, CodingKey {
            case id

            case title

            case genre

            case imageUrl

            case releaseYear

            case rating

            case description
          }

          public init(from decoder: any Decoder) throws {
            var container = try decoder.container(keyedBy: CodingKeys.self)
            let codecHelper = CodecHelper<CodingKeys>()

            id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)

            title = try codecHelper.decode(String.self, forKey: .title, container: &container)

            genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)

            imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)

            releaseYear = try codecHelper.decode(
              Int?.self,
              forKey: .releaseYear,
              container: &container
            )

            rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)

            description = try codecHelper.decode(
              String?.self,
              forKey: .description,
              container: &container
            )
          }
        }

        public var
          movie: Movie

        enum CodingKeys: String, CodingKey {
          case movie
        }

        public init(from decoder: any Decoder) throws {
          var container = try decoder.container(keyedBy: CodingKeys.self)
          let codecHelper = CodecHelper<CodingKeys>()

          movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
        }
      }

      public var
        favoriteMovies: [FavoriteMovieFavoriteMovies]

      enum CodingKeys: String, CodingKey {
        case favoriteMovies
      }

      public init(from decoder: any Decoder) throws {
        var container = try decoder.container(keyedBy: CodingKeys.self)
        let codecHelper = CodecHelper<CodingKeys>()

        favoriteMovies = try codecHelper.decode(
          [FavoriteMovieFavoriteMovies].self,
          forKey: .favoriteMovies,
          container: &container
        )
      }
    }

    public var
      user: User?
  }

  public func ref(
  )
    -> QueryRefObservation<GetUserFavoriteMoviesQuery.Data,
      GetUserFavoriteMoviesQuery.Variables> {
    var variables = GetUserFavoriteMoviesQuery.Variables()

    let ref = dataConnect.query(
      name: "GetUserFavoriteMovies",
      variables: variables,
      resultsDataType: GetUserFavoriteMoviesQuery.Data.self,
      publisher: .observableMacro
    )
    return ref as! QueryRefObservation<
      GetUserFavoriteMoviesQuery.Data,
      GetUserFavoriteMoviesQuery.Variables
    >
  }

  @MainActor
  public func execute(
  ) async throws -> OperationResult<GetUserFavoriteMoviesQuery.Data> {
    var variables = GetUserFavoriteMoviesQuery.Variables()

    let ref = dataConnect.query(
      name: "GetUserFavoriteMovies",
      variables: variables,
      resultsDataType: GetUserFavoriteMoviesQuery.Data.self,
      publisher: .observableMacro
    )

    let refCast = ref as! QueryRefObservation<
      GetUserFavoriteMoviesQuery.Data,
      GetUserFavoriteMoviesQuery.Variables
    >
    return try await refCast.execute()
  }
}
