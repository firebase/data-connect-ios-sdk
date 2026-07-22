# Firebase SQL Connect for Swift
(formerly called Firebase Data Connect)

**Connect your Swift & SwiftUI apps directly to a managed Google CloudSQL (PostgreSQL) database.**

This repository contains the official open-source Swift SDK for [Firebase SQL Connect](https://firebase.google.com/docs/sql-connect), a service that lets you build modern, data-driven applications on Apple platforms (iOS, macOS, etc.) with the power and scalability of a SQL database.

This SDK is perfect for those:
* Who need a robust SQL database for their app but want to avoid writing and managing a separate backend.
* Looking for a type-safe, async-first library to integrate a PostgreSQL database into their applications.
* Require realtime queries integrated with Swift's Observation framework and Offline access to query results.

---

## ✨ Why Use Firebase SQL Connect?

* **Use power of SQL:** Get the power of a managed PostgreSQL database without the hassle of managing servers. Focus on your app's frontend experience.
* **Type-Safe & Modern Swift:** Interact with your database using a strongly-typed, auto-generated Swift SDK. It's built with modern `async/await` for clean, concurrent code.
* **Realtime**:** Get automatic realtime updates to your Queries.
* **Offline Cache:** Access your query results even when offline.
* **Built for SwiftUI:** `@Observable Queries` automatically update your SwiftUI views when data changes, making it incredibly simple to build reactive UIs.
* **Full CRUD Operations:** Define your data models and operations using GraphQL, and Data Connect generates the Swift code to query, insert, update, and delete data.
* **Local Emulator:** Develop and test your entire application locally with the FDC emulator for a fast and efficient development cycle.

## Next Steps
* **Get Started:** [Build your first App](https://firebase.google.com/docs/sql-connect/quickstart/ios).
* **Schema Design:** Learn more about designing schemas, queries, and mutations in the [official documentation](https://firebase.google.com/docs/data-connect/schemas-guide).
* **Codelab:** Follow our detailed [Firebase SQL Connect for iOS Codelab](https://firebase.google.com/codelabs/firebase-dataconnect-ios#0).
* **Sample App:** Explore a complete sample application, [FriendlyFlix](https://github.com/firebase/data-connect-ios-sdk/tree/main/Examples/FriendlyFlix), to see more advanced usage patterns.


This repository is licensed under the [Apache License, version 2.0](http://www.apache.org/licenses/LICENSE-2.0). Your use of Firebase is governed by the [Terms of Service for Firebase Services](https://firebase.google.com/terms/).
