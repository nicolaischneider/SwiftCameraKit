//
//  ContentView.swift
//  SwiftCameraKitTestApp
//
//  Created by knc on 09.05.25.
//

import SwiftUI
import SwiftCameraKit

// ViewModel to manage camera state and controller
class CameraViewModel: ObservableObject {
    @Published var cameraOutput: CameraOutput?
    var controller: SwiftCameraKit?
    
    init() {
        // Initialize with nil controller - will be set when view is created
    }
    
    func setController(_ controller: SwiftCameraKit) {
        self.controller = controller
        // Set up state observation
        observeControllerState()
    }
    
    private func observeControllerState() {
        guard let controller = controller else { return }
        
        // Use Combine to observe the controller's state
        controller.$state
            .receive(on: DispatchQueue.main)
            .assign(to: &$cameraOutput)
    }
    
    // Camera control functions
    func capturePhoto() {
        controller?.capturePhoto()
    }
    
    // Add other controller functions as needed
}

class ShareHubView: UIViewController {
    // Reference to the camera controller
    var controller: SwiftCameraKit?
    
    // Main view that will hold the camera preview
    private lazy var cameraView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCameraView()
    }
    
    private func setupCameraView() {
        view.addSubview(cameraView)
        NSLayoutConstraint.activate([
            cameraView.topAnchor.constraint(equalTo: view.topAnchor),
            cameraView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            cameraView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            cameraView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

// UIViewControllerRepresentable with ViewModel
struct ShareHubViewRepresentable: UIViewControllerRepresentable {
    @ObservedObject var viewModel: CameraViewModel
    
    func makeUIViewController(context: Context) -> ShareHubView {
        let shareHubView = ShareHubView()
        let cameraKit = SwiftCameraKit(view: shareHubView.view)
        shareHubView.controller = cameraKit
        
        // Set the controller in the ViewModel
        viewModel.setController(cameraKit)
        
        // Initialize camera and audio
        Task {
            switch await shareHubView.controller?.grantAccessForCameraAndAudio() {
            case .success:
                shareHubView.controller?.setupSessionAndCamera()
            default:
                print("nothing to do")
            }
        }
        
        return shareHubView
    }
    
    func updateUIViewController(_ uiViewController: ShareHubView, context: Context) {
        // Updates can be handled here if needed
    }
}

// Main SwiftUI view
struct ContentView: View {
    @StateObject private var cameraViewModel = CameraViewModel()
    @State private var isShowingCamera = false
    
    var body: some View {
        VStack {
            Button("Open Camera") {
                isShowingCamera = true
            }
            
            // Example of observing camera output
            if case .photoOutput(let image) = cameraViewModel.cameraOutput {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 200)
            }
        }
        .sheet(isPresented: $isShowingCamera) {
            ShareHubViewRepresentable(viewModel: cameraViewModel)
                .edgesIgnoringSafeArea(.all)
        }
    }
}

// Example usage in another view
struct CameraControlsView: View {
    @ObservedObject var cameraViewModel: CameraViewModel
    
    var body: some View {
        HStack {
            Button("Take Photo") {
                cameraViewModel.capturePhoto()
            }
        }
    }
}
