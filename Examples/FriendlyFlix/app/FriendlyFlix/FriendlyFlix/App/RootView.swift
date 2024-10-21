//
// RootView.swift
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

struct RootView: View {
  @Environment(AuthenticationViewModel.self) private var authenticationViewModel

  var body: some View {
    @Bindable var authenticationViewModel = authenticationViewModel
    TabView {
      HomeScreen()
        .tabItem {
          Label("Home", systemImage: "house")
        }
      SearchScreen()
        .tabItem {
          Label("Search", systemImage: "magnifyingglass")
        }
      LibraryScreen()
        .tabItem {
          Label("Library", systemImage: "rectangle.on.rectangle")
        }
    }
    .sheet(isPresented: $authenticationViewModel.presentingAuthenticationDialog) {
      AuthenticationScreen()
    }
    .sheet(isPresented: $authenticationViewModel.presentingAccountDialog) {
      AccountScreen()
    }
  }
}

#Preview {
  RootView()
    .environment(AuthenticationViewModel())
}
