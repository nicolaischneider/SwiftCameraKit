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
