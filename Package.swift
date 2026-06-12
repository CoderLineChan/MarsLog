// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "MarsLog",
    platforms: [.iOS("15.0")],
    products: [
        .library(
            name: "MarsLog",
            type: .static,
            targets: ["MarsLog"]),
    ],
    targets: [
        .target(
            name: "MarsLog",
            dependencies: ["CMarsLog"],
            path: "Sources/MarsLog"
        ),
        .target(
            name: "CMarsLog",
            dependencies: ["mars"],
            path: "MarsLog",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("../mars.xcframework/ios-arm64/Headers"),
                .headerSearchPath("../mars.xcframework/ios-arm64_x86_64-simulator/Headers")
            ],
            cxxSettings: [
                .headerSearchPath("../mars.xcframework/ios-arm64/Headers"),
                .headerSearchPath("../mars.xcframework/ios-arm64_x86_64-simulator/Headers")
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("z"),
                .linkedFramework("Foundation")
            ]
        ),
        .binaryTarget(
            name: "mars",
            path: "mars.xcframework"
        )
    ],
    cxxLanguageStandard: .cxx11
)
