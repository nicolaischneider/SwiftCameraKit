import UIKit
import AVFoundation
import os

// MARK: - AVCaptureFileOutputRecordingDelegate
extension SwiftCameraKit: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Handle recording started
        DispatchQueue.main.async {
            LogManager.swiftCameraKit.addLog("Video recording started")
        }
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {        
        if let error = error {
            LogManager.swiftCameraKit.addLog("Error recording video: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .error(.videoOutputFailed)
            }
            return
        }
        
        // Process recorded video
        processRecordedVideo(videoURL: outputFileURL)
    }
    
    private func processRecordedVideo(videoURL: URL) {
        LogManager.swiftCameraKit.addLog("Video recording finished and processed")
        
        // Store original URL
        self.state = .videoOutput(videoURL)
        
        DispatchQueue.main.async {
            self.stopCaptureSession()
        }
    }
}
