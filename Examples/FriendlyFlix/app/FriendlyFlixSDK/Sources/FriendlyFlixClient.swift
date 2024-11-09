
import Foundation

import FirebaseCore
import FirebaseDataConnect

public extension DataConnect {
  static let friendlyFlixConnector: FriendlyFlixConnector = {
    let dc = DataConnect.dataConnect(
      connectorConfig: FriendlyFlixConnector.connectorConfig,
      callerSDKType: .generated
    )
    return FriendlyFlixConnector(dataConnect: dc)
  }()
}

public class FriendlyFlixConnector {
  let dataConnect: DataConnect

  public static let connectorConfig = ConnectorConfig(
    serviceId: "dataconnect",
    location: "us-central1",
    connector: "friendly-flix"
  )

  init(dataConnect: DataConnect) {
    self.dataConnect = dataConnect

    // init operations
    upsertUserMutation = UpsertUserMutation(dataConnect: dataConnect)
    addFavoritedMovieMutation = AddFavoritedMovieMutation(dataConnect: dataConnect)
    deleteFavoritedMovieMutation = DeleteFavoritedMovieMutation(dataConnect: dataConnect)
    addReviewMutation = AddReviewMutation(dataConnect: dataConnect)
    updateReviewMutation = UpdateReviewMutation(dataConnect: dataConnect)
    deleteReviewMutation = DeleteReviewMutation(dataConnect: dataConnect)
    listMoviesQuery = ListMoviesQuery(dataConnect: dataConnect)
    getMovieByIdQuery = GetMovieByIdQuery(dataConnect: dataConnect)
    getActorByIdQuery = GetActorByIdQuery(dataConnect: dataConnect)
    getCurrentUserQuery = GetCurrentUserQuery(dataConnect: dataConnect)
    getIfFavoritedMovieQuery = GetIfFavoritedMovieQuery(dataConnect: dataConnect)
    searchAllQuery = SearchAllQuery(dataConnect: dataConnect)
    listMoviesByPartialTitleQuery = ListMoviesByPartialTitleQuery(dataConnect: dataConnect)
    getUserFavoriteMoviesQuery = GetUserFavoriteMoviesQuery(dataConnect: dataConnect)
  }

  public func useEmulator(host: String = DataConnect.EmulatorDefaults.host,
                          port: Int = DataConnect.EmulatorDefaults.port) {
    dataConnect.useEmulator(host: host, port: port)
  }

  // MARK: Operations

  public let upsertUserMutation: UpsertUserMutation
  public let addFavoritedMovieMutation: AddFavoritedMovieMutation
  public let deleteFavoritedMovieMutation: DeleteFavoritedMovieMutation
  public let addReviewMutation: AddReviewMutation
  public let updateReviewMutation: UpdateReviewMutation
  public let deleteReviewMutation: DeleteReviewMutation
  public let listMoviesQuery: ListMoviesQuery
  public let getMovieByIdQuery: GetMovieByIdQuery
  public let getActorByIdQuery: GetActorByIdQuery
  public let getCurrentUserQuery: GetCurrentUserQuery
  public let getIfFavoritedMovieQuery: GetIfFavoritedMovieQuery
  public let searchAllQuery: SearchAllQuery
  public let listMoviesByPartialTitleQuery: ListMoviesByPartialTitleQuery
  public let getUserFavoriteMoviesQuery: GetUserFavoriteMoviesQuery
}
