// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "JanoPaymentservicesAPI",
    products: [
        .library(name: "JanoPaymentservicesAPI", targets: ["JanoPaymentservicesAPI"])
    ],
    dependencies: [
        .package(url: "https://github.com/Alamofire/Alamofire.git", .exact("4.7.2")),
        .package(url: "https://github.com/antitypical/Result.git", .exact("4.0.0")),
    ],
    targets: [
        .target(name: "JanoPaymentservicesAPI", dependencies: [
          "Alamofire",
          "Result",
        ], path: "Sources")
    ]
)
