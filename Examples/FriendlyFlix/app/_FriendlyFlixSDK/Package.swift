// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "FriendlyFlixSDK",
    platforms: [
        .iOS(.v15),
        .macOS(.v10_15),
        .watchOS(.v6),
        .tvOS(.v13)
    ],
    products: [
        .library(
            name: "FriendlyFlixSDK",
            targets: ["FriendlyFlixSDK"]),
    ],
    dependencies: [
      
        .package(url: "https://github.com/firebase/firebase-ios-sdk", branch: "dataconnect"),
      
    ],
    targets: [
        .target(
            name: "FriendlyFlixSDK",
            dependencies: [
              .product(name:"FirebaseDataConnect", package:"firebase-ios-sdk")
            ],
            path: "Sources"
        )
    ]
)

