// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HoroscopeFeature",
    platforms: [.iOS(.v26)],
    products: [
        .library(
            name: "HoroscopeFeature",
            targets: ["HoroscopeFeature"]
        ),
    ],
    dependencies: [
        .package(path: "../HoroscopeClient"),
        .package(url: "https://github.com/markbattistella/ZodiacKit", from: "3.1.0"),
    ],
    targets: [
        .target(
            name: "HoroscopeFeature",
            dependencies: [
                "HoroscopeClient",
                .product(name: "ZodiacKit", package: "ZodiacKit"),
            ],
            resources: [
                .process("Resources")
            ]
        ),
    ]
)
