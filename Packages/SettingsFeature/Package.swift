// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "SettingsFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "SettingsFeature",
            targets: ["SettingsFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../NotificationsClient"),
    ],
    targets: [
        .target(
            name: "SettingsFeature",
            dependencies: [
                "NotificationsClient"
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
