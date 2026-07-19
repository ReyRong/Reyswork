// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SleepAidApp",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "SleepAidApp", targets: ["SleepAidApp"])
    ],
    targets: [
        .executableTarget(
            name: "SleepAidApp",
            resources: [
                .process("Resources")
            ]
        ),
        .testTarget(
            name: "SleepAidAppTests",
            dependencies: ["SleepAidApp"]
        )
    ]
)
