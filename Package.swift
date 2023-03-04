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
                      checksum: "a94403492a4fb3221f9bfc88c33a765cd50a8a0b007fb5d2e1a8311cd9de1246")
    ]
)
