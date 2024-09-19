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
  platforms: [.iOS(.v12), .macCatalyst(.v13), .macOS(.v10_15), .tvOS(.v13), .watchOS(.v7)],
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
      from: "1.19.1" // TODO: Constrain to a range at time of release
    ),
  ],
  targets: [
    .target(
      name: "FirebaseDataConnect",
      dependencies: [
        .product(name: "GRPC", package: "grpc-swift"),
        .product(name: "FirebaseCore", package: "firebase-ios-sdk"),
        // TODO: Investigate switching Auth and AppCheck to interop.
        .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
        .product(name: "FirebaseAppCheck", package: "firebase-ios-sdk"),

      ],
      path: "Sources"
    ),
    .testTarget(
      name: "FirebaseDataConnectUnit",
      dependencies: ["FirebaseDataConnect"],
      path: "Tests/Unit"
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

  return .package(url: firebaseURL, exact: "11.3.0")
}
