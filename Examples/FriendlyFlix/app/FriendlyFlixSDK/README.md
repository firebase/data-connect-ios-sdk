This Swift package contains the generated Swift code for the connector `friendly-flix`.

You can use this package by adding it as a local Swift package dependency in your project.

# Accessing the connector

Add the necessary imports

```
import FirebaseDataConnect
import FriendlyFlixSDK

```

The connector can be accessed using the following code:

```
let connector = DataConnect.friendlyFlixConnector

```


## Connecting to the local Emulator
By default, the connector will connect to the production service.

To connect to the emulator, you can use the following code, which can be called from the `init` function of your SwiftUI app

```
connector.useEmulator()
```

# Queries

## ListMoviesQuery
### Variables


#### Optional
```swift

let limit: Int = ...
```



### Using the Query Reference
```
struct MyView: View {
   var listMoviesQueryRef = DataConnect.friendlyFlixConnector.listMoviesQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listMoviesQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listMoviesQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.listMoviesQuery.execute(...)
```


## ListMoviesByGenreQuery
### Variables
#### Required
```swift

let genre: String = ...
```




### Using the Query Reference
```
struct MyView: View {
   var listMoviesByGenreQueryRef = DataConnect.friendlyFlixConnector.listMoviesByGenreQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listMoviesByGenreQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listMoviesByGenreQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.listMoviesByGenreQuery.execute(...)
```


## GetMovieByIdQuery
### Variables
#### Required
```swift

let id: UUID = ...
```




### Using the Query Reference
```
struct MyView: View {
   var getMovieByIdQueryRef = DataConnect.friendlyFlixConnector.getMovieByIdQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getMovieByIdQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getMovieByIdQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getMovieByIdQuery.execute(...)
```


## GetActorByIdQuery
### Variables
#### Required
```swift

let id: UUID = ...
```




### Using the Query Reference
```
struct MyView: View {
   var getActorByIdQueryRef = DataConnect.friendlyFlixConnector.getActorByIdQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getActorByIdQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getActorByIdQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getActorByIdQuery.execute(...)
```


## GetCurrentUserQuery


### Using the Query Reference
```
struct MyView: View {
   var getCurrentUserQueryRef = DataConnect.friendlyFlixConnector.getCurrentUserQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getCurrentUserQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getCurrentUserQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getCurrentUserQuery.execute(...)
```


## GetIfFavoritedMovieQuery
### Variables
#### Required
```swift

let movieId: UUID = ...
```




### Using the Query Reference
```
struct MyView: View {
   var getIfFavoritedMovieQueryRef = DataConnect.friendlyFlixConnector.getIfFavoritedMovieQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getIfFavoritedMovieQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getIfFavoritedMovieQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getIfFavoritedMovieQuery.execute(...)
```


## GetIfFavoritedActorQuery
### Variables
#### Required
```swift

let actorId: UUID = ...
```




### Using the Query Reference
```
struct MyView: View {
   var getIfFavoritedActorQueryRef = DataConnect.friendlyFlixConnector.getIfFavoritedActorQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getIfFavoritedActorQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getIfFavoritedActorQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getIfFavoritedActorQuery.execute(...)
```


## SearchAllQuery
### Variables
#### Required
```swift

let minYear: Int = ...
let maxYear: Int = ...
let minRating: Double = ...
let maxRating: Double = ...
let genre: String = ...
```


#### Optional
```swift

let input: String = ...
```



### Using the Query Reference
```
struct MyView: View {
   var searchAllQueryRef = DataConnect.friendlyFlixConnector.searchAllQuery.ref(...)

  var body: some View {
    VStack {
      if let data = searchAllQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await searchAllQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.searchAllQuery.execute(...)
```


## SearchMovieDescriptionUsingL2similarityQuery
### Variables
#### Required
```swift

let query: String = ...
```




### Using the Query Reference
```
struct MyView: View {
   var searchMovieDescriptionUsingL2similarityQueryRef = DataConnect.friendlyFlixConnector.searchMovieDescriptionUsingL2similarityQuery.ref(...)

  var body: some View {
    VStack {
      if let data = searchMovieDescriptionUsingL2similarityQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await searchMovieDescriptionUsingL2similarityQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.searchMovieDescriptionUsingL2similarityQuery.execute(...)
```


## ListMoviesByPartialTitleQuery
### Variables
#### Required
```swift

let input: String = ...
```




### Using the Query Reference
```
struct MyView: View {
   var listMoviesByPartialTitleQueryRef = DataConnect.friendlyFlixConnector.listMoviesByPartialTitleQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listMoviesByPartialTitleQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listMoviesByPartialTitleQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.listMoviesByPartialTitleQuery.execute(...)
```


## ListMoviesByTagQuery
### Variables
#### Required
```swift

let tag: String = ...
```




### Using the Query Reference
```
struct MyView: View {
   var listMoviesByTagQueryRef = DataConnect.friendlyFlixConnector.listMoviesByTagQuery.ref(...)

  var body: some View {
    VStack {
      if let data = listMoviesByTagQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await listMoviesByTagQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.listMoviesByTagQuery.execute(...)
```


## MoviesByReleaseYearQuery
### Variables


#### Optional
```swift

let min: Int = ...
let max: Int = ...
```



### Using the Query Reference
```
struct MyView: View {
   var moviesByReleaseYearQueryRef = DataConnect.friendlyFlixConnector.moviesByReleaseYearQuery.ref(...)

  var body: some View {
    VStack {
      if let data = moviesByReleaseYearQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await moviesByReleaseYearQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.moviesByReleaseYearQuery.execute(...)
```


## SearchMovieOrQuery
### Variables


#### Optional
```swift

let minRating: Double = ...
let maxRating: Double = ...
let genre: String = ...
let tag: String = ...
let input: String = ...
```



### Using the Query Reference
```
struct MyView: View {
   var searchMovieOrQueryRef = DataConnect.friendlyFlixConnector.searchMovieOrQuery.ref(...)

  var body: some View {
    VStack {
      if let data = searchMovieOrQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await searchMovieOrQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.searchMovieOrQuery.execute(...)
```


## SearchMovieAndQuery
### Variables


#### Optional
```swift

let minRating: Double = ...
let maxRating: Double = ...
let genre: String = ...
let tag: String = ...
let input: String = ...
```



### Using the Query Reference
```
struct MyView: View {
   var searchMovieAndQueryRef = DataConnect.friendlyFlixConnector.searchMovieAndQuery.ref(...)

  var body: some View {
    VStack {
      if let data = searchMovieAndQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await searchMovieAndQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.searchMovieAndQuery.execute(...)
```


## GetFavoriteActorsQuery


### Using the Query Reference
```
struct MyView: View {
   var getFavoriteActorsQueryRef = DataConnect.friendlyFlixConnector.getFavoriteActorsQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getFavoriteActorsQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getFavoriteActorsQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getFavoriteActorsQuery.execute(...)
```


## GetUserFavoriteMoviesQuery


### Using the Query Reference
```
struct MyView: View {
   var getUserFavoriteMoviesQueryRef = DataConnect.friendlyFlixConnector.getUserFavoriteMoviesQuery.ref(...)

  var body: some View {
    VStack {
      if let data = getUserFavoriteMoviesQueryRef.data {
        // use data in View
      }
      else {
        Text("Loading...")
      }
    }
    .task {
        do {
          let _ = try await getUserFavoriteMoviesQueryRef.execute()
        } catch {
        }
      }
  }
}
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.getUserFavoriteMoviesQuery.execute(...)
```


# Mutations
## CreateMovieMutation

### Variables

#### Required
```swift

let title: String = ...
let releaseYear: Int = ...
let genre: String = ...
let imageUrl: String = ...
```
 

#### Optional
```swift

let rating: Double = ...
let description: String = ...
let tags: String = ...
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.createMovieMutation.execute(...)
```

## AddFavoritedMovieMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.addFavoritedMovieMutation.execute(...)
```

## DeleteFavoritedMovieMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.deleteFavoritedMovieMutation.execute(...)
```

## AddFavoritedActorMutation

### Variables

#### Required
```swift

let actorId: UUID = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.addFavoritedActorMutation.execute(...)
```

## DeleteFavoritedActorMutation

### Variables

#### Required
```swift

let actorId: UUID = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.deleteFavoritedActorMutation.execute(...)
```

## AddReviewMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
let rating: Int = ...
let reviewText: String = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.addReviewMutation.execute(...)
```

## DeleteReviewMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.deleteReviewMutation.execute(...)
```

## UpsertUserMutation

### Variables

#### Required
```swift

let username: String = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.upsertUserMutation.execute(...)
```

## UpdateMovieMutation

### Variables

#### Required
```swift

let id: UUID = ...
```
 

#### Optional
```swift

let title: String = ...
let releaseYear: Int = ...
let genre: String = ...
let rating: Double = ...
let description: String = ...
let imageUrl: String = ...
let tags: String = ...
```

### One-shot execute
```
DataConnect.friendlyFlixConnector.updateMovieMutation.execute(...)
```

## DeleteMovieMutation

### Variables

#### Required
```swift

let id: UUID = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.deleteMovieMutation.execute(...)
```

## DeleteUnpopularMoviesMutation

### Variables

#### Required
```swift

let minRating: Double = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.deleteUnpopularMoviesMutation.execute(...)
```

