// Copyright © 2024 Google LLC. All rights reserved.
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

import Foundation
import Observation
import FirebaseAuth

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

@Observable
class AuthenticationService {
  var presentingAuthenticationDialog = false
  var presentingAccountDialog = false

  var authenticationState: AuthenticationState = .unauthenticated
  var user: User? = nil

  private var authenticationListener: AuthStateDidChangeListenerHandle?

  init() {
    authenticationListener = Auth.auth().addStateDidChangeListener { auth, user in
      if let user {
        self.authenticationState = .authenticated
        self.user = user
      }
      else {
        self.authenticationState = .unauthenticated
      }
    }
  }

  func signInWithEmailPassword(email: String, password: String) async throws {
    try await Auth.auth().signIn(withEmail: email, password: password)
    authenticationState = .authenticated
  }

  func signUpWithEmailPassword(email: String, password: String) async throws {
    try await Auth.auth().createUser(withEmail: email, password: password)
    authenticationState = .authenticated
  }

  func signOut() throws {
    try Auth.auth().signOut()
    authenticationState = .unauthenticated
  }
}
