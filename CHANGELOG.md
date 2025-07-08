# 11.7.2
- [fixed] `DataConnectOperationError` now includes underlying server error messages in the debug description instead of a generic decoding error. [#14945](https://github.com/firebase/firebase-ios-sdk/issues/14945)

# 11.7.1
- [fixed] `AnyValue` type fixes to support decoding values fetched using PostgreSQL `jsonb_build_object`.  `AnyValue` now internally stores data as a JSON value / dictionary instead of `Swift.Data`.

# 11.7.0
- [changed] Firebase Data Connect has exited beta and is now generally available for use.
- [changed] **Breaking Change:** Refactored the base `DataConnectError` error type to be a protocol instead of an enum and introduced concrete error types `DataConnectInitError`, `DataConnectCodecError`, `DataConnectOperationError`. Note that if you have code using a `switch` on the previous error enum, you will need to update that code. See the [PR] (https://github.com/firebase/data-connect-ios-sdk/pull/42) for a usage example and `DataConnectError.swift` for implementation details.
- [added] Support for partial errors via the above mentioned `DataConnectOperationError`.

# 11.6.0-beta
- [changed] Dependency on Firebase iOS SDK changed to 'minimum version required' instead of an 'exact version'. This lets apps use the latest version of the Firebase iOS SDK.

# 11.5.0-beta
- [added] FriendlyFlix - a comprehensive SwiftUI sample app.
- [changed] Switched to using AppCheckInterop APIs to remove hard dependency on FirebaseAppCheck library.

# 11.4.0-beta
- [added] Support for Swift 6 strict concurrency.
- [added] Logging within SDKs.
- [changed] SDK will throw errors if partial GraphQL errors are detected during operation execution.

# 11.3.0-beta
- [added] Initial public preview (pre-announced) release of the SDK. For more information visit
  [Firebase Data Connect](https://firebase.google.com/products/data-connect).
