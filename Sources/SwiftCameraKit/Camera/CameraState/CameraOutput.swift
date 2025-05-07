import Foundation
import UIKit

public enum CameraOutput {
    case photoOutput(UIImage)
    case videoOutput(URL)
    case error(SwiftCameraKitError)
}
