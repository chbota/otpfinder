// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "otpfinder",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(name: "otpfinder", targets: ["otpfinder"]),
    ],
    dependencies: [
        .package(url: "https://github.com/stephencelis/SQLite.swift.git", from: "0.13.3")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .executableTarget(
            name: "otpfinder",
            dependencies: [.product(name: "SQLite", package: "SQLite.swift")],
            linkerSettings: [
                    .unsafeFlags( ["-Xlinker", "-sectcreate",
                                 "-Xlinker", "__TEXT",
                                 "-Xlinker", "__info_plist",
                                 "-Xlinker", "Resources/Info.plist"] )
                ]
        )
    ]
)
