// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to
// build this package.

// Copyright 2020 Google LLC
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

import class Foundation.ProcessInfo
import PackageDescription

let package = Package(
  name: "FirebaseDataConnect",
  platforms: [.iOS(.v15), .macOS(.v12), .tvOS(.v15), .watchOS(.v8)],
  products: [
    .library(
      name: "FirebaseDataConnect",
      targets: ["FirebaseDataConnect"]
    ),
  ],
  dependencies: [
    firebaseDependency(),
    .package(
      url: "https://github.com/grpc/grpc-swift.git",
      exact: "1.23.1"
    ),
    .package(
      url: "https://github.com/google/GoogleUtilities.git",
      "8.0.0" ..< "9.0.0"
    ),
  ],
  targets: [
    .target(
      name: "FirebaseDataConnect",
      dependencies: [
        .product(name: "GRPC", package: "grpc-swift"),
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),

        // TODO: Add FirebaseAppCheckInterop as a dependency once its available as an external library
        // TODO: Investigate switching Auth to interop.
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "GULEnvironment", package: "GoogleUtilities"),
      ],
      path: "Sources"
    ),
    .testTarget(
      name: "FirebaseDataConnectUnit",
      dependencies: ["FirebaseDataConnect"],
      path: "Tests/Unit"
    ),
    .testTarget(
      name: "FirebaseDataConnectIntegration",
      dependencies: ["FirebaseDataConnect"],
      path: integrationTestPath(),
      exclude: ["Gen/KitchenSink/Package.swift"],
      resources: [
        .copy("Resources/fdc-kitchensink"),
      ]
    ),
  ]
)

func firebaseDependency() -> Package.Dependency {
  let firebaseURL = "https://github.com/firebase/firebase-ios-sdk"

  // Point SPM CI to the tip of main of https://github.com/firebase/firebase-ios-sdk so that the
  // release process can defer publishing the GoogleAppMeasurement tag until after testing.
  if ProcessInfo.processInfo.environment["FIREBASE_MAIN"] != nil {
    return .package(url: firebaseURL, branch: "main")
  }

  return .package(url: firebaseURL, from: "11.5.0")
}

func integrationTestPath() -> String? {
  // Set this env variable to disable integration tests being run as part of CI
  if ProcessInfo.processInfo.environment["DISABLE_INTEGRATION_TESTS"] != nil {
    return "Tests/NoIntegration"
  } else {
    return "Tests/Integration"
  }
}
