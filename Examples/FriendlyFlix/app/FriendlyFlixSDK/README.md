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

let orderByRating: OrderDirection = ...
let orderByReleaseYear: OrderDirection = ...
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


## ListMoviesByPartialTitleQuery
### Variables
#### Required
```swift

let searchTerm: String = ...
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


# Mutations
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

## UpdateReviewMutation

### Variables

#### Required
```swift

let movieId: UUID = ...
let rating: Int = ...
let reviewText: String = ...
```
 

### One-shot execute
```
DataConnect.friendlyFlixConnector.updateReviewMutation.execute(...)
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

