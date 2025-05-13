import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
    
    // MARK: - Photo Capture
    
    // Simulator
    
    /* HIDING SIMULATOR FEATURE FOR NOW
    #if targetEnvironment(simulator)
    func capturePhoto() {
        self.finalPhoto = UIImage(named: "story-static-img")!
    }
    
    // Real Device
    #else*/
    public func capturePhoto() {
        mediaMode = .photo
        
        // Immediately pause the preview layer animation
        cameraPreviewLayer?.connection?.isEnabled = false

        let settings = AVCapturePhotoSettings()
        
        // Configure photo settings for best quality
        settings.isHighResolutionPhotoEnabled = true
        settings.photoQualityPrioritization = .quality
        
        if flashMode == .on {
            settings.flashMode = .on
        }
        
        photoOutput?.capturePhoto(with: settings, delegate: self)
    }
    //#endif
}
