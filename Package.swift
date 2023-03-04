// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "LIBDSM",
    products: [
        .library(name: "LIBDSM", targets: ["LIBDSM"])
    ],
    targets: [
        .binaryTarget(name: "LIBDSM",
                      url: "https://github.com/McSims/LIBDSM/releases/download/0.3.4/LIBDSM-0.3.4.xcframework.zip",
                      checksum: "8c79711a52d379162c7cb6f37153a276e3f619498812881ef462bc7cc3ae5064")
    ]
)
