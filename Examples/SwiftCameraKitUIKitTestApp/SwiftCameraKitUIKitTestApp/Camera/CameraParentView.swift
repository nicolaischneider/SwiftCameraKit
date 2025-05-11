//
//  CameraParentView.swift
//  SwiftCameraKitUIKitTestApp
//
//  Created by knc on 11.05.25.
//

import UIKit
import SwiftCameraKit
import Combine
import SimpleConstraints

enum CameraHubViewType {
    case camera
    case error
    case review(UIImage)
    case reviewVideo(URL)
}

class CameraHubView: UIViewController {
    
    private var cancellables = Set<AnyCancellable>()
    
    var cameraController: SwiftCameraKit? {
        didSet {
            // Configure camera when it's set
            setupCameraIfNeeded()
        }
    }
    // camera view
    let cameraView = CameraView()
    
    // error view
    let errorView = ErrorView()
    
    // review view
    let reviewView = MediaReviewView()
    
    // quit button
    private let headerView = UIView.view(corner: nil, shadow: false, background: .white)
    let quitButton = UIButton.viewWithImage(
        image: UIImage(systemName: "xmark.circle.fill"),
        tintColor: .black,
        cornerRadius: nil,
        shadow: false,
        function: nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        print("loading camera hub")
        
        setupViews()
        displayView()
        
        // If camera controller is already set, configure it
        setupCameraIfNeeded()
    }
    
    func showView (viewType: CameraHubViewType) {
        
        guard let cameraController else {
            print("controller is nil")
            return
        }
        
        print("showing \(viewType)")
        
        switch viewType {
        case .camera:
            self.cameraView.isHidden = false
            self.errorView.isHidden = true
            self.reviewView.isHidden = true
            self.cameraView.reloadView()
            
        case .error:
            self.cameraView.isHidden = true
            self.errorView.isHidden = false
            self.reviewView.isHidden = true
            
        case .review(let image):
            reviewView.configure(
                image: image,
                dismissView: {
                    self.dismiss(animated: true)
                })
            self.cameraView.isHidden = true
            self.errorView.isHidden = true
            self.reviewView.isHidden = false
            
        case .reviewVideo(let url):
            reviewView.configure(
                loadVideo: { videoView in
                    cameraController.setupVideoPlayback(in: videoView, videoURL: url)
                },
                dismissView: {
                    self.dismiss(animated: true)
                })
            self.cameraView.isHidden = true
            self.errorView.isHidden = true
            self.reviewView.isHidden = false
        }
    }
    
    private func setupCameraIfNeeded() {
        guard let cameraController = cameraController,
              isViewLoaded // Make sure view is loaded
        else {
            print("Either controller is nil or view isn't loaded yet")
            return
        }
        
        setupViews()
        
        Task {
            switch await cameraController.grantAccessForCameraAndAudio() {
            case .success:
                self.cameraController?.setupSessionAndCamera()
                showView(viewType: .camera) // Show camera view when ready
                
            case .microphoneNotAuthorized:
                self.cameraController?.setupSessionAndCamera()
                self.cameraView.isMicEnabled = false
                showView(viewType: .camera)

            case .cameraNotAuthorized, .cameraAndMicrophoneNotAuthorized:
                showView(viewType: .error)
            }
        }
        
        cameraController.$state
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                guard let self = self else { return }
                switch state {
                case .error:
                    self.showView(viewType: .error)
                case .photoOutput(let image):
                    self.showView(viewType: .review(image))
                case .videoOutput(let url):
                    self.showView(viewType: .reviewVideo(url))
                default:
                    break
                }
            }
            .store(in: &cancellables)
    }
    
    private func setupViews() {
        
        guard let cameraController else {
            print("controller is nil")
            return
        }
        
        // quit button
        quitButton.addTarget(self, action: #selector(dismissVC), for: .touchUpInside)

        // camera view
        cameraView.configure(
            captureAction: cameraController.capturePhoto,
            videoAction: { isRecording in
                if isRecording {
                    cameraController.startVideoRecording()
                } else {
                    cameraController.stopVideoRecording()
                }
            },
            isFlashOn: cameraController.shouldUseFlash,
            switchCameraAction: cameraController.switchCamera,
            switchFlashAction: cameraController.switchFlash,
            switchRecordingToPhotoAction: { toPhoto in
                cameraController.switchCaptureMode(toPhoto: toPhoto)
            })
        
        // error view
        errorView.configure(with: "Camera was never enabled")
    }
    
    private func displayView() {
        
        // quit button
        view.edgesAndHeight(headerView, top: nil, left: nil, right: nil, height: 40)
        headerView.edgesAndSize(quitButton,
                          top: .top(headerView, 5),
                          right: .right(headerView, -5),
                          height: 30,
                          width: 30)
        
        // camera view
        view.edges(cameraView, top: .bottom(headerView, 0), bottom: nil, left: nil, right: nil)
        
        // error view
        view.edges(errorView, top: .bottom(headerView, 0), bottom: nil, left: nil, right: nil)
        
        // review view
        view.edges(reviewView, top: .bottom(headerView, 0), bottom: nil, left: nil, right: nil)
        
        showView(viewType: .camera)
    }
    
    @objc func dismissVC () {
        cameraController?.reset()
        cameraController = nil
        dismiss(animated: true)
    }
}
