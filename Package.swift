// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LIBDSM",
    products: [
        .library(name: "LIBDSM", targets: ["LIBDSM"])
    ],
    targets: [
        .binaryTarget(name: "LIBDSM",
                      url: "https://github.com/McSims/LIBDSM/releases/download/0.0.1/LIBDSM-0.0.1.xcframework.zip",
                      checksum: "fa955714239057a4ad2079c5d37c845fa59116a67074e78cf84d1bb9084c04df")
    ]
)
