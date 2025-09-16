# Sprint 3: Data Persistence & Notifications

**Duration**: 2 coding sessions  
**Goal**: Save session data, play completion sounds, and show system notifications

## 🎯 Sprint Objectives

### Primary Goals

- [x] Implement UserDefaults for app state persistence
- [x] Create JSONL session logging system
- [x] Add completion sound/alarm functionality
- [x] Implement system notifications for session end
- [x] Request notification permissions on first launch
- [x] Restore previous session state on app launch

### Success Criteria

- ✅ App remembers title, goals, and timer state between launches
- ✅ Completed sessions logged to JSONL file
- ✅ Sound plays when timer reaches zero
- ✅ System notification appears on completion
- ✅ Smooth user experience with proper permissions

## 📋 Detailed Tasks

### 1. UserDefaults Persistence

- Save current timer state (remaining seconds, is running)
- Save main title and sub-goals
- Save user preferences (default duration, sound enabled)
- Auto-save on state changes
- Restore state on app launch

### 2. JSONL Session Logging

- Create log directory: `~/Library/Application Support/SprintBell/`
- Log format: one JSON object per line in `log.jsonl`
- Include: start time, end time, title, goals, duration, completion status
- Write log entry when session completes
- Handle file I/O errors gracefully

### 3. Completion Sound System

- Add alarm sound file to app bundle (`alarm.mp3`)
- Fallback to system sound (SystemSoundID 1304)
- Play sound when timer reaches zero
- User preference to enable/disable sound
- Test sound functionality

### 4. System Notifications

- Request notification permissions on first launch
- Create notification when timer completes
- Include session title and goals summary in notification
- Handle notification permissions gracefully
- Test on different macOS versions

### 5. Session State Management

- Track session lifecycle (created, started, paused, completed)
- Calculate actual work time vs. planned time
- Handle edge cases (app quit during timer, system sleep)
- Persistent session IDs for logging

## 🛠 Technical Implementation Notes

### Key Files to Create/Modify

```
SprintBell/
├── Storage/
│   ├── PersistenceManager.swift    # UserDefaults wrapper
│   ├── SessionLogger.swift         # JSONL logging
│   └── NotificationManager.swift   # System notifications
├── Audio/
│   └── alarm.mp3                  # Completion sound
├── Models/
│   ├── SprintSession.swift        # Enhanced session model
│   └── SessionState.swift         # Session state enum
└── TimerManager.swift             # Modified with persistence
```

### Core Classes

**PersistenceManager**

```swift
class PersistenceManager {
    private let userDefaults = UserDefaults.standard

    func saveTimerState(_ state: TimerState) { /* ... */ }
    func loadTimerState() -> TimerState? { /* ... */ }
    func saveSubGoals(_ goals: [SubGoal]) { /* ... */ }
    func loadSubGoals() -> [SubGoal] { /* ... */ }
    func saveUserPreferences(_ prefs: UserPreferences) { /* ... */ }
}
```

**SessionLogger**

```swift
class SessionLogger {
    private let logFileURL: URL

    init() {
        // Create ~/Library/Application Support/SprintBell/ if needed
        let supportDir = FileManager.default.urls(for: .applicationSupportDirectory,
                                                 in: .userDomainMask)[0]
        let sprintBellDir = supportDir.appendingPathComponent("SprintBell")
        try? FileManager.default.createDirectory(at: sprintBellDir, withIntermediateDirectories: true)
        logFileURL = sprintBellDir.appendingPathComponent("log.jsonl")
    }

    func logSession(_ session: CompletedSession) throws { /* ... */ }
}
```

**NotificationManager**

```swift
class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    func requestPermissions() async -> Bool { /* ... */ }
    func scheduleSessionCompleteNotification(title: String, goals: [SubGoal]) { /* ... */ }
    func playCompletionSound() { /* ... */ }
}
```

### JSONL Log Format

```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "ts_start": "2025-09-16T09:00:00+02:00",
  "ts_end": "2025-09-16T09:50:00+02:00",
  "title": "RAG retriever implementation",
  "goals": [
    { "text": "write tests", "completed": true },
    { "text": "benchmark HNSW", "completed": false }
  ],
  "planned_duration_sec": 3000,
  "actual_duration_sec": 2987,
  "result": "Complete"
}
```

### UserDefaults Keys

```swift
enum UserDefaultsKeys {
    static let currentTitle = "sprintbell.current.title"
    static let currentSubGoals = "sprintbell.current.subgoals"
    static let remainingSeconds = "sprintbell.current.remaining"
    static let isRunning = "sprintbell.current.running"
    static let sessionStartTime = "sprintbell.current.start_time"
    static let soundEnabled = "sprintbell.preferences.sound"
    static let defaultDuration = "sprintbell.preferences.default_duration"
}
```

## 🔊 Audio Implementation

### Sound Options

1. **Custom alarm sound**: Bundle `alarm.mp3` with app
2. **System sound fallback**: Use `SystemSoundID` 1304 (glass sound)
3. **User preference**: Allow enable/disable in future preferences

### Audio Code Example

```swift
import AVFoundation

class AudioManager {
    private var audioPlayer: AVAudioPlayer?

    func playCompletionSound() {
        guard UserDefaults.standard.bool(forKey: "soundEnabled") else { return }

        if let soundURL = Bundle.main.url(forResource: "alarm", withExtension: "mp3") {
            try? audioPlayer = AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.play()
        } else {
            // Fallback to system sound
            AudioServicesPlaySystemSound(1304)
        }
    }
}
```

## 📱 Notification Implementation

### Permission Handling

- Request permissions on first app launch
- Gracefully handle denied permissions
- Show helpful message if notifications disabled
- Don't block app functionality if denied

### Notification Content

```swift
let content = UNMutableNotificationContent()
content.title = timerManager.mainTitle
content.body = "Sprint completed! Goals: \(completedGoalsCount)/\(totalGoals)"
content.sound = .default
```

## 🧪 Testing Checklist

- [ ] App state persists between quit/relaunch
- [ ] Session logs correctly written to JSONL
- [ ] Completion sound plays when timer ends
- [ ] System notification appears on completion
- [ ] Notification permissions requested appropriately
- [ ] Handles file system errors gracefully
- [ ] UserDefaults doesn't grow unbounded
- [ ] Audio works with system volume/mute settings
- [ ] Notifications respect system Do Not Disturb
- [ ] Log file location is accessible to user

## 🎁 Sprint Deliverables

At the end of Sprint 3, you should have:

1. **Persistent app state** - remembers everything between launches
2. **Session history logging** - complete JSONL audit trail
3. **Professional completion experience** - sound + notification
4. **Robust data handling** - proper error handling and permissions
5. **User-friendly persistence** - no data loss, smooth experience

## 🔄 Transition to Sprint 4

Sprint 3 completes the standalone app functionality. Sprint 4 will begin external integrations:

- VSCode task integration
- URL scheme registration
- Basic automation capabilities
- Foundation for HTTP API

The persistence and logging systems from Sprint 3 will be essential for tracking sessions initiated via external tools!
