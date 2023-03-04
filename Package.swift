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
                      checksum: "589e1e094cd122c3010917f7dfad6d2af6e8c675453df929d06cfcc24967b61b")
    ]
)
