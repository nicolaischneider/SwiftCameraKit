import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
 
    #if targetEnvironment(simulator)
    
    // MARK: - Simulator
    
    // Switch between photo and video mode
    public func switchCaptureMode(to mediaMode: MediaMode) {
        self.mediaMode = mediaMode
        // Notify any observers or update UI if needed
        LogManager.swiftCameraKit.addLog("[Simulator] Switched to \(mediaMode) mode")
    }
    
    // Turn on/off flash
    public func switchFlash() {
        self.flashMode = self.flashMode.toggle
        LogManager.swiftCameraKit.addLog("[Simulator] Flash switched to \(flashMode)")
    }
    
    // Switches between back and front camera
    public func switchCamera() {
        LogManager.swiftCameraKit.addLog("[Simulator] Camera switched")
    }
    
    #else
    
    // MARK: - Device

    // MARK: Camera Controls

    // Switch between photo and video mode
    public func switchCaptureMode(to mediaMode: MediaMode) {
        // no need to update the configs if settings are already set
        self.mediaMode = mediaMode
        
        captureSession?.beginConfiguration()
        
        // Update session preset based on mode
        switch mediaMode {
        case .photo:
            captureSession?.sessionPreset = configs.photoSetting.photoSessionPreset

        case .video:
            captureSession?.sessionPreset = configs.videoSettings.videoSessionPreset
        }
        
        captureSession?.commitConfiguration()
    }
        
    // Turn on/off flash
    public func switchFlash() {
        self.flashMode = self.flashMode.toggle
    }

    // Switches between back and front camera
    public func switchCamera() {
        guard cameraSessionStarted, cameraSessionCommitted else {
            LogManager.swiftCameraKit.addLog("Camera hasn't loaded yet.")
            return
        }
        
        guard let session = captureSession, let currentCamera = currentCamera else {
            state = .error(.cameraSwitchFailed)
            return
        }

        session.beginConfiguration()

        // Remove all inputs
        session.inputs.forEach { input in
            session.removeInput(input)
        }

        // Remove and re-add video output if in video mode
        if mediaMode == .video, let output = movieFileOutput {
            session.removeOutput(output)
        }

        // Switch current camera
        self.currentCamera = (currentCamera.position == .back) ? frontCamera : backCamera

        do {
            guard let newCamera = self.currentCamera else {
                state = .error(.cameraSwitchFailed)
                session.commitConfiguration()
                return
            }

            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if session.canAddInput(newInput) {
                session.addInput(newInput)
            }

            // Re-add video output if in video mode
            if mediaMode == .video, let output = movieFileOutput, session.canAddOutput(output) {
                session.addOutput(output)
            }
        } catch {
            DispatchQueue.main.async {
                self.state = .error(.cameraSwitchFailed)
            }
            session.commitConfiguration()
            return
        }

        session.commitConfiguration()
    }
    #endif
}
