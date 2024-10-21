//
// AccountScreen.swift
// FriendlyFlixMocks
//
// Created by Peter Friese on 10.10.24.
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
  @Environment(AuthenticationViewModel.self) var authenticationViewModel

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
              Text("Peter Friese")
              Text("peterfriese@google.com")
            }
          }
        }

        Section {
          Button(role: .destructive, action: {}) {
            Text("Clear viewing history")
          }
        }

        Section {
          Button(action: {
            authenticationViewModel.signOut()
            dismiss()
          }) {
            Text("Sign out")
          }
        }
      }
      .navigationTitle("Account")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem {
          Button(action: {dismiss()}) {
            Text("Done")
          }
        }
      }
    }
  }
}

#Preview {
  AccountScreen()
}
