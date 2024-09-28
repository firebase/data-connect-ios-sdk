import FirebaseDataConnect
import Foundation

public extension DataConnect {
  static var friendlyFlixConnector: FriendlyFlixConnector = {
    let dc = DataConnect.dataConnect(connectorConfig: FriendlyFlixConnector.connectorConfig)
    return FriendlyFlixConnector(dataConnect: dc)
  }()
}

public class FriendlyFlixConnector {
  var dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(
    serviceId: "friendly-flix-service",
    location: "us-central1",
    connector: "friendly-flix"
  )

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect

    // init operations
    createMovieMutation = CreateMovieMutation(dataConnect: dataConnect)
    addFavoritedMovieMutation = AddFavoritedMovieMutation(dataConnect: dataConnect)
    deleteFavoritedMovieMutation = DeleteFavoritedMovieMutation(dataConnect: dataConnect)
    addFavoritedActorMutation = AddFavoritedActorMutation(dataConnect: dataConnect)
    deleteFavoritedActorMutation = DeleteFavoritedActorMutation(dataConnect: dataConnect)
    addReviewMutation = AddReviewMutation(dataConnect: dataConnect)
    deleteReviewMutation = DeleteReviewMutation(dataConnect: dataConnect)
    upsertUserMutation = UpsertUserMutation(dataConnect: dataConnect)
    updateMovieMutation = UpdateMovieMutation(dataConnect: dataConnect)
    deleteMovieMutation = DeleteMovieMutation(dataConnect: dataConnect)
    deleteUnpopularMoviesMutation = DeleteUnpopularMoviesMutation(dataConnect: dataConnect)
    listMoviesQuery = ListMoviesQuery(dataConnect: dataConnect)
    listMoviesByGenreQuery = ListMoviesByGenreQuery(dataConnect: dataConnect)
    getMovieByIdQuery = GetMovieByIdQuery(dataConnect: dataConnect)
    getActorByIdQuery = GetActorByIdQuery(dataConnect: dataConnect)
    getCurrentUserQuery = GetCurrentUserQuery(dataConnect: dataConnect)
    getIfFavoritedMovieQuery = GetIfFavoritedMovieQuery(dataConnect: dataConnect)
    getIfFavoritedActorQuery = GetIfFavoritedActorQuery(dataConnect: dataConnect)
    searchAllQuery = SearchAllQuery(dataConnect: dataConnect)
    searchMovieDescriptionUsingL2similarityQuery =
      SearchMovieDescriptionUsingL2similarityQuery(dataConnect: dataConnect)
    listMoviesByPartialTitleQuery = ListMoviesByPartialTitleQuery(dataConnect: dataConnect)
    listMoviesByTagQuery = ListMoviesByTagQuery(dataConnect: dataConnect)
    moviesByReleaseYearQuery = MoviesByReleaseYearQuery(dataConnect: dataConnect)
    searchMovieOrQuery = SearchMovieOrQuery(dataConnect: dataConnect)
    searchMovieAndQuery = SearchMovieAndQuery(dataConnect: dataConnect)
    getFavoriteActorsQuery = GetFavoriteActorsQuery(dataConnect: dataConnect)
    getUserFavoriteMoviesQuery = GetUserFavoriteMoviesQuery(dataConnect: dataConnect)
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host,
                          port: Int = DataConnect.EmulatorDefaults.port) {
    dataConnect.useEmulator(host: host, port: port)
  }

  // MARK: Operations

  public let createMovieMutation: CreateMovieMutation
  public let addFavoritedMovieMutation: AddFavoritedMovieMutation
  public let deleteFavoritedMovieMutation: DeleteFavoritedMovieMutation
  public let addFavoritedActorMutation: AddFavoritedActorMutation
  public let deleteFavoritedActorMutation: DeleteFavoritedActorMutation
  public let addReviewMutation: AddReviewMutation
  public let deleteReviewMutation: DeleteReviewMutation
  public let upsertUserMutation: UpsertUserMutation
  public let updateMovieMutation: UpdateMovieMutation
  public let deleteMovieMutation: DeleteMovieMutation
  public let deleteUnpopularMoviesMutation: DeleteUnpopularMoviesMutation
  public let listMoviesQuery: ListMoviesQuery
  public let listMoviesByGenreQuery: ListMoviesByGenreQuery
  public let getMovieByIdQuery: GetMovieByIdQuery
  public let getActorByIdQuery: GetActorByIdQuery
  public let getCurrentUserQuery: GetCurrentUserQuery
  public let getIfFavoritedMovieQuery: GetIfFavoritedMovieQuery
  public let getIfFavoritedActorQuery: GetIfFavoritedActorQuery
  public let searchAllQuery: SearchAllQuery
  public let searchMovieDescriptionUsingL2similarityQuery: SearchMovieDescriptionUsingL2similarityQuery
  public let listMoviesByPartialTitleQuery: ListMoviesByPartialTitleQuery
  public let listMoviesByTagQuery: ListMoviesByTagQuery
  public let moviesByReleaseYearQuery: MoviesByReleaseYearQuery
  public let searchMovieOrQuery: SearchMovieOrQuery
  public let searchMovieAndQuery: SearchMovieAndQuery
  public let getFavoriteActorsQuery: GetFavoriteActorsQuery
  public let getUserFavoriteMoviesQuery: GetUserFavoriteMoviesQuery
}
