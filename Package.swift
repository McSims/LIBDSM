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
                      checksum: "e58805af24de43acbcd46a9a3650639ce43407b3eabc90ac078779fd1e437636")
    ]
)
