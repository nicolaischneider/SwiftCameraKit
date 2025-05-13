import UIKit
import AVFoundation
import os

extension SwiftCameraKit {
    
    /// Sets up video playback in a specified view.
    ///
    /// This method configures and starts playback of a recorded video in the provided view.
    /// It automatically configures looping playback, so the video will repeat continuously.
    ///
    /// - Parameters:
    ///   - playerView: The UIView where the video will be displayed.
    ///   - videoURL: The URL of the video file to play.
    ///
    /// - Note: If there was already video playback configured in the provided view,
    ///         it will be stopped and replaced with the new video.
    ///
    /// - Important: The video gravity (aspect ratio handling) is based on the configured
    ///              `videoGravity` setting in `SwiftCameraKitConfig.VideoSettings`.
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
        
        LogManager.swiftCameraKit.addLog("Video playback setup complete.")
    }
    
    /// Resumes playback of a previously setup video.
    ///
    /// This method resumes playback if it was paused. It is automatically called
    /// when the app returns to the foreground.
    ///
    /// - Note: This method has no effect if no video player is currently set up.
    @objc public func restartVideo() {
        LogManager.swiftCameraKit.addLog("Restarting video playback.")
        if let videoPlayer = videoPlayer {
            videoPlayer.play()
        }
    }
    
    /// Pauses the currently playing video.
    ///
    /// This method pauses the video playback. It is automatically called
    /// when the app enters the background.
    ///
    /// - Note: This method has no effect if no video player is currently set up
    ///         or if the video is already paused.
    @objc public func pauseVideo() {
        LogManager.swiftCameraKit.addLog("Pausing video playback.")
        videoPlayer?.pause()
    }
    
    func cleanupVideoPlayback() {
        LogManager.swiftCameraKit.addLog("Cleanup video playback.")
        
        // Stop playback
        videoPlayer?.pause()
        
        // Remove notification observer
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer?.currentItem)
        
        // Clear reference
        videoPlayer = nil
    }
}
