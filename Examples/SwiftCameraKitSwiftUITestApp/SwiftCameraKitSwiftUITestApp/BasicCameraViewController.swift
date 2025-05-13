import Foundation
import SwiftUI
import SwiftCameraKit
import Combine

// Pure camera controller - only handles camera functionality
final class BasicCameraViewController: UIViewController {
    private var cameraKit: SwiftCameraKit?
    private var cancellables = Set<AnyCancellable>()
    var onImageCaptured: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupCamera()
    }
    
    private func setupCamera() {
        cameraKit = SwiftCameraKit(view: view)

        Task {
            switch await cameraKit?.grantAccessForCameraAndAudio() {
            case .success:
                await MainActor.run {
                    cameraKit?.setupSessionAndCamera()
                    
                    cameraKit?.$state
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] state in
                            if case .photoOutput(let image) = state {
                                self?.onImageCaptured?(image)
                            }
                        }
                        .store(in: &cancellables)
                }
            default:
                print("Camera access failed")
            }
        }
    }
    
    func capturePhoto() {
        cameraKit?.capturePhoto()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard let kit = cameraKit else { return }
        kit.stopCaptureSession()
        kit.reset()
        cameraKit = nil
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        cancellables.removeAll()
    }
    
    deinit {
        guard let kit = cameraKit else { return }
        kit.stopCaptureSession()
        kit.reset()
        cameraKit = nil
    }
}

struct BasicCameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Binding var cameraVC: BasicCameraViewController?
    @Binding var capturedImage: UIImage?
    
    func makeUIViewController(context: Context) -> BasicCameraViewController {
        let vc = BasicCameraViewController()
        vc.onImageCaptured = { image in
            self.capturedImage = image
        }
        cameraVC = vc
        return vc
    }
    
    func updateUIViewController(_ uiViewController: BasicCameraViewController, context: Context) {}
}
