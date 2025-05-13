import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
    
    public func setupVideoPlayback(in playerView: UIView, videoURL: URL) {
        // Create AVPlayer
        let player = AVPlayer(url: videoURL)
        
        // Create AVPlayerLayer
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = playerView.bounds
        playerLayer.videoGravity = configs.videoSettings.videoGravity
        
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
    
    @objc public func restartVideo() {
        if let videoPlayer = videoPlayer {
            videoPlayer.play()
        }
    }
    
    @objc public func pauseVideo() {
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
