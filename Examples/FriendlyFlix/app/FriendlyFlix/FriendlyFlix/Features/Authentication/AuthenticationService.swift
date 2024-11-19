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

import FirebaseAuth
import Foundation
import Observation
import os

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

@Observable
class AuthenticationService {
  private let logger = Logger(subsystem: "FriendlyFlix", category: "auth")

  var presentingAuthenticationDialog = false
  var presentingAccountDialog = false

  var authenticationState: AuthenticationState = .unauthenticated
  var user: User?

  private var authenticationListener: AuthStateDidChangeListenerHandle?

  init() {
    authenticationListener = Auth.auth().addStateDidChangeListener { auth, user in
      if let user {
        self.authenticationState = .authenticated
        self.user = user
      } else {
        self.authenticationState = .unauthenticated
      }
    }
  }

  private var onSignUp: ((User) -> Void)?
  public func onSignUp(_ action: @escaping (User) -> Void) {
    onSignUp = action
  }

  func signInWithEmailPassword(email: String, password: String) async throws {
    try await Auth.auth().signIn(withEmail: email, password: password)
    authenticationState = .authenticated
  }

  func signUpWithEmailPassword(email: String, password: String) async throws {
    try await Auth.auth().createUser(withEmail: email, password: password)

    if let onSignUp, let user = Auth.auth().currentUser {
      logger.debug("User signed in \(user.displayName ?? "(no fullname)") with email \(user.email ?? "(no email)")")
      onSignUp(user)
    }

    authenticationState = .authenticated
  }

  func signOut() throws {
    try Auth.auth().signOut()
    authenticationState = .unauthenticated
  }
}
