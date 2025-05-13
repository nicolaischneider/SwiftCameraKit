import AVFoundation

public struct SwiftCameraKitConfig {

    public struct PhotoSettings {
        
        /// Photo quality preset
        public let photoSessionPreset: AVCaptureSession.Preset
        
        /// Boolean indicating whether high quality photos should be taken
        public let highQualityPhotos: Bool
        
        public init(
            photoSessionPreset: AVCaptureSession.Preset = .photo,
            highQualityPhotos: Bool = true
        ) {
            self.photoSessionPreset = photoSessionPreset
            self.highQualityPhotos = highQualityPhotos
        }
    }
    
    // MARK: - Media Quality Settings
    public struct VideoSettings {
        
        /// Photo quality preset
        public let photoSessionPreset: AVCaptureSession.Preset
        /// Video recording quality preset
        public let videoSessionPreset: AVCaptureSession.Preset
        /// Maximum video recording duration in seconds
        public let maxVideoRecordingDuration: Int
        /// Video preview gravity mode
        public let videoGravity: AVLayerVideoGravity
        
        public init(
            photoSessionPreset: AVCaptureSession.Preset = .photo,
            videoSessionPreset: AVCaptureSession.Preset = .high,
            maxVideoRecordingDuration: Int = 30,
            videoGravity: AVLayerVideoGravity = .resizeAspectFill,
        ) {
            self.photoSessionPreset = videoSessionPreset
            self.videoSessionPreset = videoSessionPreset
            self.maxVideoRecordingDuration = maxVideoRecordingDuration
            self.videoGravity = videoGravity
        }
    }
    
    // MARK: - Camera Settings
    public struct CameraSettings {
        /// Initial camera mode (front or back)
        public let initialCameraMode: CameraMode
        /// Initial media mode (photo or video)
        public let initialMediaMode: MediaMode
        /// Initial flash mode
        public let initialFlashMode: FlashMode
        
        public init(
            initialCameraMode: CameraMode = .back,
            initialMediaMode: MediaMode = .photo,
            initialFlashMode: FlashMode = .off
        ) {
            self.initialCameraMode = initialCameraMode
            self.initialMediaMode = initialMediaMode
            self.initialFlashMode = initialFlashMode
        }
    }
    
    // MARK: - Main Properties
    public let photoSetting: PhotoSettings
    public let VideoSettings: VideoSettings
    public let cameraSettings: CameraSettings
    
    public init(
        photoSetting: PhotoSettings = PhotoSettings(),
        videoSettings: VideoSettings = VideoSettings(),
        cameraSettings: CameraSettings = CameraSettings()
    ) {
        self.photoSetting = photoSetting
        self.VideoSettings = videoSettings
        self.cameraSettings = cameraSettings
    }
}
