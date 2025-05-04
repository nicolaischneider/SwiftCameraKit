import Foundation

extension SwiftCameraKit {
    // Call this function when the controller is no longer needed
    // or when you need to reset the camera state completely
    func reset() {
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
    }

    // Stop any active video recording
    private func breakVideoRecording() {
        if isRecordingVideo, let movieFileOutput = movieFileOutput {
            isRecordingVideo = false
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
        recordingDuration = 0
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
        
        if let originalURL = originalVideoURL, fileManager.fileExists(atPath: originalURL.path) {
            try? fileManager.removeItem(at: originalURL)
            originalVideoURL = nil
        }
        
        if let finalURL = finalVideoURL, fileManager.fileExists(atPath: finalURL.path) {
            try? fileManager.removeItem(at: finalURL)
            finalVideoURL = nil
        }
        
        // Clear photo references to release memory
        finalPhoto = nil
    }

    // Reset all state variables to their initial values
    private func resetStateVariables() {
        // Camera configuration
        backCamera = nil
        frontCamera = nil
        currentCamera = nil
        photoOutput = nil
        movieFileOutput = nil
        shouldUseFlash = false
        
        // Recording state
        isRecordingVideo = false
        isPhotoMode = true
        videoHasWatermark = true
        
        // Flags and statuses
        errorOccurred = false
        error = nil
    }

    // Remove any notification observers
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
    }
}
