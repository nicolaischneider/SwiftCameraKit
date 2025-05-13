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
    var currentRecordingDuration: Int = 0
    var videoPlayer: AVPlayer?
    var frontFlashOverlay: UIView? // white brightr screen for flash during video recording using front camera

    // Camera Session
    var cameraSessionStarted = false
    var cameraSessionCommitted = false
    
    // Configs
    var configs: SwiftCameraKitConfig
    
    public init(
        view: UIView,
        configs: SwiftCameraKitConfig = SwiftCameraKitConfig()
    ) {
        self.view = view
        self.configs = configs
        super.init()
        self.subscribeToObserver()
    }
}
