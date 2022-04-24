// swift-tools-version: 5.5

// WARNING:
// This file is automatically generated.
// Do not edit it by hand because the contents will be replaced.

import PackageDescription
import AppleProductTypes

let package = Package(
    name: "Athletic Robot",
    platforms: [
        .iOS("15.2")
    ],
    products: [
        .iOSApplication(
            name: "Athletic Robot",
            targets: ["AppModule"],
            bundleIdentifier: "com.saschasalles.athleticrobot.Athletic-Robot",
            teamIdentifier: "85Y7A7HSKG",
            displayVersion: "1.0",
            bundleVersion: "1",
            iconAssetName: "AppIcon",
            accentColorAssetName: "AccentColor",
            supportedDeviceFamilies: [
                .pad,
            ],
            supportedInterfaceOrientations: [.portrait],
            capabilities: [
                .camera(purposeString: "Athletic Robot needs access to the camera to detect your movements.")
            ]
        )
    ],
    targets: [
        .executableTarget(
            name: "AppModule",
            path: ".",
	    resources: [
            	.process("Resources/3DAssets/RobotScene.scn"),
		.process("Resources/3DAssets/FocusScene.scn"),
		.process("Resources/MLModel/WorkoutClassifier.mlmodelc"),
       		.process("Resources/Sounds/WWDC22SoftSong.m4a")
            ]
        )
    ]
)