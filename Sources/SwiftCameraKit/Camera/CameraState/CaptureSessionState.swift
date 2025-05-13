/// Represents the authorization state of the camera capture session.
///
/// This enum is returned by the `grantAccessForCameraAndAudio()` method to indicate
/// whether permissions were successfully granted for camera and microphone access.
public enum CaptureSessionState {
    /// Indicates that both camera and microphone access were successfully authorized.
    ///
    /// The app has full permission to capture photos and videos with audio.
    case success
    
    /// Indicates that camera access was denied but microphone access was granted.
    ///
    /// In this state, the app cannot capture photos or videos. The user should be prompted
    /// to grant camera permissions in the device settings.
    case cameraNotAuthorized
    
    /// Indicates that microphone access was denied but camera access was granted.
    ///
    /// In this state, photos and videos can still be taken, but videos will not include audio.
    /// The user can be prompted to grant microphone permissions in the device settings if audio is required.
    case microphoneNotAuthorized
    
    /// Indicates that both camera and microphone access were denied.
    ///
    /// In this state, the app cannot capture photos or videos. The user should be prompted
    /// to grant both camera and microphone permissions in the device settings.
    case cameraAndMicrophoneNotAuthorized
}
