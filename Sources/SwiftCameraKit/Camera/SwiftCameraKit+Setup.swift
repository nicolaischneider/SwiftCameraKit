import AVFoundation
import UIKit

internal extension SwiftCameraKit {
    
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
}
