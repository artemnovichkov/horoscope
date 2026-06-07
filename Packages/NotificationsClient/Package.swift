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
        .target(name: "NotificationsClient", swiftSettings: [.defaultIsolation(MainActor.self)]),
        .target(name: "NotificationsClientLive", dependencies: ["NotificationsClient"], swiftSettings: [.defaultIsolation(MainActor.self)]),
        .testTarget(name: "NotificationsClientTests", dependencies: ["NotificationsClient", "NotificationsClientLive"], swiftSettings: [.defaultIsolation(MainActor.self)]),
    ]
)
