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

extension Movie {
  init(from: ListMoviesQuery.Data.Movie) {
    self.id = from.id
    self.title = from.title
    self.description = from.description ?? ""
    self.releaseYear = from.releaseYear
    self.rating = from.rating
    self.imageUrl = from.imageUrl
  }

  init(from: ListMoviesByPartialTitleQuery.Data.Movie) {
    self.id = from.id
    self.title = from.title
    self.description = from.description ?? ""
    self.releaseYear = from.releaseYear
    self.rating = from.rating
    self.imageUrl = from.imageUrl
  }

  init(from: GetUserFavoriteMoviesQuery.Data.User.FavoriteMovieFavoriteMovies) {
    self.id = from.movie.id
    self.title = from.movie.title
    self.description = from.movie.description ?? ""
    self.releaseYear = from.movie.releaseYear
    self.rating = from.movie.rating
    self.imageUrl = from.movie.imageUrl
  }
}

