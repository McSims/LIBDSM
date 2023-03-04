// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LIBDSM",
    products: [
        .library(name: "LIBDSM", targets: ["LIBDSM"])
    ],
    targets: [
        .binaryTarget(name: "LIBDSM",
                      url: "https://github.com/McSims/LIBDSM/releases/download/0.3.5/LIBDSM-0.3.5.xcframework.zip",
                      checksum: "ce29e8c4eed84fd0cece21aa7618952ea61cada3ee78e0147e42ffd0716dee05")
    ]
)
