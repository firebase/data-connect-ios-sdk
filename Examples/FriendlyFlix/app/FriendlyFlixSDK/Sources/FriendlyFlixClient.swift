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
import Foundation

public extension DataConnect {
  static var friendlyFlixConnector: FriendlyFlixConnector = {
    let dc = DataConnect.dataConnect(
      connectorConfig: FriendlyFlixConnector.connectorConfig,
      callerSDKType: .generated
    )
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
}
