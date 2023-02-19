// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Generative",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .library(
            name: "App",
            targets: [
                "GenerativeImage",
            ]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/ml-stable-diffusion", from: "0.2.0")
    ],
    targets: [
        .target(
            name: "GenerativeImage",
            dependencies: [
                "Service"
            ]
        ),
        .target(
            name: "Service",
            dependencies: [
                .product(name: "StableDiffusion", package: "ml-stable-diffusion")
            ],
            resources: [
                .copy("StableDiffusion")
            ]
        )
    ]
)
