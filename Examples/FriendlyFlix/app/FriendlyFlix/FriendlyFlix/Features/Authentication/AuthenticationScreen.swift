//
// AuthenticationScreen.swift
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

import AuthenticationServices
import SwiftUI

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

private enum AuthenticationFlow {
  case login
  case signUp
}

struct AuthenticationScreen: View {
  @Environment(AuthenticationService.self) var authenticationService
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

  @State private var email = ""
  @State private var password = ""
  @State private var confirmPassword = ""

  @State private var flow: AuthenticationFlow = .login

  @State private var errorMessage = ""
  @State private var displayName = ""

  private var isValid: Bool {
    return if flow == .login {
      !email.isEmpty && !password.isEmpty
    } else {
      !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
  }

  private func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  @FocusState private var focus: FocusableField?

  private func signInWithEmailPassword() {
    Task {
      do {
        try await authenticationService.signInWithEmailPassword(email: email, password: password)
        dismiss()
      } catch {
        print(error.localizedDescription)
        errorMessage = error.localizedDescription
      }
    }
  }

  private func signUpWithEmailPassword() {
    Task {
      do {
        try await authenticationService.signUpWithEmailPassword(email: email, password: password)
        errorMessage = ""
        dismiss()
      } catch {
        print(error.localizedDescription)
        errorMessage = error.localizedDescription
      }
    }
  }
}

extension AuthenticationScreen {
  var body: some View {
    VStack {
      Text("Welcome to FriendlyFlix")
        .font(.largeTitle)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Image(systemName: "at")
        TextField("Email", text: $email)
          .textInputAutocapitalization(.never)
          .disableAutocorrection(true)
          .focused($focus, equals: .email)
          .submitLabel(.next)
          .onSubmit {
            self.focus = .password
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 4)

      HStack {
        Image(systemName: "lock")
        SecureField("Password", text: $password)
          .focused($focus, equals: .password)
          .submitLabel(.go)
          .onSubmit {
            signInWithEmailPassword()
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      if flow == .signUp {
        HStack {
          Image(systemName: "lock")
          SecureField("Confirm password", text: $confirmPassword)
            .focused($focus, equals: .confirmPassword)
            .submitLabel(.go)
            .onSubmit {
              signUpWithEmailPassword()
            }
        }
        .padding(.vertical, 6)
        .background(Divider(), alignment: .bottom)
        .padding(.bottom, 8)
      }

      if !errorMessage.isEmpty {
        VStack {
          Text(errorMessage)
            .foregroundColor(Color(UIColor.systemRed))
        }
      }

      Button(action: {
        if flow == .login { signInWithEmailPassword() }
        else { signUpWithEmailPassword() }
      }) {
        if authenticationService.authenticationState != .authenticating {
          Text(flow == .login ? "Log in with password" : "Sign up")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        } else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
      }
      .disabled(!isValid)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)

      HStack {
        Text(flow == .login ? "Don't have an account yet?" : "Already have an account?")
        Button(action: {
          withAnimation {
            switchFlow()
          }
        }) {
          Text(flow == .signUp ? "Log in" : "Sign up")
            .fontWeight(.semibold)
            .foregroundColor(.blue)
        }
      }
      .padding([.top, .bottom], 50)
    }
    .padding()
    .frame(maxHeight: .infinity, alignment: .bottom)
  }
}

#Preview {
  AuthenticationScreen()
    .environment(AuthenticationService())
}
