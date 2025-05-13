import AVFoundation

public struct SwiftCameraKitConfig {

    public struct PhotoSettings {
        
        /// Photo quality preset
        let photoSessionPreset: AVCaptureSession.Preset
        
        /// Boolean indicating whether high quality photos should be taken
        let highQualityPhotos: Bool
        
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
        
        /// Video recording quality preset
        let videoSessionPreset: AVCaptureSession.Preset
        /// Maximum video recording duration in seconds
        let maxVideoRecordingDuration: Int
        /// Video preview gravity mode
        let videoGravity: AVLayerVideoGravity
        
        public init(
            videoSessionPreset: AVCaptureSession.Preset = .high,
            maxVideoRecordingDuration: Int = 30,
            videoGravity: AVLayerVideoGravity = .resizeAspectFill,
        ) {
            self.videoSessionPreset = videoSessionPreset
            self.maxVideoRecordingDuration = maxVideoRecordingDuration
            self.videoGravity = videoGravity
        }
    }
    
    // MARK: - Main Properties
    let photoSetting: PhotoSettings
    let videoSettings: VideoSettings
    
    public init(
        photoSetting: PhotoSettings = PhotoSettings(),
        videoSettings: VideoSettings = VideoSettings(),
    ) {
        self.photoSetting = photoSetting
        self.videoSettings = videoSettings
    }
}
