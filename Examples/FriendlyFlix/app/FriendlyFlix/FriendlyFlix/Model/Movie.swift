//
// Movie.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 30.09.24.
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
import SwiftUI

struct Movie: Identifiable, Hashable {
  let id = UUID()
  let title: String
  let subtitle: String
  let image: ImageResource
  let releaseYear: Int?
  let imageUrl: String
}

extension Movie: Mockable {
  static var mockList: [Movie] = [
    .init(
      title: "The Hitchhiker's Guide to the Galaxy",
      subtitle:
        "Mere seconds before the Earth is to be demolished by an alien construction crew, Arthur Dent is swept off the planet by his friend Ford Prefect, a researcher penning a new edition of \"The Hitchhiker's Guide to the Galaxy.\"",
      image: .hitchhiker,
      releaseYear: 2005,
      imageUrl: "https://image.tmdb.org/t/p/w1280/yr9A3KGQlxBh3yW0cmglsr8aMIz.jpg"
    ),
    .init(
      title: "Interstellar",
      subtitle:
        "The adventures of a group of explorers who make use of a newly discovered wormhole to surpass the limitations on human space travel and conquer the vast distances involved in an interstellar voyage.",
      image: .interstellar,
      releaseYear: 2005,
      imageUrl: "https://image.tmdb.org/t/p/w1280/gEU2QniE6E77NI6lCU6MxlNBvIx.jpg"
    ),
    .init(
      title: "The Matrix",
      subtitle:
        "Set in the 22nd century, The Matrix tells the story of a computer hacker who joins a group of underground insurgents fighting the vast and powerful computers who now rule the earth.",
      image: .matrix,
      releaseYear: 1999,
      imageUrl: "https://image.tmdb.org/t/p/w1280/f89U3ADr1oiB1s9GkdPOEpXUk5H.jpg"
    ),
    .init(
      title: "Titanic",
      subtitle:
        "101-year-old Rose DeWitt Bukater tells the story of her life aboard the Titanic, 84 years later. A young Rose boards the ship with her mother and fiancé. Meanwhile, Jack Dawson and Fabrizio De Rossi win third-class tickets aboard the ship. Rose tells the whole story from Titanic's departure through to its death—on its first and last voyage—on April 15, 1912.",
      image: .titanic,
      releaseYear: 1998,
      imageUrl: "https://image.tmdb.org/t/p/w1280/tuvoTDlqaLm7hFUROR6u0OUtwCW.jpg"
    ),
    .init(
      title: "Slow Horses",
      subtitle:
        "Follow a dysfunctional team of MI5 agents—and their obnoxious boss, the notorious Jackson Lamb—as they navigate the espionage world's smoke and mirrors to defend England from sinister forces.",
      image: .slowhorses,
      releaseYear: 2022,
      imageUrl: "https://image.tmdb.org/t/p/w1280/dnpatlJrEPiDSn5fzgzvxtiSnMo.jpg"
    ),
    .init(
      title: "Tomorrow Never Dies",
      subtitle:
        "A deranged media mogul is staging international incidents to pit the world's superpowers against each other. Now James Bond must take on this evil mastermind in an adrenaline-charged battle to end his reign of terror and prevent global pandemonium.",
      image: .tomorrowneverdies,
      releaseYear: 1997,
      imageUrl: "https://image.tmdb.org/t/p/w1280/bkEJA84af63IpaOPP4CbbgTiTlL.jpg"
    ),
    .init(
      title: "The man from U.N.C.L.E.",
      subtitle:
        "At the height of the Cold War, a mysterious criminal organization plans to use nuclear weapons and technology to upset the fragile balance of power between the United States and Soviet Union. CIA agent Napoleon Solo and KGB agent Illya Kuryakin are forced to put aside their hostilities and work together to stop the evildoers in their tracks. The duo's only lead is the daughter of a missing German scientist, whom they must find soon to prevent a global catastrophe.",
      image: .uncle,
      releaseYear: 2015,
      imageUrl: "https://image.tmdb.org/t/p/w1280/nFiu4lLhkyf1amaGaN6pNoUn5Ly.jpg"
    ),
  ]

  static var featured = Array<Movie>(mockList.filter { $0.title.contains("The")})
  static var topMovies = Array<Movie>(mockList.prefix(3))
  static var watchList = Array<Movie>(mockList.suffix(5))

//  static var featured = Array<Movie>([mockList[0]])
//  static var topMovies = Array<Movie>([mockList[1]])
//  static var watchList = Array<Movie>([mockList[2]])


}

