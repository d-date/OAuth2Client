// swift-tools-version:5.3

import PackageDescription

let package = Package(
  name: "OAuth2Client",
  platforms: [.iOS("15.0"), .macOS("12.0")],
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
