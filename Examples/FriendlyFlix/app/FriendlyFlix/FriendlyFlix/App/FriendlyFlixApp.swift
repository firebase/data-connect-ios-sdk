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

@main
struct FriendlyFlixApp: App {
  var authenticationService: AuthenticationService?

  init() {
    FirebaseApp.configure()

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
