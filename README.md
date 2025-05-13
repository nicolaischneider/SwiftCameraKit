# SwiftCameraKit

A lightweight, easy-to-use camera library for SwiftUI and UIKit applications that handle photo or video capture (or both) with a clean API.

## Features

- Photo capture with configurable quality settings
- Video recording with customizable settings
- Camera switching (front/back)
- Flash control for photos and videos
- Camera permission handling
- Video playback support
- Full support for device and simulator environments

## Installation

### Swift Package Manager

Add SwiftCameraKit to your project via Swift Package Manager:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/SwiftCameraKit.git", from: "1.0.0")
]
```

### Required Permissions

Add the following keys to your Info.plist file:

```xml
<key>NSCameraUsageDescription</key>
<string>This app needs camera access to take photos and videos</string>
<key>NSMicrophoneUsageDescription</key>
<string>This app needs microphone access to record videos with audio</string>
```

## Quick Start

Basic initialization and usage:

```swift
// Initialize camera
let cameraKit = SwiftCameraKit(view: containerView)

// Request permissions and set up camera
Task {
    let authState = await cameraKit.grantAccessForCameraAndAudio()
    if authState == .success {
        cameraKit.setupSessionAndCamera()
    }
}

// Take a photo
cameraKit.capturePhoto()

// Start/stop video recording
cameraKit.startVideoRecording()
cameraKit.stopVideoRecording()

// Switch camera and toggle flash
cameraKit.switchCamera()
cameraKit.switchFlash()
```

## Example Projects

The package includes example integrations for both SwiftUI and UIKit:

- [SwiftUI Example](Examples/SwiftCameraKitSwiftUITestApp): Demonstrates basic photo capture functionality.
- [SwiftUI Example](Examples/SwiftCameraKitUIKitTestApp): Shows more advanced features including video recording and playback.

Check the example projects for complete implementations and usage patterns.

## Configuration

SwiftCameraKit can be customized with various options:

```swift
// Create custom configuration
let config = SwiftCameraKitConfig(
    photoSetting: SwiftCameraKitConfig.PhotoSettings(
        photoSessionPreset: .high,
        highQualityPhotos: true
    ),
    videoSettings: SwiftCameraKitConfig.VideoSettings(
        videoSessionPreset: .high,
        maxVideoRecordingDuration: 60,
        videoGravity: .resizeAspectFill
    )
)

// Initialize with custom config
let cameraKit = SwiftCameraKit(view: containerView, configs: config)
```

## Requirements

- iOS 15.0 or later
- Swift 5.5 or later

## License

SwiftCameraKit is available under the MIT license. See the LICENSE file for more info.
