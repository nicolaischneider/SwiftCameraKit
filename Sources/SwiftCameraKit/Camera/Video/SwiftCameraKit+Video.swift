import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
    
    // MARK: - Video Recording
    
    #if targetEnvironment(simulator)
    
    // MARK: Simulator
    
    public func startVideoRecording() {
        recordingState = .isRecording
        LogManager.swiftCameraKit.addLog("[Simulator] Started mock video recording (Note: No actual video will be recorded in simulator)")
    }
    
    public func stopVideoRecording() {
        recordingState = .notRecording
        LogManager.swiftCameraKit.addLog("[Simulator] Stopped mock video recording")
    }
    
    #else
    
    // MARK: Device

    /// Starts recording a video with the current camera settings.
    ///
    /// Uses temporary storage to record a video file. Recording will automatically stop
    /// when maximum duration is reached.
    ///
    /// - Note: Results delivered via `state` property as `.videoOutput(URL)` or `.error`.
    public func startVideoRecording() {
        LogManager.swiftCameraKit.addLog("Starting video recording")
        
        mediaMode = .video

        guard let movieFileOutput = movieFileOutput, !movieFileOutput.isRecording else {
            LogManager.swiftCameraKit.addLog("Cannot start recording: already recording or output not configured")
            return
        }
        
        // Make sure audio session is active
        do {
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            LogManager.swiftCameraKit.addLog("Failed to activate audio session: \(error)")
        }
        
        // Verify that audio is enabled for the connection
        if let audioConnection = movieFileOutput.connection(with: .audio) {
            if !audioConnection.isEnabled {
                LogManager.swiftCameraKit.addLog("Audio connection was disabled, enabling now")
                audioConnection.isEnabled = true
            }
        } else {
            LogManager.swiftCameraKit.addLog("No audio connection available!")
        }
        
        // Update UI state
        recordingState = .isRecording
        
        // Create temporary URL for the video file
        let tempDir = NSTemporaryDirectory()
        let tempFileName = UUID().uuidString
        let tempFileURL = URL(fileURLWithPath: tempDir)
            .appendingPathComponent(tempFileName)
            .appendingPathExtension("mov")
        
        // Configure flash if needed
        if flashMode == .on {
            setTorchForVideo(on: true)
        }
        
        // Start recording
        movieFileOutput.startRecording(to: tempFileURL, recordingDelegate: self)
        
        // Start recording timer
        startRecordingTimer()
    }
    
    /// Stops the current video recording session.
    ///
    /// Has no effect if no recording is in progress.
    public func stopVideoRecording() {
        
        LogManager.swiftCameraKit.addLog("Stop video recording")
        
        guard let movieFileOutput = movieFileOutput, movieFileOutput.isRecording else {
            LogManager.swiftCameraKit.addLog("Cannot stop recording: not currently recording")
            return
        }
        
        // Update UI state
        recordingState = .notRecording

        // Turn off torch if it was on
        if flashMode == .on {
            setTorchForVideo(on: false)
        }
        
        // Stop recording
        movieFileOutput.stopRecording()
        
        // Stop timer
        stopRecordingTimer()
    }
    
    private func setTorchForVideo(on: Bool) {
        
        guard cameraMode == .back else {
            showFrontCameraFlashForVideo(on)
            return
        }
        
        guard let device = AVCaptureDevice.default(for: .video),
              device.hasTorch,
              device.isTorchAvailable else {
            return
        }
        
        do {
            try device.lockForConfiguration()
            device.torchMode = on ? .on : .off
            device.unlockForConfiguration()
        } catch {
            LogManager.swiftCameraKit.addLog("Error toggling torch: \(error.localizedDescription)")
        }
    }
    
    private func showFrontCameraFlashForVideo(_ on: Bool) {
        if on {
            // Create and add white overlay if it doesn't exist
            if frontFlashOverlay == nil {
                frontFlashOverlay = UIView()
                frontFlashOverlay?.backgroundColor = .white
                if let firstSubview = view.subviews.first {
                    view.insertSubview(frontFlashOverlay!, aboveSubview: firstSubview)
                } else {
                    view.addSubview(frontFlashOverlay!)
                }
                frontFlashOverlay?.frame = view.bounds
            }
            
            // Store current brightness and set to max
            originalBrightness = UIScreen.main.brightness
            UIScreen.main.brightness = 1.0
            
            // Show overlay
            frontFlashOverlay?.alpha = 1.0
            
        } else {
            // Hide overlay
            frontFlashOverlay?.alpha = 0
            
            // Restore original brightness
            UIScreen.main.brightness = originalBrightness
        }
    }
    
    private func startRecordingTimer() {
        // Reset recording time
        currentRecordingDuration = 0
        
        // Start a timer that fires every second
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.currentRecordingDuration += 1
            
            // Optional: Implement a maximum recording duration (e.g., 30 seconds)
            if self.currentRecordingDuration >= self.configs.videoSettings.maxVideoRecordingDuration {
                self.stopVideoRecording()
            }
        }
    }
    
    private func stopRecordingTimer() {
        recordingTimer?.invalidate()
        recordingTimer = nil
    }
    #endif
}
