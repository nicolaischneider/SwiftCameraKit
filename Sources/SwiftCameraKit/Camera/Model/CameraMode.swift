public enum FlashMode {
    case off
    case on
    
    var toggle: FlashMode {
        switch self {
        case .off:
            return .on
        case .on:
            return .off
        }
    }
}

public enum RecordingVideo {
    case isRecording
    case notRecording
}

public enum MediaMode {
    case photo
    case video
}

public enum CameraMode {
    case front
    case back
}
