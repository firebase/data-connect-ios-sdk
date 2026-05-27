# **🤖 Agent Guide: Swift \+ Firebase Data Connect (a.k.a. Firebase SQL Connect)**

## **Agent Goals**

The Agent must produce the following working deliverable 

**The FDC Generated Swift SDK:** A local Swift Package created by FDC based on `.gql` definitions. Suffix the name of this package with “GenSDK”

\[\!IMPORTANT\] **Entry Point Logic:** Only execute this guide if an FDC project/SDK doesn't exist. If it does, skip this guide and only perform a check with the user about missing artifacts in the guide.

## **Conventions**

- `<AppName>` — the app's short name (e.g. `Todo`). Derive `<AppName>` from the user prompt or by inspecting the root directory for a `.xcodeproj` or `.xcworkspace` file name..  
- `<connector>` — the FDC connector name (matches `connectorId` in `connector.yaml`).  
- Generated SDK package name: `<AppName>GenSDK`.  
- Consolidated model package name (optional add-on): `<AppName>Data`.  
- Swift toolchain: `// swift-tools-version:5.9`.  
- All examples below use `<AppName> = Todo`, `<connector> = todo`.

## **Prerequisites & Pre-Flight Check**

The Agent **must** verify these items before attempting to generate the SDK:

* **Firebase agent skills from https://github.com/firebase/agent-skills** installed locally under `.agents/skills/`. Required skills:  
  * `firebase-basics` — Firebase CLI, project init/auth, `GoogleService-Info.plist` setup  
  * `firebase-data-connect-basics` — schema, queries, mutations, CEL auth, connector config, sdk\_ios, SDK generation.  
  * `xcode-project-setup` — adding Swift packages and files to the `.xcodeproj`  
* **Firebase CLI:** Ensure Firebase CLI is installed. Refer to `firebase-basics` skill  
* **App Registration & Config (Mandatory):**  
  * Prompt the user for an iOS app bundle ID or suggest one based on app description.  
  * Register the iOS app bundle ID in the Firebase Project.  
  * Download `GoogleService-Info.plist` to the project root.  
  * **Agent Action:** Search the local directory for `GoogleService-Info.plist`. If missing, stop and prompt: *"I cannot find GoogleService-Info.plist. I need to register the app via MCP or have you provide the file before I can initialize the SDK."*

## **Core Deliverable: FDC Generated Swift Package**

1. **Initiate & Configure Emulators:**  
   * Run `firebase init dataconnect`.  
   * **CRITICAL:** Verify the `emulators` section in `firebase.json` contains both `auth` and `dataconnect` blocks.  
2. **Schema:** Define models in `dataconnect/schema/schema.gql`. Use firebase-data-connect-basics agent skills for custom schema GQL directives, CEL expressions, defaults, auth levels.  
3. **Connector Config:**  
   * Set `connectorId` in `dataconnect/<connector>/connector.yaml`.  
   * **Caching:** Configure `clientCache` with `maxAge: 0s` within the sdk generate section for the Swift SDK. Inform the user in summary to update value to something suitable for the app. Skill: firebase-data-connect-basics  
4. **Operations:** Define logic in `queries.gql` and `mutations.gql`.   
   * Use `@refresh` directives for realtime support. Skill: `firebase-data-connect-basics / Realtime Reference`  
   * IMPORTANT: When generating queries and mutations, prefer FDC GQL over Native SQL unless the query or mutation is complex and cannot be successfully expressed in GQL (e.g. recursive CTEs, window functions, multi-table aggregate joins not supported by GQL directives, PostGIS queries).  
5. **SDK Generation:** Set output to a **Local Swift Package** at the **root**. The generator creates its own folder; do not create a containing folder manually. Skill: `firebase-data-connect-basics / iOS SDK`

## **Modification Lifecycle**

1. **Modify GQL** — update `.gql` files; apply `@auth` directives.  
2. **Regenerate** — `firebase dataconnect:sdk:generate`.  
3. **Sync consumers** — read the SDK's generated `README.md` to identify type and function signature changes.   
4. **Build** — `swift build --clean-first` in the package root; fix all errors and Sendable warnings.

\[\!IMPORTANT\] **Self-correction:** Analyze the error output, apply a targeted fix to the code/GQL, and then retry the failing step (regenerate, edit GQL, or rebuild as appropriate) up to **3 times**. On the 4th failure, stop and surface the full output of the failing command (`firebase dataconnect:sdk:generate` or `swift build`) to the user.

## **Xcode Integration**

Provide the user with these steps:

1. Add `<AppName>GenSDK` as local package dependencies.  
2. Add `GoogleService-Info.plist` to the app target.  
3. Import `FirebaseCore` (and `<AppName>Data` if enabled) in the app entry point.  
4. Call `FirebaseApp.configure()` in `init()` of the `App` struct.  
5. Optionally call `useEmulator(...)` during local development.

## **Core Execution Rules**

1. **Strict concurrency** — build must pass `swift build -Xswiftc -strict-concurrency=complete` with zero warnings.  
2. **Clean builds gate completion** — packages must compile with `swift build --clean-first` before a task is reported done.  
3. **UI isolation** — once Part B exists, Views must not import `<AppName>GenSDK` directly; they interact only with the consolidated model store.

## **Definition of Done**

Core setup is complete when **all** of the following hold:

- [ ] `GoogleService-Info.plist` present at project root.  
- [ ] `firebase.json` `emulators` contains both `auth` and `dataconnect` blocks.  
- [ ] `<AppName>GenSDK` builds clean with `swift build --clean-first`.  
- [ ] `swift build -Xswiftc -strict-concurrency=complete` passes with no warnings.  
- [ ] Xcode integration steps have been provided to the user.
