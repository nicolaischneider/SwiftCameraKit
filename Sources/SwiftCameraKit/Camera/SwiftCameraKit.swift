import UIKit
import AVFoundation
import os
import Photos

public class SwiftCameraKit: NSObject {
    
    var view: UIViewController
    
    // Camera values
    var captureSession: AVCaptureSession?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    var shouldUseFlash = false
    
    var isUsingFrontCamera: Bool {
        self.currentCamera?.position == .front
    }
    
    // front camera flash for video
    var originalBrightness: CGFloat = 0.0
    
    // For video recording
    var movieFileOutput: AVCaptureMovieFileOutput?
    var isRecordingVideo = false
    var isPhotoMode = true // Default to photo mode
    var recordingTimer: Timer?
    var recordingDuration: Int = 0
    var maxRecordingDuration: Int = 30 // Max video length in seconds
    var videoPlayer: AVPlayer?

    // Camera Session
    var cameraSessionStarted = false
    var cameraSessionCommitted = false
        
    @Published public var state: CameraOutput?
    
    public init(
        view: UIViewController
    ) {
        self.view = view
    }
    
    deinit {
        reset()
    }
    
    func subscribeToObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(pauseVideo),
            name: UIApplication.didEnterBackgroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartVideo),
            name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    func retakeImage() {
        cameraPreviewLayer?.connection?.isEnabled = true
        cleanupVideoPlayback()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let session = self?.captureSession, !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    func stopCaptureSession() {
        if let session = captureSession, session.isRunning {
            session.stopRunning()
        }
    }
}
