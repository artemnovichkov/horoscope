// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "GithubClient",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "GithubClient",
            targets: ["GithubClient"]),
        .library(
            name: "GithubClientLive",
            targets: ["GithubClientLive"]),
    ],
    targets: [
        .target(name: "GithubClient"),
        .target(name: "GithubClientLive", dependencies: ["GithubClient"]),
        .testTarget(name: "GithubClientTests", dependencies: ["GithubClient", "GithubClientLive"]),
    ]
)
