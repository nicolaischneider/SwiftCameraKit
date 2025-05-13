import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
    
    // MARK: - Photo Capture
        
    #if targetEnvironment(simulator)

    // MARK: - Simulator Mode

    public func capturePhoto() {
        LogManager.swiftCameraKit.addLog("[Simulator] Taking mock photo using system camera icon")
        self.state = .photoOutput(UIImage(systemName: "camera.viewfinder") ?? UIImage())
    }
    
    #else

    // MARK: - Device
    
    /// Captures a photo with the current camera and settings.
    ///
    /// This method takes a photo using the configured camera, applying the current
    /// flash mode and quality settings. After capture, the camera preview is temporarily
    /// paused until processing completes.
    ///
    /// - Note: The result of the photo capture will be delivered asynchronously through
    ///         the `state` property, which will be updated with either:
    ///         - `.photoOutput(UIImage)` containing the captured image
    ///         - `.error(SwiftCameraKitError)` if an error occurs
    ///
    /// - Important: The camera is automatically switched to photo mode if it's currently
    ///              in video mode. The camera preview will be paused during capture.
    ///
    /// - Requires: Camera permission must be granted and the camera session must be started
    ///             before calling this method.
    public func capturePhoto() {
        mediaMode = .photo
        
        // Immediately pause the preview layer animation
        cameraPreviewLayer?.connection?.isEnabled = false

        let settings = AVCapturePhotoSettings()
        
        // Configure photo settings for best quality
        if configs.photoSetting.highQualityPhotos {
            settings.isHighResolutionPhotoEnabled = true
            settings.photoQualityPrioritization = .quality
        }
        
        if flashMode == .on {
            settings.flashMode = .on
        }
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    #endif
}
