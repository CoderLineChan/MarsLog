// swift-tools-version:5.3
import PackageDescription


let package = Package(
    name: "MarsLog",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "MarsLog",
            targets: ["MarsLog"]),
    ],
    targets: [
        .target(
            name: "MarsLog",
            dependencies: ["mars"],
            path: "MarsLog",
            publicHeadersPath: ".",
            cSettings: [
                .headerSearchPath("../mars.xcframework/ios-arm64/mars.framework/Headers"),
                .headerSearchPath("../mars.xcframework/ios-arm64-simulator/mars.framework/Headers")
            ],
            cxxSettings: [
                .headerSearchPath("../mars.xcframework/ios-arm64/mars.framework/Headers"),
                .headerSearchPath("../mars.xcframework/ios-arm64-simulator/mars.framework/Headers")
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
