import Foundation

extension SwiftCameraKit {
    /// Call this function when the controller is no longer needed or when you need to reset the camera state completely.
    /// **IMPORTANT**: to void memory leaks always reset before dismissing
    public func reset() {
        // Stop any ongoing video recording
        breakVideoRecording()
        
        // Stop and clean up the capture session
        breakCaptureSession()
        
        // Clean up timer resources
        invalidateTimers()
        
        // Clean up video playback
        cleanUpVideoPlayer()
        
        // Clean up file resources
        cleanUpTemporaryFiles()
        
        // Reset states and flags
        resetStateVariables()
        
        // Remove notification observers
        removeObservers()
        
        LogManager.swiftCameraKit.addLog("SwiftCameraKit: reset completed")
    }

    // Stop any active video recording
    private func breakVideoRecording() {
        if recordingState == .isRecording, let movieFileOutput = movieFileOutput {
            recordingState = .notRecording
            movieFileOutput.stopRecording()
        }
    }

    // Properly stop the capture session
    private func breakCaptureSession() {
        // Stop the session on a background thread to avoid UI freezes
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self else { return }
            
            // Stop running session
            self.captureSession?.stopRunning()
            
            // Remove all inputs and outputs to free up resources
            if let session = self.captureSession {
                for input in session.inputs {
                    session.removeInput(input)
                }
                
                for output in session.outputs {
                    session.removeOutput(output)
                }
            }
            
            // Clean up preview layer on main thread
            DispatchQueue.main.async { [weak self] in
                self?.cameraPreviewLayer?.removeFromSuperlayer()
                self?.cameraPreviewLayer = nil
            }
            
            // Set flags
            self.cameraSessionStarted = false
            self.cameraSessionCommitted = false
            
            // Clear session reference
            self.captureSession = nil
        }
    }

    // Clean up any active timers
    private func invalidateTimers() {
        recordingTimer?.invalidate()
        recordingTimer = nil
        currentRecordingDuration = 0
    }

    // Clean up video player resources
    private func cleanUpVideoPlayer() {
        videoPlayer?.pause()
        videoPlayer?.replaceCurrentItem(with: nil)
        videoPlayer = nil
    }

    // Clean up temporary files created during capture
    private func cleanUpTemporaryFiles() {
        // Delete temporary video files
        let fileManager = FileManager.default
        
        if case .videoOutput(let url) = state {
            try? fileManager.removeItem(at: url)
        }
        
        state = nil
    }

    // Reset all state variables to their initial values
    private func resetStateVariables() {
        // Camera configuration
        backCamera = nil
        frontCamera = nil
        currentCamera = nil
        photoOutput = nil
        movieFileOutput = nil
        flashMode = .off
        
        // Recording state
        recordingState = .notRecording
        mediaMode = .photo
    }

    // Remove any notification observers
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
