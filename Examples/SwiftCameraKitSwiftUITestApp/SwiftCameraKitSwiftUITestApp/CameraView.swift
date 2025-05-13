import SwiftUI
import SwiftCameraKit
import Combine

final class BasicCameraViewController: UIViewController {
    private var cameraKit: SwiftCameraKit?
    private var cancellables = Set<AnyCancellable>()
    
    private let captureButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        button.setImage(UIImage(named: "capture_icon"), for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        return button
    }()
    
    private let previewImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.isHidden = true
        return imageView
    }()
    
    private let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    var onImageCaptured: ((UIImage) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupCamera()
    }
    
    private func setupUI() {
        // Add all views
        view.addSubview(previewImageView)
        view.addSubview(captureButton)
        view.addSubview(dismissButton)
        
        // Setup constraints
        previewImageView.translatesAutoresizingMaskIntoConstraints = false
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        dismissButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            previewImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            previewImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            previewImageView.topAnchor.constraint(equalTo: view.topAnchor),
            previewImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30),
            captureButton.widthAnchor.constraint(equalToConstant: 60),
            captureButton.heightAnchor.constraint(equalToConstant: 60),
            
            dismissButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            dismissButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
        ])
        
        captureButton.addTarget(self, action: #selector(captureButtonTapped), for: .touchUpInside)
        dismissButton.addTarget(self, action: #selector(dismissButtonTapped), for: .touchUpInside)
    }
    
    private func setupCamera() {
        cameraKit = SwiftCameraKit(view: view)

        Task {
            switch await cameraKit?.grantAccessForCameraAndAudio() {
            case .success:
                await MainActor.run {
                    cameraKit?.setupSessionAndCamera()
                    
                    // Setup state observation
                    cameraKit?.$state
                        .receive(on: DispatchQueue.main)
                        .sink { [weak self] state in
                            if case .photoOutput(let image) = state {
                                self?.handleCapturedImage(image)
                            }
                        }
                        .store(in: &cancellables)
                }
            default:
                print("Camera access failed")
            }
        }
    }
    
    private func handleCapturedImage(_ image: UIImage) {
        previewImageView.image = image
        previewImageView.isHidden = false
        captureButton.isHidden = true
        dismissButton.isHidden = false
    }
    
    @objc private func captureButtonTapped() {
        cameraKit?.capturePhoto()
    }
    
    @objc private func dismissButtonTapped() {
        if let image = previewImageView.image {
            onImageCaptured?(image)
        }
    }
    
    @objc private func retakeButtonTapped() {
        previewImageView.isHidden = true
        captureButton.isHidden = false
        dismissButton.isHidden = true
        previewImageView.image = nil
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

struct CameraView: View {
    @State private var showCamera = false
    
    var body: some View {
        VStack {
            Button("Take Photo") {
                showCamera = true
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            BasicCameraViewControllerRepresentable()
                .ignoresSafeArea()
                .interactiveDismissDisabled()
        }
    }
}

struct BasicCameraViewControllerRepresentable: UIViewControllerRepresentable {
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> BasicCameraViewController {
        let vc = BasicCameraViewController()
        vc.onImageCaptured = { [presentationMode] image in
            presentationMode.wrappedValue.dismiss()
        }
        return vc
    }
    
    func updateUIViewController(_ uiViewController: BasicCameraViewController, context: Context) {}
}
