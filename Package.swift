// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "OAuth2Client",
  platforms: [.iOS(.v14), .macOS(.v11)],
  products: [
    .library(
      name: "OAuth2Client",
      targets: ["OAuth2Client"])
  ],
  dependencies: [],
  targets: [
    .target(
      name: "OAuth2Client",
      dependencies: []),
    .testTarget(
      name: "OAuth2ClientTests",
      dependencies: ["OAuth2Client"]),
  ]
)
