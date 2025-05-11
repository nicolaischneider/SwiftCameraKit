import UIKit
import AVFoundation
import os
import Photos

public class SwiftCameraKit: NSObject {
    
    var view: UIView
    
    // Camera values
    var captureSession: AVCaptureSession?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    public var shouldUseFlash = false
    
    var isUsingFrontCamera: Bool {
        self.currentCamera?.position == .front
    }
    
    // front camera flash for video
    var originalBrightness: CGFloat = 0.0
    
    // For video recording
    var movieFileOutput: AVCaptureMovieFileOutput?
    public var isRecordingVideo = false
    public var isPhotoMode = true // Default to photo mode
    var recordingTimer: Timer?
    var recordingDuration: Int = 0
    var maxRecordingDuration: Int = 30 // Max video length in seconds
    var videoPlayer: AVPlayer?

    // Camera Session
    var cameraSessionStarted = false
    var cameraSessionCommitted = false
        
    @Published public var state: CameraOutput? {
        didSet {
            // Clean up previous video file if we're changing from .videoOutput to something else
            if case .videoOutput(let oldURL) = oldValue {
                // Only delete if we're changing to a different case or nil
                switch state {
                case .videoOutput(let newURL) where newURL == oldURL:
                    // Same URL, don't delete
                    break
                default:
                    // Different case or nil, safe to delete old file
                    try? FileManager.default.removeItem(at: oldURL)
                }
            }
        }
    }
    
    public init(
        view: UIView
    ) {
        self.view = view
        super.init()
        self.subscribeToObserver()
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
    
    public func restartCaptureSession() {
        cameraPreviewLayer?.connection?.isEnabled = true
        cleanupVideoPlayback()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let session = self?.captureSession, !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    public func stopCaptureSession() {
        if let session = captureSession, session.isRunning {
            session.stopRunning()
        }
    }
}
