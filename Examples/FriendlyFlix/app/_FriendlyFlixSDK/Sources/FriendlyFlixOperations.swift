import FirebaseDataConnect
import Foundation






















// MARK: Connector Client Extension
public extension FriendlyFlixClient {
   
    
    
    
    func createMovieMutationRef(
        
        
title: String
,
releaseYear: Int
,
genre: String
,
imageUrl: String

        
        ,
        _ optionalVars: ((inout CreateMovieMutation.Variables)->())? = nil
        ) -> MutationRef<CreateMovieMutation.Data,CreateMovieMutation.Variables>  {
        var variables = CreateMovieMutation.Variables(title:title,releaseYear:releaseYear,genre:genre,imageUrl:imageUrl)
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = MutationRequest(operationName: "CreateMovie", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:CreateMovieMutation.Data.self)
        return ref as! MutationRef<CreateMovieMutation.Data,CreateMovieMutation.Variables>
    }
    
    
    
    
    func addFavoritedMovieMutationRef(
        
        
movieId: UUID

        ) -> MutationRef<AddFavoritedMovieMutation.Data,AddFavoritedMovieMutation.Variables>  {
        var variables = AddFavoritedMovieMutation.Variables(movieId:movieId)
        
        let request = MutationRequest(operationName: "AddFavoritedMovie", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:AddFavoritedMovieMutation.Data.self)
        return ref as! MutationRef<AddFavoritedMovieMutation.Data,AddFavoritedMovieMutation.Variables>
    }
    
    
    
    
    func deleteFavoritedMovieMutationRef(
        
        
movieId: UUID

        ) -> MutationRef<DeleteFavoritedMovieMutation.Data,DeleteFavoritedMovieMutation.Variables>  {
        var variables = DeleteFavoritedMovieMutation.Variables(movieId:movieId)
        
        let request = MutationRequest(operationName: "DeleteFavoritedMovie", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:DeleteFavoritedMovieMutation.Data.self)
        return ref as! MutationRef<DeleteFavoritedMovieMutation.Data,DeleteFavoritedMovieMutation.Variables>
    }
    
    
    
    
    func addFavoritedActorMutationRef(
        
        
actorId: UUID

        ) -> MutationRef<AddFavoritedActorMutation.Data,AddFavoritedActorMutation.Variables>  {
        var variables = AddFavoritedActorMutation.Variables(actorId:actorId)
        
        let request = MutationRequest(operationName: "AddFavoritedActor", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:AddFavoritedActorMutation.Data.self)
        return ref as! MutationRef<AddFavoritedActorMutation.Data,AddFavoritedActorMutation.Variables>
    }
    
    
    
    
    func deleteFavoritedActorMutationRef(
        
        
actorId: UUID

        ) -> MutationRef<DeleteFavoritedActorMutation.Data,DeleteFavoritedActorMutation.Variables>  {
        var variables = DeleteFavoritedActorMutation.Variables(actorId:actorId)
        
        let request = MutationRequest(operationName: "DeleteFavoritedActor", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:DeleteFavoritedActorMutation.Data.self)
        return ref as! MutationRef<DeleteFavoritedActorMutation.Data,DeleteFavoritedActorMutation.Variables>
    }
    
    
    
    
    func addReviewMutationRef(
        
        
movieId: UUID
,
rating: Int
,
reviewText: String

        ) -> MutationRef<AddReviewMutation.Data,AddReviewMutation.Variables>  {
        var variables = AddReviewMutation.Variables(movieId:movieId,rating:rating,reviewText:reviewText)
        
        let request = MutationRequest(operationName: "AddReview", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:AddReviewMutation.Data.self)
        return ref as! MutationRef<AddReviewMutation.Data,AddReviewMutation.Variables>
    }
    
    
    
    
    func deleteReviewMutationRef(
        
        
movieId: UUID

        ) -> MutationRef<DeleteReviewMutation.Data,DeleteReviewMutation.Variables>  {
        var variables = DeleteReviewMutation.Variables(movieId:movieId)
        
        let request = MutationRequest(operationName: "DeleteReview", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:DeleteReviewMutation.Data.self)
        return ref as! MutationRef<DeleteReviewMutation.Data,DeleteReviewMutation.Variables>
    }
    
    
    
    
    func upsertUserMutationRef(
        
        
username: String

        ) -> MutationRef<UpsertUserMutation.Data,UpsertUserMutation.Variables>  {
        var variables = UpsertUserMutation.Variables(username:username)
        
        let request = MutationRequest(operationName: "UpsertUser", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:UpsertUserMutation.Data.self)
        return ref as! MutationRef<UpsertUserMutation.Data,UpsertUserMutation.Variables>
    }
    
    
    
    
    func updateMovieMutationRef(
        
        
id: UUID

        
        ,
        _ optionalVars: ((inout UpdateMovieMutation.Variables)->())? = nil
        ) -> MutationRef<UpdateMovieMutation.Data,UpdateMovieMutation.Variables>  {
        var variables = UpdateMovieMutation.Variables(id:id)
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = MutationRequest(operationName: "UpdateMovie", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:UpdateMovieMutation.Data.self)
        return ref as! MutationRef<UpdateMovieMutation.Data,UpdateMovieMutation.Variables>
    }
    
    
    
    
    func deleteMovieMutationRef(
        
        
id: UUID

        ) -> MutationRef<DeleteMovieMutation.Data,DeleteMovieMutation.Variables>  {
        var variables = DeleteMovieMutation.Variables(id:id)
        
        let request = MutationRequest(operationName: "DeleteMovie", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:DeleteMovieMutation.Data.self)
        return ref as! MutationRef<DeleteMovieMutation.Data,DeleteMovieMutation.Variables>
    }
    
    
    
    
    func deleteUnpopularMoviesMutationRef(
        
        
minRating: Double

        ) -> MutationRef<DeleteUnpopularMoviesMutation.Data,DeleteUnpopularMoviesMutation.Variables>  {
        var variables = DeleteUnpopularMoviesMutation.Variables(minRating:minRating)
        
        let request = MutationRequest(operationName: "DeleteUnpopularMovies", variables: variables)
        let ref = dataConnect.mutation(request: request, resultsDataType:DeleteUnpopularMoviesMutation.Data.self)
        return ref as! MutationRef<DeleteUnpopularMoviesMutation.Data,DeleteUnpopularMoviesMutation.Variables>
    }
    
    
    
    
    func listMoviesQueryRef(
        
        
        
        
        _ optionalVars: ((inout ListMoviesQuery.Variables)->())? = nil
        ) -> QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>  {
        var variables = ListMoviesQuery.Variables()
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = QueryRequest(operationName: "ListMovies", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:ListMoviesQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>
    }
    
    
    
    
    func listMoviesByGenreQueryRef(
        
        
genre: String

        ) -> QueryRefObservation<ListMoviesByGenreQuery.Data,ListMoviesByGenreQuery.Variables>  {
        var variables = ListMoviesByGenreQuery.Variables(genre:genre)
        
        let request = QueryRequest(operationName: "ListMoviesByGenre", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:ListMoviesByGenreQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListMoviesByGenreQuery.Data,ListMoviesByGenreQuery.Variables>
    }
    
    
    
    
    func getMovieByIdQueryRef(
        
        
id: UUID

        ) -> QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>  {
        var variables = GetMovieByIdQuery.Variables(id:id)
        
        let request = QueryRequest(operationName: "GetMovieById", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetMovieByIdQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>
    }
    
    
    
    
    func getActorByIdQueryRef(
        
        
id: UUID

        ) -> QueryRefObservation<GetActorByIdQuery.Data,GetActorByIdQuery.Variables>  {
        var variables = GetActorByIdQuery.Variables(id:id)
        
        let request = QueryRequest(operationName: "GetActorById", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetActorByIdQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetActorByIdQuery.Data,GetActorByIdQuery.Variables>
    }
    
    
    
    
    func getCurrentUserQueryRef(
        
        
        ) -> QueryRefObservation<GetCurrentUserQuery.Data,GetCurrentUserQuery.Variables>  {
        var variables = GetCurrentUserQuery.Variables()
        
        let request = QueryRequest(operationName: "GetCurrentUser", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetCurrentUserQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetCurrentUserQuery.Data,GetCurrentUserQuery.Variables>
    }
    
    
    
    
    func getIfFavoritedMovieQueryRef(
        
        
movieId: UUID

        ) -> QueryRefObservation<GetIfFavoritedMovieQuery.Data,GetIfFavoritedMovieQuery.Variables>  {
        var variables = GetIfFavoritedMovieQuery.Variables(movieId:movieId)
        
        let request = QueryRequest(operationName: "GetIfFavoritedMovie", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetIfFavoritedMovieQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetIfFavoritedMovieQuery.Data,GetIfFavoritedMovieQuery.Variables>
    }
    
    
    
    
    func getIfFavoritedActorQueryRef(
        
        
actorId: UUID

        ) -> QueryRefObservation<GetIfFavoritedActorQuery.Data,GetIfFavoritedActorQuery.Variables>  {
        var variables = GetIfFavoritedActorQuery.Variables(actorId:actorId)
        
        let request = QueryRequest(operationName: "GetIfFavoritedActor", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetIfFavoritedActorQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetIfFavoritedActorQuery.Data,GetIfFavoritedActorQuery.Variables>
    }
    
    
    
    
    func searchAllQueryRef(
        
        
minYear: Int
,
maxYear: Int
,
minRating: Double
,
maxRating: Double
,
genre: String

        
        ,
        _ optionalVars: ((inout SearchAllQuery.Variables)->())? = nil
        ) -> QueryRefObservation<SearchAllQuery.Data,SearchAllQuery.Variables>  {
        var variables = SearchAllQuery.Variables(minYear:minYear,maxYear:maxYear,minRating:minRating,maxRating:maxRating,genre:genre)
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = QueryRequest(operationName: "SearchAll", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:SearchAllQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<SearchAllQuery.Data,SearchAllQuery.Variables>
    }
    
    
    
    
    func searchMovieDescriptionUsingL2similarityQueryRef(
        
        
query: String

        ) -> QueryRefObservation<SearchMovieDescriptionUsingL2similarityQuery.Data,SearchMovieDescriptionUsingL2similarityQuery.Variables>  {
        var variables = SearchMovieDescriptionUsingL2similarityQuery.Variables(query:query)
        
        let request = QueryRequest(operationName: "SearchMovieDescriptionUsingL2Similarity", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:SearchMovieDescriptionUsingL2similarityQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<SearchMovieDescriptionUsingL2similarityQuery.Data,SearchMovieDescriptionUsingL2similarityQuery.Variables>
    }
    
    
    
    
    func listMoviesByPartialTitleQueryRef(
        
        
input: String

        ) -> QueryRefObservation<ListMoviesByPartialTitleQuery.Data,ListMoviesByPartialTitleQuery.Variables>  {
        var variables = ListMoviesByPartialTitleQuery.Variables(input:input)
        
        let request = QueryRequest(operationName: "ListMoviesByPartialTitle", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:ListMoviesByPartialTitleQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListMoviesByPartialTitleQuery.Data,ListMoviesByPartialTitleQuery.Variables>
    }
    
    
    
    
    func listMoviesByTagQueryRef(
        
        
tag: String

        ) -> QueryRefObservation<ListMoviesByTagQuery.Data,ListMoviesByTagQuery.Variables>  {
        var variables = ListMoviesByTagQuery.Variables(tag:tag)
        
        let request = QueryRequest(operationName: "ListMoviesByTag", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:ListMoviesByTagQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<ListMoviesByTagQuery.Data,ListMoviesByTagQuery.Variables>
    }
    
    
    
    
    func moviesByReleaseYearQueryRef(
        
        
        
        
        _ optionalVars: ((inout MoviesByReleaseYearQuery.Variables)->())? = nil
        ) -> QueryRefObservation<MoviesByReleaseYearQuery.Data,MoviesByReleaseYearQuery.Variables>  {
        var variables = MoviesByReleaseYearQuery.Variables()
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = QueryRequest(operationName: "MoviesByReleaseYear", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:MoviesByReleaseYearQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<MoviesByReleaseYearQuery.Data,MoviesByReleaseYearQuery.Variables>
    }
    
    
    
    
    func searchMovieOrQueryRef(
        
        
        
        
        _ optionalVars: ((inout SearchMovieOrQuery.Variables)->())? = nil
        ) -> QueryRefObservation<SearchMovieOrQuery.Data,SearchMovieOrQuery.Variables>  {
        var variables = SearchMovieOrQuery.Variables()
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = QueryRequest(operationName: "SearchMovieOr", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:SearchMovieOrQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<SearchMovieOrQuery.Data,SearchMovieOrQuery.Variables>
    }
    
    
    
    
    func searchMovieAndQueryRef(
        
        
        
        
        _ optionalVars: ((inout SearchMovieAndQuery.Variables)->())? = nil
        ) -> QueryRefObservation<SearchMovieAndQuery.Data,SearchMovieAndQuery.Variables>  {
        var variables = SearchMovieAndQuery.Variables()
        
        if let optionalVars {
            optionalVars(&variables)
        }
        
        let request = QueryRequest(operationName: "SearchMovieAnd", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:SearchMovieAndQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<SearchMovieAndQuery.Data,SearchMovieAndQuery.Variables>
    }
    
    
    
    
    func getFavoriteActorsQueryRef(
        
        
        ) -> QueryRefObservation<GetFavoriteActorsQuery.Data,GetFavoriteActorsQuery.Variables>  {
        var variables = GetFavoriteActorsQuery.Variables()
        
        let request = QueryRequest(operationName: "GetFavoriteActors", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetFavoriteActorsQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetFavoriteActorsQuery.Data,GetFavoriteActorsQuery.Variables>
    }
    
    
    
    
    func getUserFavoriteMoviesQueryRef(
        
        
        ) -> QueryRefObservation<GetUserFavoriteMoviesQuery.Data,GetUserFavoriteMoviesQuery.Variables>  {
        var variables = GetUserFavoriteMoviesQuery.Variables()
        
        let request = QueryRequest(operationName: "GetUserFavoriteMovies", variables: variables)
        let ref = dataConnect.query(request: request, resultsDataType:GetUserFavoriteMoviesQuery.Data.self, publisher: .observableMacro)
        return ref as! QueryRefObservation<GetUserFavoriteMoviesQuery.Data,GetUserFavoriteMoviesQuery.Variables>
    }
    
}






public enum CreateMovieMutation{

  public static let OperationName = "CreateMovie"

  public typealias Ref = MutationRef<CreateMovieMutation.Data,CreateMovieMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
title: String

  
        
        public var 
releaseYear: Int

  
        
        public var 
genre: String

  
        @OptionalVariable
        public var 
rating: Double?

  
        @OptionalVariable
        public var 
description: String?

  
        
        public var 
imageUrl: String

  
        @OptionalVariable
        public var 
tags: [String]?


    
    
    
    public init (
        
title: String
,
        
releaseYear: Int
,
        
genre: String
,
        
imageUrl: String

        
        
        ,
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        self.title = title
        self.releaseYear = releaseYear
        self.genre = genre
        self.imageUrl = imageUrl
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.title == rhs.title && 
              lhs.releaseYear == rhs.releaseYear && 
              lhs.genre == rhs.genre && 
              lhs.rating == rhs.rating && 
              lhs.description == rhs.description && 
              lhs.imageUrl == rhs.imageUrl && 
              lhs.tags == rhs.tags
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(title)
  
  hasher.combine(releaseYear)
  
  hasher.combine(genre)
  
  hasher.combine(rating)
  
  hasher.combine(description)
  
  hasher.combine(imageUrl)
  
  hasher.combine(tags)
  
}

    enum CodingKeys: String, CodingKey {
      
      case title
      
      case releaseYear
      
      case genre
      
      case rating
      
      case description
      
      case imageUrl
      
      case tags
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(title, forKey: .title, container: &container)
      
      
      
      try codecHelper.encode(releaseYear, forKey: .releaseYear, container: &container)
      
      
      
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      
      
      if $rating.isSet { 
      try codecHelper.encode(rating, forKey: .rating, container: &container)
      }
      
      if $description.isSet { 
      try codecHelper.encode(description, forKey: .description, container: &container)
      }
      
      
      try codecHelper.encode(imageUrl, forKey: .imageUrl, container: &container)
      
      
      if $tags.isSet { 
      try codecHelper.encode(tags, forKey: .tags, container: &container)
      }
      
    }

  }

  public struct Data: Decodable {



public var 
movie_insert: MovieKey

  }
}






public enum AddFavoritedMovieMutation{

  public static let OperationName = "AddFavoritedMovie"

  public typealias Ref = MutationRef<AddFavoritedMovieMutation.Data,AddFavoritedMovieMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
movieId: UUID


    
    
    
    public init (
        
movieId: UUID

        
        ) {
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

  public struct Data: Decodable {



public var 
favorite_movie_upsert: FavoriteMovieKey

  }
}






public enum DeleteFavoritedMovieMutation{

  public static let OperationName = "DeleteFavoritedMovie"

  public typealias Ref = MutationRef<DeleteFavoritedMovieMutation.Data,DeleteFavoritedMovieMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
movieId: UUID


    
    
    
    public init (
        
movieId: UUID

        
        ) {
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

  public struct Data: Decodable {



public var 
favorite_movie_delete: FavoriteMovieKey?

  }
}






public enum AddFavoritedActorMutation{

  public static let OperationName = "AddFavoritedActor"

  public typealias Ref = MutationRef<AddFavoritedActorMutation.Data,AddFavoritedActorMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
actorId: UUID


    
    
    
    public init (
        
actorId: UUID

        
        ) {
        self.actorId = actorId
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.actorId == rhs.actorId
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(actorId)
  
}

    enum CodingKeys: String, CodingKey {
      
      case actorId
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(actorId, forKey: .actorId, container: &container)
      
      
    }

  }

  public struct Data: Decodable {



public var 
favorite_actor_upsert: FavoriteActorKey

  }
}






public enum DeleteFavoritedActorMutation{

  public static let OperationName = "DeleteFavoritedActor"

  public typealias Ref = MutationRef<DeleteFavoritedActorMutation.Data,DeleteFavoritedActorMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
actorId: UUID


    
    
    
    public init (
        
actorId: UUID

        
        ) {
        self.actorId = actorId
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.actorId == rhs.actorId
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(actorId)
  
}

    enum CodingKeys: String, CodingKey {
      
      case actorId
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(actorId, forKey: .actorId, container: &container)
      
      
    }

  }

  public struct Data: Decodable {



public var 
favorite_actor_delete: FavoriteActorKey?

  }
}






public enum AddReviewMutation{

  public static let OperationName = "AddReview"

  public typealias Ref = MutationRef<AddReviewMutation.Data,AddReviewMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
movieId: UUID

  
        
        public var 
rating: Int

  
        
        public var 
reviewText: String


    
    
    
    public init (
        
movieId: UUID
,
        
rating: Int
,
        
reviewText: String

        
        ) {
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

  public struct Data: Decodable {



public var 
review_upsert: ReviewKey

  }
}






public enum DeleteReviewMutation{

  public static let OperationName = "DeleteReview"

  public typealias Ref = MutationRef<DeleteReviewMutation.Data,DeleteReviewMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
movieId: UUID


    
    
    
    public init (
        
movieId: UUID

        
        ) {
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

  public struct Data: Decodable {



public var 
review_delete: ReviewKey?

  }
}






public enum UpsertUserMutation{

  public static let OperationName = "UpsertUser"

  public typealias Ref = MutationRef<UpsertUserMutation.Data,UpsertUserMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
username: String


    
    
    
    public init (
        
username: String

        
        ) {
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

  public struct Data: Decodable {



public var 
user_upsert: UserKey

  }
}






public enum UpdateMovieMutation{

  public static let OperationName = "UpdateMovie"

  public typealias Ref = MutationRef<UpdateMovieMutation.Data,UpdateMovieMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
id: UUID

  
        @OptionalVariable
        public var 
title: String?

  
        @OptionalVariable
        public var 
releaseYear: Int?

  
        @OptionalVariable
        public var 
genre: String?

  
        @OptionalVariable
        public var 
rating: Double?

  
        @OptionalVariable
        public var 
description: String?

  
        @OptionalVariable
        public var 
imageUrl: String?

  
        @OptionalVariable
        public var 
tags: [String]?


    
    
    
    public init (
        
id: UUID

        
        
        ,
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        self.id = id
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.id == rhs.id && 
              lhs.title == rhs.title && 
              lhs.releaseYear == rhs.releaseYear && 
              lhs.genre == rhs.genre && 
              lhs.rating == rhs.rating && 
              lhs.description == rhs.description && 
              lhs.imageUrl == rhs.imageUrl && 
              lhs.tags == rhs.tags
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
  hasher.combine(title)
  
  hasher.combine(releaseYear)
  
  hasher.combine(genre)
  
  hasher.combine(rating)
  
  hasher.combine(description)
  
  hasher.combine(imageUrl)
  
  hasher.combine(tags)
  
}

    enum CodingKeys: String, CodingKey {
      
      case id
      
      case title
      
      case releaseYear
      
      case genre
      
      case rating
      
      case description
      
      case imageUrl
      
      case tags
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
      if $title.isSet { 
      try codecHelper.encode(title, forKey: .title, container: &container)
      }
      
      if $releaseYear.isSet { 
      try codecHelper.encode(releaseYear, forKey: .releaseYear, container: &container)
      }
      
      if $genre.isSet { 
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      }
      
      if $rating.isSet { 
      try codecHelper.encode(rating, forKey: .rating, container: &container)
      }
      
      if $description.isSet { 
      try codecHelper.encode(description, forKey: .description, container: &container)
      }
      
      if $imageUrl.isSet { 
      try codecHelper.encode(imageUrl, forKey: .imageUrl, container: &container)
      }
      
      if $tags.isSet { 
      try codecHelper.encode(tags, forKey: .tags, container: &container)
      }
      
    }

  }

  public struct Data: Decodable {



public var 
movie_update: MovieKey?

  }
}






public enum DeleteMovieMutation{

  public static let OperationName = "DeleteMovie"

  public typealias Ref = MutationRef<DeleteMovieMutation.Data,DeleteMovieMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
id: UUID


    
    
    
    public init (
        
id: UUID

        
        ) {
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

  public struct Data: Decodable {



public var 
movie_delete: MovieKey?

  }
}






public enum DeleteUnpopularMoviesMutation{

  public static let OperationName = "DeleteUnpopularMovies"

  public typealias Ref = MutationRef<DeleteUnpopularMoviesMutation.Data,DeleteUnpopularMoviesMutation.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
minRating: Double


    
    
    
    public init (
        
minRating: Double

        
        ) {
        self.minRating = minRating
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.minRating == rhs.minRating
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(minRating)
  
}

    enum CodingKeys: String, CodingKey {
      
      case minRating
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(minRating, forKey: .minRating, container: &container)
      
      
    }

  }

  public struct Data: Decodable {


public var 
movie_deleteMany: Int

  }
}






public enum ListMoviesQuery{

  public static let OperationName = "ListMovies"

  public typealias Ref = QueryRefObservation<ListMoviesQuery.Data,ListMoviesQuery.Variables>

  public struct Variables: OperationVariable {
  
        @OptionalVariable
        public var 
limit: Int?


    
    
    
    public init (
        
        
        
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.limit == rhs.limit
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(limit)
  
}

    enum CodingKeys: String, CodingKey {
      
      case limit
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      if $limit.isSet { 
      try codecHelper.encode(limit, forKey: .limit, container: &container)
      }
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
    
    self.description = try codecHelper.decode(String?.self, forKey: .description, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }
}






public enum ListMoviesByGenreQuery{

  public static let OperationName = "ListMoviesByGenre"

  public typealias Ref = QueryRefObservation<ListMoviesByGenreQuery.Data,ListMoviesByGenreQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
genre: String


    
    
    
    public init (
        
genre: String

        
        ) {
        self.genre = genre
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.genre == rhs.genre
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(genre)
  
}

    enum CodingKeys: String, CodingKey {
      
      case genre
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      
      
    }

  }

  public struct Data: Decodable {




public struct MovieMostPopular: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
imageUrl: String



public var 
rating: Double?



public var 
tags: [String]?


  
  public var movieMostPopularKey: MovieKey {
    return MovieKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: MovieMostPopular, rhs: MovieMostPopular) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case title
    
    case imageUrl
    
    case rating
    
    case tags
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
  }
}
public var 
mostPopular: [MovieMostPopular]





public struct MovieMostRecent: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
imageUrl: String



public var 
rating: Double?



public var 
tags: [String]?


  
  public var movieMostRecentKey: MovieKey {
    return MovieKey(
      
      id: id
    )
  }

  
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(id)
  
}
public static func == (lhs: MovieMostRecent, rhs: MovieMostRecent) -> Bool {
    
    return lhs.id == rhs.id 
        
  }

  

  
  enum CodingKeys: String, CodingKey {
    
    case id
    
    case title
    
    case imageUrl
    
    case rating
    
    case tags
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
  }
}
public var 
mostRecent: [MovieMostRecent]

  }
}






public enum GetMovieByIdQuery{

  public static let OperationName = "GetMovieById"

  public typealias Ref = QueryRefObservation<GetMovieByIdQuery.Data,GetMovieByIdQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
id: UUID


    
    
    
    public init (
        
id: UUID

        
        ) {
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

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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





public struct MovieMetadataMetadata: Decodable  {
  


public var 
director: String?


  

  
  enum CodingKeys: String, CodingKey {
    
    case director
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.director = try codecHelper.decode(String?.self, forKey: .director, container: &container)
    
    
  }
}
public var 
metadata: [MovieMetadataMetadata]





public struct ActorMainActors: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.name = try codecHelper.decode(String.self, forKey: .name, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
mainActors: [ActorMainActors]





public struct ActorSupportingActors: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.name = try codecHelper.decode(String.self, forKey: .name, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
supportingActors: [ActorSupportingActors]





public struct ReviewReviews: Decodable  {
  


public var 
id: UUID



public var 
reviewText: String?



public var 
reviewDate: LocalDate



public var 
rating: Int?





public struct User: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
    
    
    self.username = try codecHelper.decode(String.self, forKey: .username, container: &container)
    
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.reviewText = try codecHelper.decode(String?.self, forKey: .reviewText, container: &container)
    
    
    
    self.reviewDate = try codecHelper.decode(LocalDate.self, forKey: .reviewDate, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)
    
    
    
    self.user = try codecHelper.decode(User.self, forKey: .user, container: &container)
    
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.description = try codecHelper.decode(String?.self, forKey: .description, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
    self.metadata = try codecHelper.decode([MovieMetadataMetadata].self, forKey: .metadata, container: &container)
    
    
    self.mainActors = try codecHelper.decode([ActorMainActors].self, forKey: .mainActors, container: &container)
    
    
    self.supportingActors = try codecHelper.decode([ActorSupportingActors].self, forKey: .supportingActors, container: &container)
    
    
    self.reviews = try codecHelper.decode([ReviewReviews].self, forKey: .reviews, container: &container)
    
    
  }
}
public var 
movie: Movie?

  }
}






public enum GetActorByIdQuery{

  public static let OperationName = "GetActorById"

  public typealias Ref = QueryRefObservation<GetActorByIdQuery.Data,GetActorByIdQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
id: UUID


    
    
    
    public init (
        
id: UUID

        
        ) {
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

  public struct Data: Decodable {




public struct Actor: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
name: String



public var 
imageUrl: String





public struct MovieMainActors: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
mainActors: [MovieMainActors]





public struct MovieSupportingActors: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.name = try codecHelper.decode(String.self, forKey: .name, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    self.mainActors = try codecHelper.decode([MovieMainActors].self, forKey: .mainActors, container: &container)
    
    
    self.supportingActors = try codecHelper.decode([MovieSupportingActors].self, forKey: .supportingActors, container: &container)
    
    
  }
}
public var 
actor: Actor?

  }
}






public enum GetCurrentUserQuery{

  public static let OperationName = "GetCurrentUser"

  public typealias Ref = QueryRefObservation<GetCurrentUserQuery.Data,GetCurrentUserQuery.Variables>

  public struct Variables: OperationVariable {

    
    
  }

  public struct Data: Decodable {




public struct User: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: String



public var 
username: String





public struct ReviewReviews: Decodable  {
  


public var 
id: UUID



public var 
rating: Int?



public var 
reviewDate: LocalDate



public var 
reviewText: String?





public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)
    
    
    
    self.reviewDate = try codecHelper.decode(LocalDate.self, forKey: .reviewDate, container: &container)
    
    
    
    self.reviewText = try codecHelper.decode(String?.self, forKey: .reviewText, container: &container)
    
    
    
    self.movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
    
    
  }
}
public var 
reviews: [ReviewReviews]





public struct FavoriteMovieFavoriteMovies: Decodable  {
  




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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





public struct MovieMetadataMetadata: Decodable  {
  


public var 
director: String?


  

  
  enum CodingKeys: String, CodingKey {
    
    case director
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.director = try codecHelper.decode(String?.self, forKey: .director, container: &container)
    
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.description = try codecHelper.decode(String?.self, forKey: .description, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
    self.metadata = try codecHelper.decode([MovieMetadataMetadata].self, forKey: .metadata, container: &container)
    
    
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

    
    
    self.movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
    
    
  }
}
public var 
favoriteMovies: [FavoriteMovieFavoriteMovies]





public struct FavoriteActorFavoriteActors: Decodable  {
  




public struct Actor: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
name: String



public var 
imageUrl: String


  
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
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.name = try codecHelper.decode(String.self, forKey: .name, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
actor: Actor


  

  
  enum CodingKeys: String, CodingKey {
    
    case actor
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.actor = try codecHelper.decode(Actor.self, forKey: .actor, container: &container)
    
    
  }
}
public var 
favoriteActors: [FavoriteActorFavoriteActors]


  
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
    
    case favoriteActors
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
    
    
    self.username = try codecHelper.decode(String.self, forKey: .username, container: &container)
    
    
    self.reviews = try codecHelper.decode([ReviewReviews].self, forKey: .reviews, container: &container)
    
    
    self.favoriteMovies = try codecHelper.decode([FavoriteMovieFavoriteMovies].self, forKey: .favoriteMovies, container: &container)
    
    
    self.favoriteActors = try codecHelper.decode([FavoriteActorFavoriteActors].self, forKey: .favoriteActors, container: &container)
    
    
  }
}
public var 
user: User?

  }
}






public enum GetIfFavoritedMovieQuery{

  public static let OperationName = "GetIfFavoritedMovie"

  public typealias Ref = QueryRefObservation<GetIfFavoritedMovieQuery.Data,GetIfFavoritedMovieQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
movieId: UUID


    
    
    
    public init (
        
movieId: UUID

        
        ) {
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

  public struct Data: Decodable {




public struct FavoriteMovie: Decodable  {
  


public var 
movieId: UUID


  

  
  enum CodingKeys: String, CodingKey {
    
    case movieId
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.movieId = try codecHelper.decode(UUID.self, forKey: .movieId, container: &container)
    
    
  }
}
public var 
favorite_movie: FavoriteMovie?

  }
}






public enum GetIfFavoritedActorQuery{

  public static let OperationName = "GetIfFavoritedActor"

  public typealias Ref = QueryRefObservation<GetIfFavoritedActorQuery.Data,GetIfFavoritedActorQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
actorId: UUID


    
    
    
    public init (
        
actorId: UUID

        
        ) {
        self.actorId = actorId
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.actorId == rhs.actorId
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(actorId)
  
}

    enum CodingKeys: String, CodingKey {
      
      case actorId
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(actorId, forKey: .actorId, container: &container)
      
      
    }

  }

  public struct Data: Decodable {




public struct FavoriteActor: Decodable  {
  


public var 
actorId: UUID


  

  
  enum CodingKeys: String, CodingKey {
    
    case actorId
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.actorId = try codecHelper.decode(UUID.self, forKey: .actorId, container: &container)
    
    
  }
}
public var 
favorite_actor: FavoriteActor?

  }
}






public enum SearchAllQuery{

  public static let OperationName = "SearchAll"

  public typealias Ref = QueryRefObservation<SearchAllQuery.Data,SearchAllQuery.Variables>

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


    
    
    
    public init (
        
minYear: Int
,
        
maxYear: Int
,
        
minRating: Double
,
        
maxRating: Double
,
        
genre: String

        
        
        ,
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
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

  public struct Data: Decodable {




public struct MovieMoviesMatchingTitle: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
moviesMatchingTitle: [MovieMoviesMatchingTitle]





public struct MovieMoviesMatchingDescription: Decodable ,Hashable, Equatable, Identifiable {
  


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
public static func == (lhs: MovieMoviesMatchingDescription, rhs: MovieMoviesMatchingDescription) -> Bool {
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
moviesMatchingDescription: [MovieMoviesMatchingDescription]





public struct ActorActorsMatchingName: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.name = try codecHelper.decode(String.self, forKey: .name, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
actorsMatchingName: [ActorActorsMatchingName]





public struct ReviewReviewsMatchingText: Decodable  {
  


public var 
id: UUID



public var 
rating: Int?



public var 
reviewText: String?



public var 
reviewDate: LocalDate





public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
  }
}
public var 
movie: Movie





public struct User: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
    
    
    self.username = try codecHelper.decode(String.self, forKey: .username, container: &container)
    
    
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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Int?.self, forKey: .rating, container: &container)
    
    
    
    self.reviewText = try codecHelper.decode(String?.self, forKey: .reviewText, container: &container)
    
    
    
    self.reviewDate = try codecHelper.decode(LocalDate.self, forKey: .reviewDate, container: &container)
    
    
    
    self.movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
    
    
    
    self.user = try codecHelper.decode(User.self, forKey: .user, container: &container)
    
    
  }
}
public var 
reviewsMatchingText: [ReviewReviewsMatchingText]

  }
}






public enum SearchMovieDescriptionUsingL2similarityQuery{

  public static let OperationName = "SearchMovieDescriptionUsingL2Similarity"

  public typealias Ref = QueryRefObservation<SearchMovieDescriptionUsingL2similarityQuery.Data,SearchMovieDescriptionUsingL2similarityQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
query: String


    
    
    
    public init (
        
query: String

        
        ) {
        self.query = query
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.query == rhs.query
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(query)
  
}

    enum CodingKeys: String, CodingKey {
      
      case query
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(query, forKey: .query, container: &container)
      
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
description: String?



public var 
tags: [String]?



public var 
rating: Double?



public var 
imageUrl: String


  
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
    
    case description
    
    case tags
    
    case rating
    
    case imageUrl
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.description = try codecHelper.decode(String?.self, forKey: .description, container: &container)
    
    
    self.tags = try codecHelper.decode([String].self, forKey: .tags, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
movies_descriptionEmbedding_similarity: [Movie]

  }
}






public enum ListMoviesByPartialTitleQuery{

  public static let OperationName = "ListMoviesByPartialTitle"

  public typealias Ref = QueryRefObservation<ListMoviesByPartialTitleQuery.Data,ListMoviesByPartialTitleQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
input: String


    
    
    
    public init (
        
input: String

        
        ) {
        self.input = input
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.input == rhs.input
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(input)
  
}

    enum CodingKeys: String, CodingKey {
      
      case input
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(input, forKey: .input, container: &container)
      
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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
    
    case rating
    
    case imageUrl
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }
}






public enum ListMoviesByTagQuery{

  public static let OperationName = "ListMoviesByTag"

  public typealias Ref = QueryRefObservation<ListMoviesByTagQuery.Data,ListMoviesByTagQuery.Variables>

  public struct Variables: OperationVariable {
  
        
        public var 
tag: String


    
    
    
    public init (
        
tag: String

        
        ) {
        self.tag = tag
        

        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.tag == rhs.tag
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(tag)
  
}

    enum CodingKeys: String, CodingKey {
      
      case tag
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(tag, forKey: .tag, container: &container)
      
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
title: String



public var 
imageUrl: String



public var 
genre: String?



public var 
rating: Double?


  
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
    
    case genre
    
    case rating
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }
}






public enum MoviesByReleaseYearQuery{

  public static let OperationName = "MoviesByReleaseYear"

  public typealias Ref = QueryRefObservation<MoviesByReleaseYearQuery.Data,MoviesByReleaseYearQuery.Variables>

  public struct Variables: OperationVariable {
  
        @OptionalVariable
        public var 
min: Int?

  
        @OptionalVariable
        public var 
max: Int?


    
    
    
    public init (
        
        
        
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.min == rhs.min && 
              lhs.max == rhs.max
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(min)
  
  hasher.combine(max)
  
}

    enum CodingKeys: String, CodingKey {
      
      case min
      
      case max
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      if $min.isSet { 
      try codecHelper.encode(min, forKey: .min, container: &container)
      }
      
      if $max.isSet { 
      try codecHelper.encode(max, forKey: .max, container: &container)
      }
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
rating: Double?



public var 
title: String



public var 
imageUrl: String


  
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
    
    case rating
    
    case title
    
    case imageUrl
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }
}






public enum SearchMovieOrQuery{

  public static let OperationName = "SearchMovieOr"

  public typealias Ref = QueryRefObservation<SearchMovieOrQuery.Data,SearchMovieOrQuery.Variables>

  public struct Variables: OperationVariable {
  
        @OptionalVariable
        public var 
minRating: Double?

  
        @OptionalVariable
        public var 
maxRating: Double?

  
        @OptionalVariable
        public var 
genre: String?

  
        @OptionalVariable
        public var 
tag: String?

  
        @OptionalVariable
        public var 
input: String?


    
    
    
    public init (
        
        
        
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.minRating == rhs.minRating && 
              lhs.maxRating == rhs.maxRating && 
              lhs.genre == rhs.genre && 
              lhs.tag == rhs.tag && 
              lhs.input == rhs.input
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(minRating)
  
  hasher.combine(maxRating)
  
  hasher.combine(genre)
  
  hasher.combine(tag)
  
  hasher.combine(input)
  
}

    enum CodingKeys: String, CodingKey {
      
      case minRating
      
      case maxRating
      
      case genre
      
      case tag
      
      case input
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      if $minRating.isSet { 
      try codecHelper.encode(minRating, forKey: .minRating, container: &container)
      }
      
      if $maxRating.isSet { 
      try codecHelper.encode(maxRating, forKey: .maxRating, container: &container)
      }
      
      if $genre.isSet { 
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      }
      
      if $tag.isSet { 
      try codecHelper.encode(tag, forKey: .tag, container: &container)
      }
      
      if $input.isSet { 
      try codecHelper.encode(input, forKey: .input, container: &container)
      }
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
rating: Double?



public var 
title: String



public var 
imageUrl: String


  
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
    
    case rating
    
    case title
    
    case imageUrl
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }
}






public enum SearchMovieAndQuery{

  public static let OperationName = "SearchMovieAnd"

  public typealias Ref = QueryRefObservation<SearchMovieAndQuery.Data,SearchMovieAndQuery.Variables>

  public struct Variables: OperationVariable {
  
        @OptionalVariable
        public var 
minRating: Double?

  
        @OptionalVariable
        public var 
maxRating: Double?

  
        @OptionalVariable
        public var 
genre: String?

  
        @OptionalVariable
        public var 
tag: String?

  
        @OptionalVariable
        public var 
input: String?


    
    
    
    public init (
        
        
        
        _ optionalVars: ((inout Variables)->())? = nil
        ) {
        

        
        if let optionalVars {
            optionalVars(&self)
        }
        
    }

    public static func == (lhs: Variables, rhs: Variables) -> Bool {
      
        return lhs.minRating == rhs.minRating && 
              lhs.maxRating == rhs.maxRating && 
              lhs.genre == rhs.genre && 
              lhs.tag == rhs.tag && 
              lhs.input == rhs.input
              
    }

    
public func hash(into hasher: inout Hasher) {
  
  hasher.combine(minRating)
  
  hasher.combine(maxRating)
  
  hasher.combine(genre)
  
  hasher.combine(tag)
  
  hasher.combine(input)
  
}

    enum CodingKeys: String, CodingKey {
      
      case minRating
      
      case maxRating
      
      case genre
      
      case tag
      
      case input
      
    }

    public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      if $minRating.isSet { 
      try codecHelper.encode(minRating, forKey: .minRating, container: &container)
      }
      
      if $maxRating.isSet { 
      try codecHelper.encode(maxRating, forKey: .maxRating, container: &container)
      }
      
      if $genre.isSet { 
      try codecHelper.encode(genre, forKey: .genre, container: &container)
      }
      
      if $tag.isSet { 
      try codecHelper.encode(tag, forKey: .tag, container: &container)
      }
      
      if $input.isSet { 
      try codecHelper.encode(input, forKey: .input, container: &container)
      }
      
    }

  }

  public struct Data: Decodable {




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
rating: Double?



public var 
title: String



public var 
imageUrl: String


  
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
    
    case rating
    
    case title
    
    case imageUrl
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
movies: [Movie]

  }
}






public enum GetFavoriteActorsQuery{

  public static let OperationName = "GetFavoriteActors"

  public typealias Ref = QueryRefObservation<GetFavoriteActorsQuery.Data,GetFavoriteActorsQuery.Variables>

  public struct Variables: OperationVariable {

    
    
  }

  public struct Data: Decodable {




public struct User: Decodable  {
  




public struct FavoriteActor: Decodable  {
  




public struct Actor: Decodable ,Hashable, Equatable, Identifiable {
  


public var 
id: UUID



public var 
name: String



public var 
imageUrl: String


  
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
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.name = try codecHelper.decode(String.self, forKey: .name, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
  }
}
public var 
actor: Actor


  

  
  enum CodingKeys: String, CodingKey {
    
    case actor
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    
    self.actor = try codecHelper.decode(Actor.self, forKey: .actor, container: &container)
    
    
  }
}
public var 
favorite_actors_on_user: [FavoriteActor]


  

  
  enum CodingKeys: String, CodingKey {
    
    case favorite_actors_on_user
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.favorite_actors_on_user = try codecHelper.decode([FavoriteActor].self, forKey: .favorite_actors_on_user, container: &container)
    
    
  }
}
public var 
user: User?

  }
}






public enum GetUserFavoriteMoviesQuery{

  public static let OperationName = "GetUserFavoriteMovies"

  public typealias Ref = QueryRefObservation<GetUserFavoriteMoviesQuery.Data,GetUserFavoriteMoviesQuery.Variables>

  public struct Variables: OperationVariable {

    
    
  }

  public struct Data: Decodable {




public struct User: Decodable  {
  




public struct FavoriteMovie: Decodable  {
  




public struct Movie: Decodable ,Hashable, Equatable, Identifiable {
  


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

    
    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
    
    
    self.title = try codecHelper.decode(String.self, forKey: .title, container: &container)
    
    
    
    self.genre = try codecHelper.decode(String?.self, forKey: .genre, container: &container)
    
    
    
    self.imageUrl = try codecHelper.decode(String.self, forKey: .imageUrl, container: &container)
    
    
    
    self.releaseYear = try codecHelper.decode(Int?.self, forKey: .releaseYear, container: &container)
    
    
    
    self.rating = try codecHelper.decode(Double?.self, forKey: .rating, container: &container)
    
    
    
    self.description = try codecHelper.decode(String?.self, forKey: .description, container: &container)
    
    
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

    
    
    self.movie = try codecHelper.decode(Movie.self, forKey: .movie, container: &container)
    
    
  }
}
public var 
favorite_movies_on_user: [FavoriteMovie]


  

  
  enum CodingKeys: String, CodingKey {
    
    case favorite_movies_on_user
    
  }

  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.favorite_movies_on_user = try codecHelper.decode([FavoriteMovie].self, forKey: .favorite_movies_on_user, container: &container)
    
    
  }
}
public var 
user: User?

  }
}


