import UIKit
import AVFoundation

extension SwiftCameraKit {
    
    // MARK: - Camera and Audio Authorization
    
    // Add this to your view controller's initialization or viewDidLoad
    public func grantAccessForCameraAndAudio() async -> CaptureSessionState {
        // First set up the audio session
        let audioSessionReady = setupAudioSession()
        if !audioSessionReady {
            LogManager.swiftCameraKit.addLog("Failed to set up audio session")
        }
        
        // Then check permissions
        let cameraAuthorized = await setupCaptureSessionWithSuccess()
        let micAuthorized = await requestMicrophoneAccess()
        
        if cameraAuthorized && micAuthorized {
            return .success
        } else {
            
            if !cameraAuthorized && !micAuthorized {
                LogManager.swiftCameraKit.addLog("Camera and Microphone access denied")
                return .cameraAndMicrophoneNotAuthorized
            }

            if !cameraAuthorized {
                LogManager.swiftCameraKit.addLog("Camera access denied")
                return .cameraNotAuthorized
            }

            LogManager.swiftCameraKit.addLog("Microphone access denied")
            return .microphoneNotAuthorized
        }
    }
    
    private func setupCaptureSessionWithSuccess() async -> Bool {
        let cameraStatus = AVCaptureDevice.authorizationStatus(for: .video)

        switch cameraStatus {
        case .authorized:
            return true

        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        continuation.resume(returning: true)
                    } else {
                        continuation.resume(returning: false)
                    }
                }
            }

        case .denied, .restricted:
            return false

        @unknown default:
            return false
        }
    }
    
    // Add this to check for microphone permissions
    private func requestMicrophoneAccess() async -> Bool {
        let status = AVCaptureDevice.authorizationStatus(for: .audio)
        
        switch status {
        case .authorized:
            return true
        case .notDetermined:
            return await withCheckedContinuation { continuation in
                AVCaptureDevice.requestAccess(for: .audio) { granted in
                    continuation.resume(returning: granted)
                }
            }
        case .denied, .restricted:
            return false
        @unknown default:
            return false
        }
    }
        
    #if targetEnvironment(simulator)

    // MARK: - Simulator Mode

    public func setupSessionAndCamera() {
        LogManager.swiftCameraKit.addLog("[Simulator] Setting up mock camera session")
    }

    public func restartCaptureSession() {
        LogManager.swiftCameraKit.addLog("[Simulator] Restarting mock capture session")
    }

    public func stopCaptureSession() {
        LogManager.swiftCameraKit.addLog("[Simulator] Stopping mock capture session")
    }

    private func setupAudioSession() -> Bool {
        LogManager.swiftCameraKit.addLog("[Simulator] Setting up mock audio session")
        return true
    }
    
    #else
    
    // MARK: - Simulator Mode
    
    // MARK - Configuring Capture Session
    
    /// Sets up the camera capture session and preview layer.
    ///
    /// This method configures the capture session with the appropriate inputs and outputs
    /// based on the current configuration, and creates a preview layer to display
    /// the camera feed in the view.
    ///
    /// - Note: This method should be called after `grantAccessForCameraAndAudio()` has
    ///         successfully completed with a `.success` result.
    ///
    /// - Important: This method runs on the main thread as it involves UI updates
    ///              for the camera preview layer.
    public func setupSessionAndCamera() {
        DispatchQueue.main.async {
            self.configureCaptureSession()
            self.setupCameraLayer()
        }
    }
    
    /// Restarts the camera capture session if it was stopped.
    ///
    /// This method re-enables the camera preview layer connection, cleans up any
    /// video playback that might be active, and starts the capture session
    /// if it's not already running.
    ///
    /// - Note: This is useful after taking a photo or recording a video when you
    ///         want to return to the camera preview for another capture.
    ///
    /// - Important: The session restart occurs on a background thread to avoid
    ///              blocking the UI.
    public func restartCaptureSession() {
        cameraPreviewLayer?.connection?.isEnabled = true
        cleanupVideoPlayback()
        DispatchQueue.global(qos: .background).async { [weak self] in
            if let session = self?.captureSession, !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    /// Stops the active camera capture session.
    ///
    /// This method stops the camera preview and resource usage by stopping
    /// the capture session if it's currently running.
    ///
    /// - Note: After stopping the session, you can restart it with `restartCaptureSession()`.
    ///         This is automatically called when taking photos or recording videos.
    public func stopCaptureSession() {
        if let session = captureSession, session.isRunning {
            session.stopRunning()
        }
    }
    
    private func configureCaptureSession() {
        
        LogManager.swiftCameraKit.addLog("Configuring capture session...")
        
        // Start off with photo session
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = configs.photoSetting.photoSessionPreset
        captureSession?.beginConfiguration()
        
        // Support all common iOS device cameras
        let deviceTypes: [AVCaptureDevice.DeviceType] = [
            .builtInWideAngleCamera,
            .builtInDualCamera,
            .builtInDualWideCamera,  // Added for iPhone 11 and similar
            .builtInTrueDepthCamera,
            .builtInTelephotoCamera  // For devices with telephoto lens
        ]
        
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: deviceTypes,
            mediaType: .video,
            position: .unspecified)
        
        // Get default cameras
        let backCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            ?? deviceDiscoverySession.devices.first { $0.position == .back }
        let frontCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
            ?? deviceDiscoverySession.devices.first { $0.position == .front }
        
        do {
            if let backCamera = backCamera {
                try configureCamera(backCamera)
                self.backCamera = backCamera
            }
            
            if let frontCamera = frontCamera {
                try configureCamera(frontCamera)
                self.frontCamera = frontCamera
            }
            
            currentCamera = backCamera
            
            guard let currentCamera = currentCamera else {
                state = .error(.configureCaptureSessionFailed)
                return
            }
            
            let input = try AVCaptureDeviceInput(device: currentCamera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
        } catch {
            state = .error(.configureCaptureSessionFailed)
            return
        }
        
        // Configure audio for video
        let audioDevice = AVCaptureDevice.default(for: .audio)
        if let audioDevice = audioDevice {
            do {
                let audioInput = try AVCaptureDeviceInput(device: audioDevice)
                if captureSession?.canAddInput(audioInput) == true {
                    captureSession?.addInput(audioInput)
                    LogManager.swiftCameraKit.addLog("Successfully added audio input")
                } else {
                    LogManager.swiftCameraKit.addLog("Could not add audio input to session")
                }
            } catch {
                // Continue without audio rather than failing completely
                LogManager.swiftCameraKit.addLog("Could not create audio input: \(error.localizedDescription)")
            }
        }
        
        // Configure photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            if configs.photoSetting.highQualityPhotos {
                photoOutput.isHighResolutionCaptureEnabled = true
                photoOutput.maxPhotoQualityPrioritization = .quality
            }
            
            if captureSession?.canAddOutput(photoOutput) == true {
                captureSession?.addOutput(photoOutput)
            }
        }
        
        // Configure video output
        movieFileOutput = AVCaptureMovieFileOutput()
        if let movieFileOutput = movieFileOutput {
            if captureSession?.canAddOutput(movieFileOutput) == true {
                captureSession?.addOutput(movieFileOutput)
            }
            
            // Configure video stabilization if available
            if let connection = movieFileOutput.connection(with: .video) {
                if connection.isVideoStabilizationSupported {
                    connection.preferredVideoStabilizationMode = .auto
                }
            }
        }
        
        captureSession?.commitConfiguration()
        cameraSessionCommitted = true
        
        // Start session with high priority
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            self?.captureSession?.startRunning()
            self?.cameraSessionStarted = true
        }
        
        LogManager.swiftCameraKit.addLog("Configured capture session")
    }
    
    private func configureCamera(_ device: AVCaptureDevice) throws {
        try device.lockForConfiguration()
        
        // Enable auto-focus
        if device.isFocusModeSupported(.continuousAutoFocus) {
            device.focusMode = .continuousAutoFocus
        }
        
        // Enable auto-exposure
        if device.isExposureModeSupported(.continuousAutoExposure) {
            device.exposureMode = .continuousAutoExposure
        }
        
        device.unlockForConfiguration()
    }
    
    // MARK: - Setup Audio Session
    
    private func setupAudioSession() -> Bool {
        do {
            let audioSession = AVAudioSession.sharedInstance()
            
            // High-quality audio recording configuration
            try audioSession.setCategory(
                .playAndRecord,
                mode: .videoRecording,  // Specifically optimized for video recording
                options: [
                    .allowBluetooth,
                    .defaultToSpeaker,
                    .duckOthers      // Reduces volume of other audio during recording
                ]
            )
            
            // Set higher sample rate for better quality
            try audioSession.setPreferredSampleRate(44100.0)  // CD quality
            
            // Set higher I/O buffer duration for more stable recording
            try audioSession.setPreferredIOBufferDuration(0.005)  // 5ms buffer
            
            // Activate the session
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
            
            return true
        } catch {
            LogManager.swiftCameraKit.addLog("Failed to set up audio session: \(error.localizedDescription)")
            return false
        }
    }
    
    // MARK: - Setup Camera

    private func setupCameraLayer() {
        guard let captureSession else {
            LogManager.swiftCameraKit.addLog("Capture Session is nil. Image couldn't be taken.")
            return
        }
        
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = configs.videoSettings.videoGravity
        cameraPreviewLayer?.frame = view.layer.bounds
            
        guard let cameraPreviewLayer else {
            LogManager.swiftCameraKit.addLog("Camera Preview Layer is nil. Image couldn't be taken.")
            return
        }
        
        view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    
    #endif
}
