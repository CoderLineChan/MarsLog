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
    dependencies: [],
    targets: [
        .target(
            name: "MarsLog",
            dependencies: [],
            path: ".",
            sources: ["MarsLog"],
            publicHeadersPath: "MarsLog",
            cSettings: [
                .headerSearchPath("MarsLog"),
                .headerSearchPath("mars.xcframework/ios-arm64/mars.framework/Headers"),
                .headerSearchPath("mars.xcframework/ios_x86_64-simulator/mars.framework/Headers")
            ],
            cxxSettings: [
                .headerSearchPath("MarsLog"),
                .headerSearchPath("mars.xcframework/ios-arm64/mars.framework/Headers"),
                .headerSearchPath("mars.xcframework/ios_x86_64-simulator/mars.framework/Headers"),
                .unsafeFlags(["-std=c++11"])  // 对应 C++11 配置
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
                .linkedLibrary("z"),
                .linkedFramework("Foundation"),
                .unsafeFlags([
                    "-L./mars.xcframework/ios-arm64/mars.framework",
                    "-L./mars.xcframework/ios_x86_64-simulator/mars.framework",
                    "-lmars"
                ])
            ]
        ),
        .binaryTarget(
            name: "mars",
            path: "mars.xcframework"
        )
    ],
    cxxLanguageStandard: .cxx11  // 全局 C++11 标准
)
