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

import FirebaseDataConnect



public struct ActorKey {
  
  public private(set) var id: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension ActorKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension ActorKey : Equatable {
  public static func == (lhs: ActorKey, rhs: ActorKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension ActorKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension ActorKey : Sendable {}



public struct FavoriteMovieKey {
  
  public private(set) var userId: String
  
  public private(set) var movieId: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  userId
    
    case  movieId
    
  }
}

extension FavoriteMovieKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.userId = try codecHelper.decode(String.self, forKey: .userId, container: &container)
    
    self.movieId = try codecHelper.decode(UUID.self, forKey: .movieId, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(userId, forKey: .userId, container: &container)
      
      
      
      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
      
      
    }
}

extension FavoriteMovieKey : Equatable {
  public static func == (lhs: FavoriteMovieKey, rhs: FavoriteMovieKey) -> Bool {
    
    if lhs.userId != rhs.userId {
      return false
    }
    
    if lhs.movieId != rhs.movieId {
      return false
    }
    
    return true
  }
}

extension FavoriteMovieKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.userId)
    
    hasher.combine(self.movieId)
    
  }
}

extension FavoriteMovieKey : Sendable {}



public struct MovieActorKey {
  
  public private(set) var movieId: UUID
  
  public private(set) var actorId: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  movieId
    
    case  actorId
    
  }
}

extension MovieActorKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.movieId = try codecHelper.decode(UUID.self, forKey: .movieId, container: &container)
    
    self.actorId = try codecHelper.decode(UUID.self, forKey: .actorId, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
      
      
      
      try codecHelper.encode(actorId, forKey: .actorId, container: &container)
      
      
    }
}

extension MovieActorKey : Equatable {
  public static func == (lhs: MovieActorKey, rhs: MovieActorKey) -> Bool {
    
    if lhs.movieId != rhs.movieId {
      return false
    }
    
    if lhs.actorId != rhs.actorId {
      return false
    }
    
    return true
  }
}

extension MovieActorKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.movieId)
    
    hasher.combine(self.actorId)
    
  }
}

extension MovieActorKey : Sendable {}



public struct MovieMetadataKey {
  
  public private(set) var id: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension MovieMetadataKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension MovieMetadataKey : Equatable {
  public static func == (lhs: MovieMetadataKey, rhs: MovieMetadataKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension MovieMetadataKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension MovieMetadataKey : Sendable {}



public struct MovieKey {
  
  public private(set) var id: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension MovieKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(UUID.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension MovieKey : Equatable {
  public static func == (lhs: MovieKey, rhs: MovieKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension MovieKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension MovieKey : Sendable {}



public struct ReviewKey {
  
  public private(set) var userId: String
  
  public private(set) var movieId: UUID
  

  enum CodingKeys: String, CodingKey {
    
    case  userId
    
    case  movieId
    
  }
}

extension ReviewKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.userId = try codecHelper.decode(String.self, forKey: .userId, container: &container)
    
    self.movieId = try codecHelper.decode(UUID.self, forKey: .movieId, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(userId, forKey: .userId, container: &container)
      
      
      
      try codecHelper.encode(movieId, forKey: .movieId, container: &container)
      
      
    }
}

extension ReviewKey : Equatable {
  public static func == (lhs: ReviewKey, rhs: ReviewKey) -> Bool {
    
    if lhs.userId != rhs.userId {
      return false
    }
    
    if lhs.movieId != rhs.movieId {
      return false
    }
    
    return true
  }
}

extension ReviewKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.userId)
    
    hasher.combine(self.movieId)
    
  }
}

extension ReviewKey : Sendable {}



public struct UserKey {
  
  public private(set) var id: String
  

  enum CodingKeys: String, CodingKey {
    
    case  id
    
  }
}

extension UserKey : Codable {
  public init(from decoder: any Decoder) throws {
    var container = try decoder.container(keyedBy: CodingKeys.self)
    let codecHelper = CodecHelper<CodingKeys>()

    
    self.id = try codecHelper.decode(String.self, forKey: .id, container: &container)
    
  }

  public func encode(to encoder: Encoder) throws {
      var container = encoder.container(keyedBy: CodingKeys.self)
      let codecHelper = CodecHelper<CodingKeys>()
      
      
      try codecHelper.encode(id, forKey: .id, container: &container)
      
      
    }
}

extension UserKey : Equatable {
  public static func == (lhs: UserKey, rhs: UserKey) -> Bool {
    
    if lhs.id != rhs.id {
      return false
    }
    
    return true
  }
}

extension UserKey : Hashable {
  public func hash(into hasher: inout Hasher) {
    
    hasher.combine(self.id)
    
  }
}

extension UserKey : Sendable {}


