# **🤖 Agent Guide: Swift \+ Firebase Data Connect (Firebase SQL Connect)**

## **🏁 Agent Goals**

The Agent must produce the following deliverables in strict sequential order:

1. **The Generated Swift SDK:** A local Swift Package created by FDC based on `.gql` definitions. Suffix the name of this package with “GenSDK”  
2. **The "Consolidated Model" Package (Optional):** A secondary logic package depending on the SDK (No UI code). Suffix the name of the package with “Data”.

\[\!IMPORTANT\] **Entry Point Logic:** Start from Goal 1 only if an FDC project/SDK doesn't exist. If it does, prompt the user for the location and skip to Goal 2\.

## **🛠 Prerequisites & Pre-Flight Check**

The Agent **must** verify these items before attempting to generate the SDK:

* **Firebase MCP Server:** Ensure installed. Used for project initiation and credential management.  
* **Firebase Agent Skills:** Install and load `firebase-agent-skills` locally for Firebase Basics, FDC schema, FDC queries, FDC mutations, FDC CEL logic, SDK configuration, SDK generation.  
* **App Registration & Config (Mandatory):**  
  * Prompt the user for an iOS app bundle ID or suggest one based on app description.  
  * Register the iOS app bundle ID in the Firebase Project.  
  * Download `GoogleService-Info.plist` to the project root.  
  * **Agent Action:** Search the local directory for `GoogleService-Info.plist`. If missing, stop and prompt: *"I cannot find GoogleService-Info.plist. I need to register the app via MCP or have you provide the file before I can initialize the SDK."*

## 🔐 **Flexible Authentication Architecture Rule**

When generating the reactive `@Observable` `AuthManager`, do not hardcode the implementation exclusively for Email/Password. It must be architected as an extensible boundary.

1. **The Default Helper**: Provide clear `signIn(email:password:)` and `signUp(email:password:)` async methods to serve as the initial out-of-the-box implementation.  
2. **The Extensible Hook**: Implement a generalized `signIn(with credential: AuthCredential)` async method. This allows the UI to easily resolve OAuth flows (Google, Apple, etc.) externally and pass the resolved `AuthCredential` into the core manager.  
3. **DB Sync Hook**: Ensure all sign-in pathways (default helpers and the extensible hook) reliably trigger the mandatory `user_upsert` database synchronization before concluding. **Implementation Reference:**

```swift
public func signIn(email: String, password: String) async throws {
    let result = try await Auth.auth().signIn(withEmail: email, password: password)
    try await syncUserToDatabase()
}
public func signIn(with credential: AuthCredential) async throws {
    let result = try await Auth.auth().signIn(with: credential)
    try await syncUserToDatabase()
}
private func syncUserToDatabase() async throws {
    _ = try await DataConnect.todoConnector.upsertUserMutation.execute()
}
```

## **🚨 User Synchronization Rule (Mandatory)**

To prevent SQL foreign key constraint violations (e.g., `violates SQL foreign key constraint: list_owner_id_fkey`), the authenticated user profile **must** exist in the database `User` table before any associated child records can be created.

* **Agent Action**: Always define a standard GraphQL `user_upsert` mutation in `mutations.gql`.  
* **Trigger**: Invoke this mutation immediately upon successful Firebase Authentication resolution (inside both `signIn` and `signUp` methods within your `AuthManager`).  
* **Dependencies**: Ensure `AuthManager` imports `FirebaseDataConnect` to flawlessly execute the database profile synchronization before the UI proceeds.

## **🚀 FDC Generated Swift Package (Deliverable 1\)**

1. **Initiate & Configure Emulators:**  
   * Run `firebase init dataconnect`.  
   * **CRITICAL:** Verify the `emulators` section in `firebase.json` contains both `auth` and `dataconnect` blocks.  
2. **Schema:** Define models in `dataconnect/schema/schema.gql`. Use agent skills for custom schema GQL directives.  
3. **Connector Config:**  
   * Set `connectorId` in `dataconnect/$CONNECTOR_NAME/connector.yaml`.  
   * **Caching:** Configure `clientCache` with `maxAge: 3s` within the sdk generate section for the Swift SDK.  
4. **Operations:** Define logic in `queries.gql` and `mutations.gql`. Use `@refresh` directives for realtime support.  
   * IMPORTANT: When generating queries and mutations, prefer FDC GQL over Native SQL unless the query or mutation is complex and cannot be successfully expressed in GQL.  
5. **SDK Generation:** Set output to a **Local Swift Package** at the **root**. The generator creates its own folder; do not create a containing folder manually.

## **🧱 Architecture: Reactive "Consolidated Model" Package (Deliverable 2\)**

The Consolidated Model Package must decouple FDC's nested types from the UI using the **Computed Reference Pattern**.

### **Step 1: The "Fat" App Model**

Define stable, unified structs. Use optional fields for query-specific data.

Swift

```
public struct AppUser: Identifiable, Hashable {
    public let id: String
    public let name: String
    public let email: String? 
}
```

### **Step 2: The Reactive @Observable Store (Reference Pattern)**

Instead of storing arrays, store the `Query.Ref`. This allows the UI to react directly to FDC's local cache updates.

Swift

```
import Foundation
import Observation
import FirebaseDataConnect
import MyGeneratedSDK // The SDK from Deliverable 1

@available(iOS 17.0, *)
@Observable @MainActor
public class UserStore {
    // 1. Hold the Query Reference (Source of Truth)
    private var userRef: GetUserQuery.Ref?
    
    // 2. Computed Property for UI (The "Consolidated Model" Mapping)
    public var currentUser: AppUser? {
        guard let data = userRef?.data else { return nil }
        // Transform the generated FDC type to our unified AppUser
        return AppUser(id: data.user.id, name: data.user.name, email: data.user.email)
    }

    public init() {}

    // 3. Subscription Management
    public func observeUser(id: String) {
        let connector = DataConnect.myConnector
        userRef = connector.getUserQuery.ref(id: id)
        
        Task {
            // Subscribe makes the userRef reactive to server/cache changes
            try? await userRef?.subscribe()
        }
    }

    public func unobserveUser() {
        userRef = nil // Dropping the ref stops the observation
    }

    // 4. Mutations
    public func updateUser(id: String, name: String) async throws {
        _ = try await DataConnect.myConnector.updateUserMutation.execute(id: id, name: name)
        // Optionally force-refresh the local ref
        try await userRef?.execute()
    }
}
```

**Rules for Generation:**

* Strictly use **Swift 5.9** toolset.  
* Resolve all concurrency/Sendable warnings.

## **🔄 The Modification Lifecycle**

1. **Modify GQL:** Update `.gql` files and apply `@auth` directives.  
2. **Regenerate:** Execute `firebase dataconnect:sdk:generate`.  
3. **Sync:** Consume the generated `README.md` in the SDK to identify type changes and update Mappers/Computed properties in Deliverable 2\.  
4. **Swift Build:** Run `swift build --clean-first` in the package root. Fix all errors.

\[\!IMPORTANT\] **Self-Correction:** Attempt logic fixes up to **3 times** on failure. On the 4th failure, provide logs and wait for the user.

## **🚨 Agent Execution Rules**

1. **Computed Properties Only:** Do not store arrays of data; store the `Ref` and map data lazily via `var`.  
2. **No UI:** Deliverable 2 must contain **zero** SwiftUI View code.  
3. **UI Isolation:** Views **must not** import the Generated SDK. They only interact with the Consolidated Model Store.  
4. **Emulator Awareness:** Provide a `useEmulator function` on the Consolidated Model Store that starts the emulators for Data Connect connector and Firebase Auth on their default ports with option to override the port.   
5. **Clean Builds:** Always ensure the generated packages compile successfully before finishing a task.  
6. **Xcode Project:** Provide instructions for integration into Xcode  
   1. Add Local Package dependencies  
   2. Add GoogleService-Info.plist  
   3. Specify the necessary imports.  
   4. Call `FirebaseApp.configure()` in the app init  
   5. Optionally call `useEmulator()` on the generated Store class.
