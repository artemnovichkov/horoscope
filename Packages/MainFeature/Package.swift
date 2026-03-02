// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "MainFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "MainFeature",
            targets: ["MainFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../HoroscopeClient"),
        .package(path: "../HoroscopeFeature"),
        .package(path: "../SettingsFeature"),
        .package(path: "../NotificationsClient"),
        .package(url: "https://github.com/artemnovichkov/TranscriptDebugMenu", exact: "1.6.4"),
    ],
    targets: [
        .target(
            name: "MainFeature",
            dependencies: [
                "HoroscopeClient",
                "HoroscopeFeature",
                "SettingsFeature",
                .product(name: "NotificationsClient", package: "NotificationsClient"),
                "TranscriptDebugMenu",
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
