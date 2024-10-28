//
// FriendlyFlixMocksApp.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 28.09.24.
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

import SwiftUI
import Firebase
import FirebaseAuth
import FirebaseDataConnect
import FriendlyFlixSDK

@main
struct FriendlyFlixApp: App {
  private func loadRocketSimConnect() {
#if DEBUG
    guard (Bundle(path: "/Applications/RocketSim.app/Contents/Frameworks/RocketSimConnectLinker.nocache.framework")?.load() == true) else {
      print("Failed to load linker framework")
      return
    }
    print("RocketSim Connect successfully linked")
#endif
  }

  var authenticationService: AuthenticationService?

  init() {
    loadRocketSimConnect()
    FirebaseApp.configure()

    authenticationService = AuthenticationService()
    authenticationService?.onSignUp { user in
      print("User signed in \(user.displayName ?? "(no fullname)") with email \(user.email ?? "(no email)")")
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
