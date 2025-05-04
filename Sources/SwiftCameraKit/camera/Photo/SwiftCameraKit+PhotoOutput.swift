//
//  InstagramStory+CapturedPhoto.swift
//  100Questions
//
//  Created by knc on 20.12.23.
//  Copyright © 2023 Schneider & co. All rights reserved.
//

import UIKit
import AVFoundation
import os

extension SwiftCameraKit: AVCapturePhotoCaptureDelegate {
    
    // This method gets called once the photo is captured
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard error == nil else {
            LogManager.swiftCameraKit.addLog("Error in capturing photo: \(error?.localizedDescription ?? "error localization failed")")
            // self.callErrorView()
            return
        }

        // Retrieve the image data
        guard let imageData = photo.fileDataRepresentation() else {
            LogManager.swiftCameraKit.addLog("Could not retrieve the image data")
            // self.callErrorView()
            return
        }

        // Create an UIImage from the data
        guard let capturedImage = UIImage(data: imageData) else {
            LogManager.swiftCameraKit.addLog("Could not create an image from the data")
            // self.callErrorView()
            return
        }

        DispatchQueue.main.async {
            self.stopCaptureSession()
            self.finalPhoto = capturedImage
            // update view
            // self.view.showView(viewType: .review(editedImage))
        }
    }
}
