// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "FriendlyFlixSDK",
  platforms: [
    .iOS(.v17),
    .macOS(.v14),
    .watchOS(.v10),
    .tvOS(.v17),
  ],
  products: [
    .library(
      name: "FriendlyFlixSDK",
      targets: ["FriendlyFlixSDK"])
  ],
  dependencies: [
    .package(name: "FirebaseDataConnect", path: "../../../../")

  ],
  targets: [
    .target(
      name: "FriendlyFlixSDK",
      dependencies: [
        .product(name: "FirebaseDataConnect", package: "FirebaseDataConnect")
      ],
      path: "Sources"
    )
  ]
)
