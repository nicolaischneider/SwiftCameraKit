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
