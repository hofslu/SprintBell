import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(AudioToolbox)
import AudioToolbox
#endif

#if canImport(AppKit)
import AppKit
#endif

/// Manages audio playback for timer completion sounds
class AudioManager {
    static let shared = AudioManager()
    
    #if canImport(AVFoundation)
    private var audioPlayer: AVAudioPlayer?
    #endif
    
    private init() {}
    
    // MARK: - Public Interface
    
    /// Plays the completion sound when timer reaches zero
    func playCompletionSound() {
        print("🔊 AudioManager.playCompletionSound() called")
        
        #if canImport(AVFoundation) && canImport(AudioToolbox)
        print("🔊 AVFoundation and AudioToolbox available")
        
        // Check if sound is enabled in preferences
        let soundEnabled = TimerDefaults.shared.soundEnabled
        print("🔊 Sound enabled in preferences: \(soundEnabled)")
        
        guard soundEnabled else { 
            print("🔇 Sound disabled in preferences")
            return 
        }
        
        print("🔊 Attempting to play custom sound first...")
        // Try to play custom sound first, fallback to system sound
        if !playCustomCompletionSound() {
            print("🔊 Custom sound failed, trying system fallback...")
            playSystemFallbackSound()
        }
        #else
        print("🔇 Audio frameworks not available on this platform")
        #endif
    }
    
    // MARK: - Private Methods
    
    #if canImport(AVFoundation)
    /// Attempts to play custom completion sound from bundle
    private func playCustomCompletionSound() -> Bool {
        // Look for alarm sound file in bundle
        guard let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") else {
            print("🔊 Custom sound file not found, using system fallback")
            return false
        }
        
        do {
            // Create and configure audio player (AVAudioSession is iOS-only)
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
            
            print("🔔 Playing custom completion sound")
            return true
            
        } catch {
            print("❌ Failed to play custom sound: \(error.localizedDescription)")
            return false
        }
    }
    #else
    private func playCustomCompletionSound() -> Bool {
        return false
    }
    #endif
    
    #if canImport(AudioToolbox)
    /// Plays system fallback sound when custom sound fails
    private func playSystemFallbackSound() {
        print("🔊 Attempting to play system fallback sound...")
        
        // Try NSBeep first (most reliable)
        #if canImport(AppKit)
        NSSound.beep()
        print("🔔 Played NSSound.beep()")
        #endif
        
        // Also try system sound for good measure
        AudioServicesPlaySystemSound(1013) // Text message sound
        print("🔔 Played AudioServicesPlaySystemSound(1013)")
        
        // Alternative: Use afplay with system sound file
        let process = Process()
        process.launchPath = "/usr/bin/afplay"
        process.arguments = ["/System/Library/Sounds/Glass.aiff"]
        
        do {
            try process.run()
            print("🔔 Played Glass.aiff via afplay")
        } catch {
            print("❌ Failed to play via afplay: \(error)")
        }
        
        print("🔔 System fallback sound sequence completed")
    }
    #else
    private func playSystemFallbackSound() {
        print("🔔 System sound not available on this platform")
    }
    #endif
}