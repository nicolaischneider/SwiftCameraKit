//
//  InstagramStoryController+Video.swift
//  100Questions
//
//  Created by knc on 04.04.25.
//  Copyright © 2025 Schneider & co. All rights reserved.
//

import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
    
    // MARK: - Video Recording
    
    #if targetEnvironment(simulator)
    
    // MARK: Simulator
    
    func startVideoRecording() {
        isRecordingVideo = true
    }
    
    func stopVideoRecording() {
        isRecordingVideo = false
    }
    #else
    
    // MARK: Device

    func startVideoRecording() {
        self.isPhotoMode = false

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
        isRecordingVideo = true
        
        // Create temporary URL for the video file
        let tempDir = NSTemporaryDirectory()
        let tempFileName = UUID().uuidString
        let tempFileURL = URL(fileURLWithPath: tempDir)
            .appendingPathComponent(tempFileName)
            .appendingPathExtension("mov")
        
        // Configure flash if needed
        if shouldUseFlash {
            setTorchForVideo(on: true)
        }
        
        // Start recording
        movieFileOutput.startRecording(to: tempFileURL, recordingDelegate: self)
        
        // Start recording timer
        startRecordingTimer()
    }
    
    func stopVideoRecording() {
        guard let movieFileOutput = movieFileOutput, movieFileOutput.isRecording else {
            LogManager.swiftCameraKit.addLog("Cannot stop recording: not currently recording")
            return
        }
        
        // Update UI state
        isRecordingVideo = false
        
        // Turn off torch if it was on
        if shouldUseFlash {
            setTorchForVideo(on: false)
        }
        
        // Stop recording
        movieFileOutput.stopRecording()
        
        // Stop timer
        stopRecordingTimer()
    }
    
    private func setTorchForVideo(on: Bool) {
        
        guard !self.isUsingFrontCamera else {
            // view.showFrontCameraFlashForVideo(on)
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
    
    private func startRecordingTimer() {
        // Reset recording time
        recordingDuration = 0
        
        // Start a timer that fires every second
        recordingTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.recordingDuration += 1
            
            // Optional: Implement a maximum recording duration (e.g., 30 seconds)
            if self.recordingDuration >= self.maxRecordingDuration {
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
