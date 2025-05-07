//
//  InstagramStoryController+VideoOutput.swift
//  100Questions
//
//  Created by knc on 04.04.25.
//  Copyright © 2025 Schneider & co. All rights reserved.
//

import UIKit
import AVFoundation
import os

// MARK: - AVCaptureFileOutputRecordingDelegate
extension SwiftCameraKit: AVCaptureFileOutputRecordingDelegate {
    
    public func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        // Handle recording started
        DispatchQueue.main.async {
            LogManager.swiftCameraKit.addLog("Video recording started")
        }
    }
    
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {        
        if let error = error {
            LogManager.swiftCameraKit.addLog("Error recording video: \(error.localizedDescription)")
            DispatchQueue.main.async {
                self.state = .error(.videoOutputFailed)
            }
            return
        }
        
        // Process recorded video
        processRecordedVideo(videoURL: outputFileURL)
    }
    
    private func processRecordedVideo(videoURL: URL) {
        // Store original URL
        self.state = .videoOutput(videoURL)
        
        DispatchQueue.main.async {
            self.stopCaptureSession()
        }
    }
    
    func setupVideoPlayback(in playerView: UIView, videoURL: URL) {        
        // Create AVPlayer
        let player = AVPlayer(url: videoURL)
        
        // Create AVPlayerLayer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        
        // Remove any existing player layers
        playerView.layer.sublayers?.forEach { layer in
            if layer is AVPlayerLayer {
                layer.removeFromSuperlayer()
            }
        }
        
        // Add player layer to view
        playerView.layer.addSublayer(playerLayer)
        
        // Set up looping
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        NotificationCenter.default.addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                                               object: player.currentItem,
                                               queue: .main) { _ in
            // When video ends, seek back to beginning and play again
            player.seek(to: CMTime.zero)
            player.play()
        }
        
        // Start playback
        player.play()
        
        // Store player reference if needed for later
        self.videoPlayer = player
    }
    
    @objc func restartVideo() {
        if let videoPlayer = videoPlayer {
            videoPlayer.play()
        }
    }
    
    @objc func pauseVideo() {
        videoPlayer?.pause()
    }
    
    func cleanupVideoPlayback() {
        // Stop playback
        videoPlayer?.pause()
        
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
        
        // Clear reference
        videoPlayer = nil
    }
}
