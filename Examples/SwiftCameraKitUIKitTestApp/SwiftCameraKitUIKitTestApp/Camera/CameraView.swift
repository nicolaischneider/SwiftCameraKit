import UIKit
import SwiftCameraKit
import SimpleConstraints

class CameraView: UIView {
    
    // camera buttons
    let captureButton = UIButton.viewWithImage(
        image: "capture_icon",
        tintColor: .white,
        cornerRadius: nil,
        shadow: true,
        function: nil)
        
    let recordingRedDot = UIView.view(corner: 13, shadow: false, background: .red)
    
    let switchCameraButton = UIButton.viewWithImage(
        image: "switch_camera",
        tintColor: .white,
        cornerRadius: nil,
        shadow: false,
        function: nil)
    
    let switchFlashButton = UIButton.viewWithImage(
        image: "flash_off",
        tintColor: .white,
        cornerRadius: nil,
        shadow: false,
        function: nil)
    
    // mode toggle buttons
    let photoModeButton = UIButton.viewWithText(
        text: "PHOTO",
        color: .white,
        font: UIFont.systemFont(ofSize: 14),
        cornerRadius: nil,
        shadow: true,
        function: nil)
    
    let videoModeButton = UIButton.viewWithText(
        text: "VIDEO",
        color: UIColor(white: 1, alpha: 0.5),
        font: UIFont.systemFont(ofSize: 14),
        cornerRadius: nil,
        shadow: true,
        function: nil)
    
    let frontCameraVideoFlash = UIView.view(
        corner: nil,
        shadow: false,
        background: UIColor(white: 1, alpha: 0.75))
    
    let loadingView = LoadingView()
    
    // pop up view
    let notificationView = NotificationPopUpView()
    
    private var captureAction: (() -> Void)?
    private var videoAction: ((Bool) -> Void)?
    private var switchCameraAction: (() -> Void)?
    private var switchFlashAction: (() -> Void)?
    private var switchRecordingToPhotoAction: ((Bool) -> Void)?
    
    // camera mode
    enum CaptureMode {
        case photo
        case video(recording: Bool)
    }
    
    private var captureMode: CaptureMode = .photo
        
    var isMicEnabled = true
    var isFlashOn: Bool = false
    
    private var originalBrightness: CGFloat = 0.0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        print("loading camera view")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure (
        captureAction: @escaping () -> Void,
        videoAction: @escaping (Bool) -> Void,
        isFlashOn: Bool,
        switchCameraAction: @escaping () -> Void,
        switchFlashAction: @escaping () -> Void,
        switchRecordingToPhotoAction: @escaping (Bool) -> Void
    ) {
        // actions
        self.isFlashOn = isFlashOn
        self.captureAction = captureAction
        self.videoAction = videoAction
        self.switchCameraAction = switchCameraAction
        self.switchFlashAction = switchFlashAction
        self.switchRecordingToPhotoAction = switchRecordingToPhotoAction
        self.captureButton.addTarget(self, action: #selector(captureButtonAction), for: .touchUpInside)
        self.switchCameraButton.addTarget(self, action: #selector(switchCameraButtonAction), for: .touchUpInside)
        self.switchFlashButton.addTarget(self, action: #selector(switchFlashButtonAction), for: .touchUpInside)
        
        // add tap gesture for photo/video buttons
        addTapGesture(button: self.photoModeButton, action: #selector(photoModeButtonAction))
        addTapGesture(button: self.videoModeButton, action: #selector(videoModeButtonAction))
                
        // setup view
        setupView()
        
        // final calls for visibilities
        switchMode(to: .photo)
    }
    
    func reloadView() {
        captureButton.alpha = 1
        if case .video(_) = captureMode {
            captureMode = .video(recording: false)
        }
        switchMode(to: self.captureMode)
        loadingView.show(false)
    }
    
    func switchMode(to mode: CaptureMode) {
        self.captureMode = mode
        
        // Update UI based on selected mode
        switch mode {
        case .photo:
            photoModeButton.setTitleColor(.white, for: .normal)
            videoModeButton.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
            recordingRedDot.alpha = 0
            
        case .video(let isRecording):
            photoModeButton.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
            videoModeButton.setTitleColor(.white, for: .normal)
            recordingRedDot.alpha = 1
            recordingRedDot.setCornerRadius(isRecording ? 5 : 13)
            switchFlashButton.alpha = isRecording ? 0 : 1
            switchCameraButton.alpha = isRecording ? 0 : 1
            photoModeButton.alpha = isRecording ? 0 : 1
            videoModeButton.alpha = isRecording ? 0 : 1
            
            if !isMicEnabled && !isRecording {
                showNotificationView(with: "Microphone is disabled. Enable in System Settings")
            }
        }
    }
    
    @objc func captureButtonAction() {
        switch captureMode {
        case .photo:
            captureAction?()
        case .video(let recording):
            if recording {
                captureButton.alpha = 0
                recordingRedDot.alpha = 0
                videoAction?(false)
                loadingView.show(true)
            } else {
                switchMode(to: .video(recording: true))
                videoAction?(true)
            }
        }
    }
    
    private func showNotificationView(with text: String) {
        bringSubviewToFront(notificationView)
        notificationView.configure(text: text)
        notificationView.showNotification()
    }
    
    @objc func switchCameraButtonAction() {
        switchCameraAction?()
    }
    
    @objc func switchFlashButtonAction() {
        isFlashOn.toggle()
        switchFlashButton.setImage(UIImage(named: isFlashOn ? "flash_on" : "flash_off"), for: .normal)
        switchFlashAction?()
    }
    
    @objc func photoModeButtonAction() {
        switchMode(to: .photo)
        switchRecordingToPhotoAction?(true)
    }
    
    @objc func videoModeButtonAction() {
        switchMode(to: .video(recording: false))
        switchRecordingToPhotoAction?(false)
    }
    
    func showFrontCameraFlashForVideo(_ show: Bool) {
        
        // hide or show fdlash view
        frontCameraVideoFlash.alpha = show ? 1 : 0
        
        if show {
            // Store the original brightness to restore later
            originalBrightness = UIScreen.main.brightness
            
            // Set screen to maximum brightness
            UIScreen.main.brightness = 1.0
        } else {
            UIScreen.main.brightness = originalBrightness
        }
    }
}

extension CameraView {
    
    func setupView() {
        // Set Constraints for camera objects and filter
        constraintsCameraObjects()
        
        // loading view
        edges(loadingView, top: nil, bottom: nil, left: nil, right: nil)
        loadingView.show(false)
        
        // flash
        edges(frontCameraVideoFlash, top: nil, bottom: nil, left: nil, right: nil)
        frontCameraVideoFlash.alpha = 0
        
        // capture button needs to be in foreground to be clickable
        bringSubviewToFront(recordingRedDot)
        bringSubviewToFront(captureButton)
        
        // notification
        edges(notificationView, top: nil, bottom: nil, left: nil, right: nil)
    }
    
    private func constraintsCameraObjects() {
        
        // Add capture button
        bottomCenterWithSize(
            captureButton,
            bottom: .bottomSafe(self, -30),
            centerX: nil,
            height: 60,
            width: 60)
        
        // recording red dot
        edges(
            recordingRedDot,
            top: .top(captureButton, 17),
            bottom: .bottom(captureButton, -17),
            left: .left(captureButton, 17),
            right: .right(captureButton, -17))
        
        // capture button needs to be in foreground to be clickable
        bringSubviewToFront(captureButton)
        
        unsafeConstraints(
            photoModeButton,
            constraints: [
                Straint(straint: .bottom, anchor: .top(captureButton, -20)),
                Straint(straint: .right, anchor: .centerX(self, -10)),
                Straint(straint: .height, anchor: .length(20))
            ])
        
        unsafeConstraints(
            videoModeButton,
            constraints: [
                Straint(straint: .bottom, anchor: .top(captureButton, -20)),
                Straint(straint: .left, anchor: .centerX(self, 10)),
                Straint(straint: .height, anchor: .length(20))
            ])
        
        // switch camera
        unsafeConstraints(
            switchCameraButton,
            constraints: [
                Straint(straint: .height, anchor: .length(30)),
                Straint(straint: .width, anchor: .length(30)),
                Straint(straint: .right, anchor: .right(self, -30)),
                Straint(straint: .centerY, anchor: .centerY(captureButton, 0))
            ])
        
        // switch flash
        unsafeConstraints(
            switchFlashButton,
            constraints: [
                Straint(straint: .height, anchor: .length(30)),
                Straint(straint: .width, anchor: .length(30)),
                Straint(straint: .left, anchor: .left(self, 30)),
                Straint(straint: .centerY, anchor: .centerY(captureButton, 0))
            ])
    }
}
