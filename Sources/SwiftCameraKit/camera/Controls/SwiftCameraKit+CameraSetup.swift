//
//  InstagramStoryController+CameraSetup.swift
//  100Questions
//
//  Created by knc on 20.12.23.
//  Copyright © 2023 Schneider & co. All rights reserved.
//

import UIKit
import AVFoundation

extension SwiftCameraKit {
    
    // MARK: - Camera and Audio Authorization
    
    func setupSessionAndCamera() {
        configureCaptureSession()
        setupCameraLayer()
    }
    
    // Add this to your view controller's initialization or viewDidLoad
    func canSetupCameraAndAudio() async -> Bool{
        // First set up the audio session
        let audioSessionReady = setupAudioSession()
        if !audioSessionReady {
            LogManager.swiftCameraKit.addLog("Failed to set up audio session")
        }
        
        // Then check permissions
        let cameraAuthorized = await setupCaptureSessionWithSuccess()
        let micAuthorized = await requestMicrophoneAccess()
        
        if cameraAuthorized && micAuthorized {
            return true
        } else {
            // Handle permission denied case
            if !cameraAuthorized {
                LogManager.swiftCameraKit.addLog("Camera access denied")
            }
            if !micAuthorized {
                LogManager.swiftCameraKit.addLog("Microphone access denied")
            }
            return false
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
    
    // MARK: - Simulator Mode
    
    #if targetEnvironment(simulator)
    private func configureCaptureSession() {}
    private func setupCameraLayer() {}
    private func setupAudioSession() -> Bool { true }
    #else
    
    // MARK: - Configuring Capture Session
    
    private func configureCaptureSession() {
        
        // Start off iwth photo session
        captureSession = AVCaptureSession()
        captureSession?.sessionPreset = .photo
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
                // callErrorView()
                return
            }
            
            let input = try AVCaptureDeviceInput(device: currentCamera)
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
        } catch {
            // callErrorView()
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
                LogManager.swiftCameraKit.addLog("Could not create audio input: \(error.localizedDescription)")
                // Continue without audio rather than failing completely
            }
        }
        
        // Configure photo output
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput {
            photoOutput.isHighResolutionCaptureEnabled = true
            photoOutput.maxPhotoQualityPrioritization = .quality
            
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
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.frame = view.view.layer.bounds
            
        guard let cameraPreviewLayer else {
            LogManager.swiftCameraKit.addLog("Camera Preview Layer is nil. Image couldn't be taken.")
            return
        }
        
        view.view.layer.insertSublayer(cameraPreviewLayer, at: 0)
    }
    #endif
}
