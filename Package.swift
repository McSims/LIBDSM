// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LIBDSM",
    products: [
        .library(name: "LIBDSM", targets: ["LIBDSM"])
    ],
    targets: [
        .binaryTarget(name: "LIBDSM",
                      url: "https://github.com/McSims/LIBDSM/releases/download/0.3.2/LIBDSM-0.3.2.xcframework.zip",
                      checksum: "d0ea4efa3d42ab41b0b153b386d6545fa74dd83b26872434c93646e2266d8a02")
    ]
)
