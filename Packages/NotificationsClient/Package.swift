// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "NotificationsClient",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "NotificationsClient",
            targets: ["NotificationsClient"]),
        .library(
            name: "NotificationsClientLive",
            targets: ["NotificationsClientLive"]),
    ],
    targets: [
        .target(name: "NotificationsClient"),
        .target(name: "NotificationsClientLive", dependencies: ["NotificationsClient"]),
        .testTarget(name: "NotificationsClientTests", dependencies: ["NotificationsClient", "NotificationsClientLive"]),
    ]
)
