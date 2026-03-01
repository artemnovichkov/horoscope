// swift-tools-version: 6.2

import PackageDescription

let package = Package(
    name: "HoroscopeClient",
    platforms: [.iOS(.v26)],
    products: [
        .library(name: "HoroscopeClient", targets: ["HoroscopeClient"]),
        .library(name: "HoroscopeClientLive", targets: ["HoroscopeClientLive"]),
    ],
    dependencies: [
        .package(path: "../GithubClient"),
        .package(url: "https://github.com/markbattistella/ZodiacKit", from: "3.1.0"),
    ],
    targets: [
        .target(name: "HoroscopeClient"),
        .target(
            name: "HoroscopeClientLive",
            dependencies: [
                "HoroscopeClient",
                .product(name: "GithubClientLive", package: "GithubClient"),
                .product(name: "ZodiacKit", package: "ZodiacKit"),
            ]
        ),
        .testTarget(
            name: "HoroscopeClientTests",
            dependencies: ["HoroscopeClient", "HoroscopeClientLive"]
        ),
    ]
)
