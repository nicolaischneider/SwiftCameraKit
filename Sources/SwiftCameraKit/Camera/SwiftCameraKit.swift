import UIKit
import AVFoundation
import os
import Photos

/// A comprehensive camera management class that handles photo and video capture
/// with support for different camera modes, flash settings, and configuration options.
///
/// `SwiftCameraKit` provides a complete solution for camera integration in iOS applications,
/// handling camera setup, permissions, capturing photos, recording videos, and managing camera state.
///
/// Example usage:
/// ```
/// let cameraView = UIView()
/// let cameraKit = SwiftCameraKit(view: cameraView)
/// await cameraKit.grantAccessForCameraAndAudio()
/// cameraKit.setupSessionAndCamera()
/// ```
public class SwiftCameraKit: NSObject {
    
    var view: UIView
    
    // MARK: Public Properties
    
    /// The current flash mode setting for the camera.
    ///
    /// This property determines whether the camera flash (or torch for video) is enabled.
    /// Use `switchFlash()` method to toggle between different flash modes.
    internal(set) public var flashMode: FlashMode = .off
    
    /// The current video recording state of the camera.
    ///
    /// This property indicates whether the camera is currently recording video.
    /// It will be `.isRecording` during active recording and `.notRecording` otherwise.
    internal(set) public var recordingState: RecordingVideo = .notRecording
    
    /// The current media capture mode of the camera.
    ///
    /// This property determines whether the camera is configured for photo or video capture.
    /// Use `switchCaptureMode(to:)` method to change between photo and video mode.
    internal(set) public var mediaMode: MediaMode = .photo
    
    /// The current camera position (front or back).
    ///
    /// This computed property returns the current active camera position.
    /// Use `switchCamera()` method to toggle between front and back cameras.
    public var cameraMode: CameraMode {
        return self.currentCamera?.position == .front ? .front : .back
    }
    
    /// The current output state of the camera.
    ///
    /// This property contains the result of camera operations:
    /// - `.photoOutput(UIImage)` when a photo is captured
    /// - `.videoOutput(URL)` when a video is recorded
    /// - `.error(SwiftCameraKitError)` when an error occurs
    ///
    /// Observe changes to this property to handle captured media or errors.
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
    
    /// Initializes a new SwiftCameraKit instance.
    ///
    /// - Parameters:
    ///   - view: The UIView where the camera preview will be displayed.
    ///   - configs: Configuration options for the camera. Uses default settings if not specified.
    ///
    /// After initialization, you should call `grantAccessForCameraAndAudio()` to request permissions,
    /// followed by `setupSessionAndCamera()` to configure and start the camera session.
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
