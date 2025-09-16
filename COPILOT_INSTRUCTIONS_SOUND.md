# 🔊 Feature: Completion Sound & Alert System

## 🎯 GitHub Copilot Implementation Guide

This branch implements audio feedback when timer sessions complete with customizable sound options.

## 📋 Implementation Tasks

### 1. Create AudioManager Class
**File**: `src/Audio/AudioManager.swift`

```swift
import AVFoundation
import os.log

class AudioManager {
    static let shared = AudioManager()
    
    private var audioPlayer: AVAudioPlayer?
    private let logger = Logger(subsystem: "com.sprintbell.app", category: "AudioManager")
    
    private init() {}
    
    // MARK: - Public Interface
    func playCompletionSound() {
        // Implementation needed
    }
    
    // MARK: - Private Methods
    private func setupAudioPlayer() {
        // Load sound file from bundle
        // Configure AVAudioPlayer
        // Handle audio session setup
    }
    
    private func playSystemFallbackSound() {
        // Fallback to system sound (AudioServicesPlaySystemSound)
        // Use SystemSoundID 1304 (Glass sound) or similar
    }
}
```

### 2. Add Sound Files to Bundle
**Directory**: `src/Audio/`

- Add completion sound file (e.g., `completion-bell.mp3`, `completion-chime.wav`)
- Ensure files are added to Xcode target/Package.swift resources
- Keep files small (<100KB) for app bundle size

### 3. Integrate with TimerManager
**File**: `src/TimerManager.swift`

In the `timerCompleted()` method, add:
```swift
private func timerCompleted() {
    // Log completed session
    if let startTime = sessionStartTime {
        logSession(startTime: startTime, wasCompleted: true, wasInterrupted: false)
    }
    
    // Play completion sound
    if persistence.soundEnabled {
        AudioManager.shared.playCompletionSound()
    }
    
    stopTimer()
    // ... rest of existing code
}
```

### 4. Add Sound Preferences
**File**: `src/Models/TimerDefaults.swift`

Add sound-related preferences:
```swift
// Add to existing TimerDefaults class
var soundEnabled: Bool {
    get { userDefaults.bool(forKey: Keys.soundEnabled.rawValue) }
    set { userDefaults.set(newValue, forKey: Keys.soundEnabled.rawValue) }
}

var selectedSoundName: String {
    get { userDefaults.string(forKey: Keys.selectedSoundName.rawValue) ?? "completion-bell" }
    set { userDefaults.set(newValue, forKey: Keys.selectedSoundName.rawValue) }
}

// Add to Keys enum
case soundEnabled = "sound_enabled"
case selectedSoundName = "selected_sound_name"
```

### 5. Add Sound Settings UI (Optional for MVP)
**File**: `src/Views/SprintPopoverView.swift`

Add sound toggle in the popover (near theme toggle):
```swift
// In header section, add sound toggle
HStack {
    Button(action: { timerManager.setSoundEnabled(!timerManager.getSoundEnabled()) }) {
        Image(systemName: timerManager.getSoundEnabled() ? "speaker.wave.2" : "speaker.slash")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(currentColorScheme == .dark ? .blue : .blue)
    }
    .help("Sound: \(timerManager.getSoundEnabled() ? "On" : "Off")")
    
    Spacer()
    
    Button(action: { themeManager.toggleTheme() }) {
        // ... existing theme toggle code
    }
}
```

## 🧪 Testing Checklist

### Audio Functionality
- [ ] Sound plays when timer reaches zero
- [ ] Fallback to system sound if file loading fails  
- [ ] Sound respects system volume settings
- [ ] Works with system mute enabled/disabled
- [ ] No audio interruption of other apps
- [ ] Sound preference persists between app launches

### Integration Testing
- [ ] TimerManager calls AudioManager correctly
- [ ] Sound only plays when enabled in preferences
- [ ] UI toggle updates preference correctly
- [ ] No crashes if audio file missing
- [ ] Graceful handling of audio permissions

### Edge Cases
- [ ] Works when headphones connected/disconnected
- [ ] Handles system audio interruptions
- [ ] Works in Do Not Disturb mode (respects system settings)
- [ ] Performance impact minimal (no audio lag)

## 🔧 Technical Requirements

### Dependencies
- `AVFoundation` framework for audio playback
- `AudioToolbox` framework for system sound fallback
- Existing `TimerDefaults` for preferences

### Audio Session Configuration
```swift
// Configure audio session to not interrupt other apps
try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
try AVAudioSession.sharedInstance().setActive(true)
```

### Sound File Requirements
- Format: MP3 or WAV
- Duration: 1-3 seconds
- Size: <100KB
- Sample rate: 44.1kHz recommended
- Quality: Good balance between quality and size

## 🎵 Suggested Sounds

1. **Bell Chime** - Classic, professional
2. **Glass Ding** - System-like, familiar  
3. **Soft Chime** - Gentle, non-intrusive
4. **Success Bell** - Positive reinforcement tone

## 📦 Expected Deliverables

1. **AudioManager.swift** - Complete audio management class
2. **Sound files** - At least one completion sound in bundle
3. **TimerManager integration** - Sound plays on completion
4. **Preferences support** - Enable/disable functionality
5. **UI toggle** - Quick access to sound settings
6. **Error handling** - Graceful fallbacks and error recovery

## 🔗 Integration Points

### With Existing Code
- `TimerManager.timerCompleted()` - Trigger sound playback
- `TimerDefaults` - Sound preferences storage  
- `SprintPopoverView` - Sound settings UI

### With Future Features
- System Notifications - Coordinate sound with notification
- Advanced Preferences - Multiple sound options
- User Customization - Import custom sounds

## 🚀 Success Criteria

✅ **Primary Goal**: Timer completion plays audio feedback
✅ **User Control**: Can enable/disable sound via UI
✅ **Reliability**: Works consistently across different audio states
✅ **Performance**: No noticeable impact on timer functionality
✅ **User Experience**: Enhances completion satisfaction without being intrusive

---

**Ready for Copilot implementation!** This feature completes the audio feedback component of Sprint 3.