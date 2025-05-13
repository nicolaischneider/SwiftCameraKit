import SwiftUI
import SwiftCameraKit
import Combine

struct ContentView: View {
    @State private var showCamera = false
    @State private var capturedImage: UIImage?
    @State private var cameraViewController: BasicCameraViewController?
    
    var body: some View {
        VStack {
            Button("Take Photo") {
                showCamera = true
            }
            .padding()
        }
        .sheet(isPresented: $showCamera) {
            ZStack {
                // Camera view in the background
                BasicCameraViewControllerRepresentable(
                    cameraVC: $cameraViewController,
                    capturedImage: $capturedImage
                )
                .ignoresSafeArea()
                
                // Preview image overlay
                if let image = capturedImage {
                    Color.black.ignoresSafeArea()
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .ignoresSafeArea()
                }
                
                // SwiftUI controls overlay
                VStack {
                    HStack {
                        if capturedImage != nil {
                            Spacer()
                            
                            Button("Done") {
                                showCamera = false
                            }
                            .foregroundColor(.white)
                            .padding()
                        }
                    }
                    
                    Spacer()
                    
                    if capturedImage == nil {
                        // Capture button
                        Button(action: {
                            cameraViewController?.capturePhoto()
                        }) {
                            Circle()
                                .fill(.white)
                                .frame(width: 60, height: 60)
                                .overlay(
                                    Circle()
                                        .stroke(.gray, lineWidth: 2)
                                )
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
            .interactiveDismissDisabled()
        }
    }
}
