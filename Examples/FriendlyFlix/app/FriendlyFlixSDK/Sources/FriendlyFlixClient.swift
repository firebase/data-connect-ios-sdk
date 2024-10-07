import Foundation
import FirebaseDataConnect







public extension DataConnect {

  static var friendlyFlixConnector: FriendlyFlixConnector = {
    let dc = DataConnect.dataConnect(connectorConfig: FriendlyFlixConnector.connectorConfig, callerSDKType: .generated)
    return FriendlyFlixConnector(dataConnect: dc)
  }()

}

public class FriendlyFlixConnector {

  var dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(serviceId: "friendly-flix-service", location: "us-central1", connector: "friendly-flix")

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect

    // init operations 
    self.createMovieMutation = CreateMovieMutation(dataConnect: dataConnect)
    self.addFavoritedMovieMutation = AddFavoritedMovieMutation(dataConnect: dataConnect)
    self.deleteFavoritedMovieMutation = DeleteFavoritedMovieMutation(dataConnect: dataConnect)
    self.addFavoritedActorMutation = AddFavoritedActorMutation(dataConnect: dataConnect)
    self.deleteFavoritedActorMutation = DeleteFavoritedActorMutation(dataConnect: dataConnect)
    self.addReviewMutation = AddReviewMutation(dataConnect: dataConnect)
    self.deleteReviewMutation = DeleteReviewMutation(dataConnect: dataConnect)
    self.upsertUserMutation = UpsertUserMutation(dataConnect: dataConnect)
    self.updateMovieMutation = UpdateMovieMutation(dataConnect: dataConnect)
    self.deleteMovieMutation = DeleteMovieMutation(dataConnect: dataConnect)
    self.deleteUnpopularMoviesMutation = DeleteUnpopularMoviesMutation(dataConnect: dataConnect)
    self.listMoviesQuery = ListMoviesQuery(dataConnect: dataConnect)
    self.listMoviesByGenreQuery = ListMoviesByGenreQuery(dataConnect: dataConnect)
    self.getMovieByIdQuery = GetMovieByIdQuery(dataConnect: dataConnect)
    self.getActorByIdQuery = GetActorByIdQuery(dataConnect: dataConnect)
    self.getCurrentUserQuery = GetCurrentUserQuery(dataConnect: dataConnect)
    self.getIfFavoritedMovieQuery = GetIfFavoritedMovieQuery(dataConnect: dataConnect)
    self.getIfFavoritedActorQuery = GetIfFavoritedActorQuery(dataConnect: dataConnect)
    self.searchAllQuery = SearchAllQuery(dataConnect: dataConnect)
    self.searchMovieDescriptionUsingL2similarityQuery = SearchMovieDescriptionUsingL2similarityQuery(dataConnect: dataConnect)
    self.listMoviesByPartialTitleQuery = ListMoviesByPartialTitleQuery(dataConnect: dataConnect)
    self.listMoviesByTagQuery = ListMoviesByTagQuery(dataConnect: dataConnect)
    self.moviesByReleaseYearQuery = MoviesByReleaseYearQuery(dataConnect: dataConnect)
    self.searchMovieOrQuery = SearchMovieOrQuery(dataConnect: dataConnect)
    self.searchMovieAndQuery = SearchMovieAndQuery(dataConnect: dataConnect)
    self.getFavoriteActorsQuery = GetFavoriteActorsQuery(dataConnect: dataConnect)
    self.getUserFavoriteMoviesQuery = GetUserFavoriteMoviesQuery(dataConnect: dataConnect)
    
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host, port: Int = DataConnect.EmulatorDefaults.port) {
    self.dataConnect.useEmulator(host: host, port: port)
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
