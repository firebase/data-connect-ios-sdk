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

import Firebase
import FirebaseAuth
import FirebaseDataConnect
import FriendlyFlixSDK
import SwiftUI
import os

@main
struct FriendlyFlixApp: App {
  private let logger = Logger(subsystem: "FriendlyFlix", category: "configuration")

  var authenticationService: AuthenticationService?

  /// Determines whether to use the Firebase Local Emulator Suite.
  /// To use the local emulator, go to the active scheme, and add `-useEmulator YES`
  /// to the _Arguments Passed On Launch_ section.
  public var useEmulator: Bool {
    let value =  UserDefaults.standard.bool(forKey: "useEmulator")
    logger.log("Using the emulator: \(value == true ? "YES" : "NO")")
    return value
  }

  init() {
    FirebaseApp.configure()
    if useEmulator {
      DataConnect.friendlyFlixConnector.useEmulator(port: 9399)
      Auth.auth().useEmulator(withHost: "localhost", port:9099)
    }

    authenticationService = AuthenticationService()
    authenticationService?.onSignUp { user in
      let userName = String(user.email?.split(separator: "@").first ?? "(unknown)")
      Task {
        try await DataConnect.friendlyFlixConnector.upsertUserMutation.execute(username: userName)
      }
    }
  }

  var body: some Scene {
    WindowGroup {
      RootView()
        .environment(authenticationService)
    }
  }
}
