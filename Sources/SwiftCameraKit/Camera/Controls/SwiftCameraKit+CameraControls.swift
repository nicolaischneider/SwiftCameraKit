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

    /// Switches between photo and video capture modes.
    ///
    /// This method configures the camera session for either photo or video capture
    /// by setting the appropriate session preset and updating internal state.
    ///
    /// - Parameter mediaMode: The desired media capture mode (`.photo` or `.video`).
    ///
    /// - Note: This method can be called at any time, even while the camera is active.
    ///         The camera session will be reconfigured immediately.
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
        
    /// Toggles the flash mode between on and off.
    ///
    /// This method switches the camera flash state. In photo mode, this controls the flash
    /// when taking a picture. In video mode, this controls the torch (continuous light).
    ///
    /// - Note: When using the front camera in video mode, a screen-based flash simulation
    ///         is used since most front cameras don't have a physical flash/torch.
    public func switchFlash() {
        self.flashMode = self.flashMode.toggle
    }

    /// Switches between the front and back cameras.
    ///
    /// This method reconfigures the capture session to use the opposite camera
    /// from the one currently in use. If the back camera is active, it switches to
    /// the front camera, and vice versa.
    ///
    /// - Note: This method requires the camera session to be started and committed.
    ///         If the camera session isn't ready, the switch will not occur.
    ///
    /// - Important: This operation may take a moment to complete as it requires
    ///              reconfiguring the entire capture session.
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
