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

struct AuthenticationToolbarButton: View {
  @Environment(AuthenticationService.self) var authenticationService

  private func onButtonTapped() {
    if authenticationService.authenticationState == .unauthenticated {
      authenticationService.presentingAuthenticationDialog.toggle()
    } else {
      authenticationService.presentingAccountDialog.toggle()
    }
  }
}

extension AuthenticationToolbarButton {
  var body: some View {
    Button(action: onButtonTapped) {
      Image(systemName: authenticationService
        .authenticationState == .unauthenticated ? "person.circle" : "person.circle.fill")
    }
  }
}

#Preview {
  AuthenticationToolbarButton()
    .environment(AuthenticationService())
}
