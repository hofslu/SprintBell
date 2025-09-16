import Foundation

#if canImport(AVFoundation)
import AVFoundation
#endif

#if canImport(AudioToolbox)
import AudioToolbox
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
        #if canImport(AVFoundation) && canImport(AudioToolbox)
        // Check if sound is enabled in preferences
        guard TimerDefaults.shared.soundEnabled else { 
            print("🔇 Sound disabled in preferences")
            return 
        }
        
        // Try to play custom sound first, fallback to system sound
        if !playCustomCompletionSound() {
            playSystemFallbackSound()
        }
        #else
        print("🔇 Audio playback not available on this platform")
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
            // Configure audio session to not interrupt other apps
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            // Create and configure audio player
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
        // Use System Sound ID 1304 (Glass sound) as fallback
        AudioServicesPlaySystemSound(1304)
        print("🔔 Playing system fallback sound (Glass)")
    }
    #else
    private func playSystemFallbackSound() {
        print("🔔 System sound not available on this platform")
    }
    #endif
}