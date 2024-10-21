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

import SwiftUI
import AuthenticationServices

enum AuthenticationState {
  case unauthenticated
  case authenticating
  case authenticated
}

enum AuthenticationFlow {
  case login
  case signUp
}

@Observable
class AuthenticationViewModel {
  var presentingAuthenticationDialog = false
  var presentingAccountDialog = false

  var email = ""
  var password = ""
  var confirmPassword = ""

  var flow: AuthenticationFlow = .login

  var authenticationState: AuthenticationState = .unauthenticated
  var errorMessage = ""
  var displayName = ""

  var isValid: Bool {
    return if flow == .login {
      !email.isEmpty && !password.isEmpty
    }
    else {
      !email.isEmpty && !password.isEmpty && password == confirmPassword
    }
  }

  func switchFlow() {
    flow = flow == .login ? .signUp : .login
    errorMessage = ""
  }

  func signOut() {
    authenticationState = .unauthenticated
  }
}

private enum FocusableField: Hashable {
  case email
  case password
  case confirmPassword
}

struct AuthenticationScreen: View {
  @Environment(AuthenticationViewModel.self) var viewModel
  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.dismiss) private var dismiss

  @FocusState private var focus: FocusableField?

  private func signInWithEmailPassword() {
    if viewModel.authenticationState == .authenticated {
      viewModel.authenticationState = .unauthenticated
      dismiss()
    }
    else {
      viewModel.authenticationState = .authenticated
      dismiss()
    }
  }

  private func signUpWithEmailPassword() {
    if viewModel.authenticationState == .authenticated {
      viewModel.authenticationState = .unauthenticated
      dismiss()
    }
    else {
      viewModel.authenticationState = .authenticated
      dismiss()
    }
  }

  var body: some View {
    @Bindable var viewModel = viewModel
    VStack {
//      Image("login")
//        .resizable()
//        .aspectRatio(contentMode: .fit)
//        .frame(minHeight: 300, maxHeight: 400)
//      Text(viewModel.flow == .login ? "Log in" : "Sign up")
      Text("Welcome")
        .font(.largeTitle)
        .fontWeight(.bold)
        .frame(maxWidth: .infinity, alignment: .leading)

      HStack {
        Image(systemName: "at")
        TextField("Email", text: $viewModel.email)
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
        SecureField("Password", text: $viewModel.password)
          .focused($focus, equals: .password)
          .submitLabel(.go)
          .onSubmit {
            signInWithEmailPassword()
          }
      }
      .padding(.vertical, 6)
      .background(Divider(), alignment: .bottom)
      .padding(.bottom, 8)

      if viewModel.flow == .signUp {
        HStack {
          Image(systemName: "lock")
          SecureField("Confirm password", text: $viewModel.confirmPassword)
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

      if !viewModel.errorMessage.isEmpty {
        VStack {
          Text(viewModel.errorMessage)
            .foregroundColor(Color(UIColor.systemRed))
        }
      }

      Button(action: signInWithEmailPassword) {
        if viewModel.authenticationState != .authenticating {
          Text(viewModel.flow == .login ? "Log in with password" : "Sign up")
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
        else {
          ProgressView()
            .progressViewStyle(CircularProgressViewStyle(tint: .white))
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity)
        }
      }
      .disabled(!viewModel.isValid)
      .frame(maxWidth: .infinity)
      .buttonStyle(.borderedProminent)

      HStack {
        VStack { Divider() }
        Text("or")
        VStack { Divider() }
      }

      if viewModel.flow == .login {
        SignInWithAppleButton(.signIn) { request in
        } onCompletion: { result in
        }
        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        .cornerRadius(8)
      }
      else {
        SignInWithAppleButton(.signUp) { request in
        } onCompletion: { result in
        }
        .signInWithAppleButtonStyle(colorScheme == .light ? .black : .white)
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        .cornerRadius(8)
      }

      HStack {
        Text(viewModel.flow == .login ? "Don't have an account yet?" : "Already have an account?")
        Button(action: {
          withAnimation {
            viewModel.switchFlow()
          }
        }) {
          Text(viewModel.flow == .signUp ? "Log in" : "Sign up")
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
    .environment(AuthenticationViewModel())
}
