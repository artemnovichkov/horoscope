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
        .package(url: "https://github.com/artemnovichkov/TranscriptDebugMenu", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "MainFeature",
            dependencies: [
                "HoroscopeClient",
                .product(name: "HoroscopeClientLive", package: "HoroscopeClient"),
                "HoroscopeFeature",
                "SettingsFeature",
                .product(name: "NotificationsClientLive", package: "NotificationsClient"),
                "TranscriptDebugMenu",
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
