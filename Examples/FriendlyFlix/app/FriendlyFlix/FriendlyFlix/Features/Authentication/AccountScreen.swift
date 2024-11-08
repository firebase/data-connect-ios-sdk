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

import SwiftUI

struct AccountScreen: View {
  @Environment(\.dismiss) var dismiss
  @Environment(AuthenticationService.self) var authenticationService

  private var displayName: String {
    authenticationService.user?.displayName ?? "(not set)"
  }

  private var email: String {
    authenticationService.user?.email ?? ""
  }

  private func signOut() {
    do {
      try authenticationService.signOut()
      dismiss()
    } catch {}
  }
}

extension AccountScreen {
  var body: some View {
    NavigationStack {
      List {
        Section {
          HStack(alignment: .center) {
            Image(systemName: "person.circle.fill")
              .resizable()
              .scaledToFit()
              .frame(height: 48)
            VStack(alignment: .leading) {
              Text(displayName)
              Text(email)
            }
          }
        }

        Section {
          Button(action: signOut) {
            Text("Sign out")
          }
        }
      }
      .navigationTitle("Account")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Button(action: { dismiss() }) {
            Text("Done")
          }
        }
      }
    }
  }
}

#Preview {
  AccountScreen()
    .environment(AuthenticationService())
}
