import UIKit
import AVFoundation
import os
import Photos

public class SwiftCameraKit: NSObject {
    
    var view: UIView
    
    // MARK: Public Properties
    
    internal(set) public var flashMode: FlashMode = .off
    
    internal(set) public var recordingState: RecordingVideo = .notRecording
    
    internal(set) public var mediaMode: MediaMode = .photo
    
    public var cameraMode: CameraMode {
        return self.currentCamera?.position == .front ? .front : .back
    }
    
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
    
    // MARK: Internal Properties
    
    // Camera values
    var captureSession: AVCaptureSession?
    var backCamera: AVCaptureDevice?
    var frontCamera: AVCaptureDevice?
    var currentCamera: AVCaptureDevice?
    var photoOutput: AVCapturePhotoOutput?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    // front camera flash for video
    var originalBrightness: CGFloat = 0.0
    
    // For video recording
    var movieFileOutput: AVCaptureMovieFileOutput?
    var recordingTimer: Timer?
    var recordingDuration: Int = 0
    var maxRecordingDuration: Int = 30 // Max video length in seconds
    var videoPlayer: AVPlayer?
    var frontFlashOverlay: UIView?

    // Camera Session
    var cameraSessionStarted = false
    var cameraSessionCommitted = false
    
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
