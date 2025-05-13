import Foundation
import UIKit

/// Represents the possible output states of the camera operations.
///
/// This enum is used by `SwiftCameraKit` to communicate the result of
/// photo capture or video recording operations, or any errors that occurred.
///
/// - Note: The `state` property of `SwiftCameraKit` returns values of this type.
public enum CameraOutput {
    /// Indicates that a photo was successfully captured.
    ///
    /// - Parameter UIImage: The captured photo as a UIImage.
    case photoOutput(UIImage)
    
    /// Indicates that a video was successfully recorded.
    ///
    /// - Parameter URL: The file URL where the recorded video is stored.
    /// - Note: This URL points to a temporary file location that should be processed or moved
    ///         before the SwiftCameraKit instance is reset.
    case videoOutput(URL)
    
    /// Indicates that an error occurred during a camera operation.
    ///
    /// - Parameter SwiftCameraKitError: The specific error that occurred.
    case error(SwiftCameraKitError)
}
