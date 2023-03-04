// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LIBDSM",
    products: [
        .library(name: "LIBDSM", targets: ["LIBDSM"])
    ],
    targets: [
        .binaryTarget(name: "LIBDSM",
                      url: "https://github.com/McSims/LIBDSM/releases/download/0.3.3/LIBDSM-0.3.3.xcframework.zip",
                      checksum: "ed849381ca2a0db84ed2faae54284292b72c1999fbcbb7bb0207dbc47a06ae29")
    ]
)
