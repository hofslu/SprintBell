# 📱 Feature: System Notifications & Permissions

## 🎯 GitHub Copilot Implementation Guide

This branch implements macOS system notifications for timer completion with proper permission handling.

## 📋 Implementation Tasks

### 1. Create NotificationManager Class
**File**: `src/Notifications/NotificationManager.swift`

```swift
import UserNotifications
import os.log

class NotificationManager {
    static let shared = NotificationManager()
    
    private let logger = Logger(subsystem: "com.sprintbell.app", category: "NotificationManager")
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        setupNotificationDelegate()
    }
    
    // MARK: - Public Interface
    
    /// Request notification permissions on first launch
    func requestPermissions() async -> Bool {
        // Implementation needed
        // Request authorization for alerts, sounds, badges
        // Handle user response gracefully
    }
    
    /// Send notification when timer completes
    func sendCompletionNotification(
        sessionTitle: String,
        actualDuration: Int,
        completedGoals: Int,
        totalGoals: Int
    ) {
        // Implementation needed
        // Create rich notification content
        // Include session summary
        // Add notification actions
    }
    
    /// Check if notifications are enabled
    func areNotificationsEnabled() async -> Bool {
        // Implementation needed
        // Check current notification settings
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationDelegate() {
        // Set delegate for handling notification responses
    }
    
    private func createNotificationContent(
        title: String,
        body: String,
        sessionData: SessionSummary
    ) -> UNMutableNotificationContent {
        // Implementation needed
        // Rich notification with session details
        // Add actions for quick workflow continuation
    }
}

// MARK: - Supporting Types

struct SessionSummary {
    let title: String
    let actualDuration: Int
    let plannedDuration: Int
    let completedGoals: Int
    let totalGoals: Int
    let completionRate: Double
}
```

### 2. Add Notification Delegate
**File**: `src/Notifications/NotificationDelegate.swift`

```swift
import UserNotifications

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is active
        completionHandler([.banner, .sound, .badge])
    }
    
    // Handle user interaction with notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        // Handle notification actions
        // - Start new session
        // - View session stats
        // - Open app
        completionHandler()
    }
}
```

### 3. Integrate with App Lifecycle
**File**: `src/SprintBellApp.swift`

```swift
// Add to AppDelegate.applicationDidFinishLaunching
func applicationDidFinishLaunching(_ notification: Notification) {
    // ... existing code ...
    
    // Request notification permissions on first launch
    if persistence.isFirstLaunch {
        Task {
            await NotificationManager.shared.requestPermissions()
        }
    }
    
    // ... rest of existing code ...
}
```

### 4. Integrate with TimerManager
**File**: `src/TimerManager.swift`

In the `timerCompleted()` method:
```swift
private func timerCompleted() {
    // Log completed session
    if let startTime = sessionStartTime {
        logSession(startTime: startTime, wasCompleted: true, wasInterrupted: false)
        
        // Send completion notification
        let subGoalsSummary = SubGoalsManager.shared.getSessionSummary()
        NotificationManager.shared.sendCompletionNotification(
            sessionTitle: mainTitle,
            actualDuration: Int(Date().timeIntervalSince(startTime)),
            completedGoals: subGoalsSummary.completed.count,
            totalGoals: subGoalsSummary.completed.count + subGoalsSummary.pending.count
        )
    }
    
    // ... rest of existing code
}
```

### 5. Add Notification Preferences
**File**: `src/Models/TimerDefaults.swift`

Add notification-related preferences:
```swift
// Add to existing TimerDefaults class
var notificationsEnabled: Bool {
    get { userDefaults.bool(forKey: Keys.notificationsEnabled.rawValue) }
    set { userDefaults.set(newValue, forKey: Keys.notificationsEnabled.rawValue) }
}

var showNotificationActions: Bool {
    get { userDefaults.bool(forKey: Keys.showNotificationActions.rawValue) }
    set { userDefaults.set(newValue, forKey: Keys.showNotificationActions.rawValue) }
}

// Add to Keys enum
case notificationsEnabled = "notifications_enabled"
case showNotificationActions = "show_notification_actions"
```

### 6. Add Notification Settings UI (Optional for MVP)
**File**: `src/Views/SprintPopoverView.swift`

Add notification toggle in the header:
```swift
// In header section with sound toggle
HStack {
    // Sound toggle (existing or from other branch)
    Button(action: { timerManager.setSoundEnabled(!timerManager.getSoundEnabled()) }) {
        Image(systemName: timerManager.getSoundEnabled() ? "speaker.wave.2" : "speaker.slash")
    }
    
    // Notification toggle
    Button(action: { 
        Task {
            let enabled = await NotificationManager.shared.areNotificationsEnabled()
            if !enabled {
                await NotificationManager.shared.requestPermissions()
            }
        }
    }) {
        Image(systemName: "bell")
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(currentColorScheme == .dark ? .green : .green)
    }
    .help("Enable Notifications")
    
    Spacer()
    
    // Theme toggle (existing)
}
```

## 🧪 Testing Checklist

### Permission Handling
- [ ] Permission request appears on first launch
- [ ] Graceful handling of denied permissions
- [ ] Can re-request permissions if initially denied
- [ ] Notification settings persist correctly
- [ ] Works when system notifications disabled globally

### Notification Content
- [ ] Notification appears when timer completes
- [ ] Rich content includes session summary
- [ ] Session title displayed correctly
- [ ] Duration and goal completion shown
- [ ] Notification actions work properly

### System Integration
- [ ] Notifications respect Do Not Disturb mode
- [ ] Works with Focus modes (if available)
- [ ] Notification sounds coordinate with app sound settings
- [ ] Badge count updates appropriately
- [ ] Notifications cleared when app becomes active

### Edge Cases
- [ ] Handles permission changes during runtime
- [ ] Works when app is backgrounded
- [ ] No duplicate notifications
- [ ] Proper cleanup when app terminates
- [ ] Performance impact minimal

## 🔧 Technical Requirements

### Dependencies
- `UserNotifications` framework
- Existing `TimerDefaults` for preferences
- Integration with `SessionLogger` for notification content

### Permission Types
```swift
let options: UNAuthorizationOptions = [.alert, .sound, .badge]
```

### Notification Categories
```swift
// Define notification categories with actions
let category = UNNotificationCategory(
    identifier: "TIMER_COMPLETION",
    actions: [
        UNNotificationAction(
            identifier: "START_NEW_SESSION",
            title: "Start New Session",
            options: [.foreground]
        ),
        UNNotificationAction(
            identifier: "VIEW_STATS",
            title: "View Stats",
            options: [.foreground]
        )
    ],
    intentIdentifiers: [],
    options: []
)
```

## 📱 Notification Content Examples

### Basic Completion Notification
```
Title: "🎯 Focus Session Complete!"
Body: "Great work on 'Feature Implementation' • 45:23 • 3/4 goals completed"
```

### Rich Notification with Actions
```
Title: "✅ Sprint Bell - Session Complete"
Body: "API Implementation (50:00)
✅ Write tests
✅ Add validation  
⏳ Update docs
📊 Progress: 67% • Effectiveness: 0.89"

Actions: [Start New Session] [View Stats]
```

## 📦 Expected Deliverables

1. **NotificationManager.swift** - Complete notification management
2. **NotificationDelegate.swift** - Handle user interactions
3. **Permission flow** - First-launch permission request
4. **TimerManager integration** - Send notifications on completion
5. **Rich notification content** - Session summaries with actions
6. **Preferences support** - Enable/disable functionality
7. **Error handling** - Graceful permission and delivery failures

## 🔗 Integration Points

### With Existing Code
- `SprintBellApp.swift` - Permission request on first launch
- `TimerManager.timerCompleted()` - Trigger notifications
- `TimerDefaults` - Notification preferences
- `SubGoalsManager` - Goal completion data

### With Other Features
- Completion Sound System - Coordinate audio with notifications
- Session Logging - Use logged data for notification content
- Future Preferences UI - Advanced notification settings

### With System
- macOS Notification Center integration
- Do Not Disturb mode respect
- Focus modes compatibility (macOS Monterey+)

## 🚀 Success Criteria

✅ **Primary Goal**: System notification appears on timer completion
✅ **Permission Handling**: Smooth first-launch permission experience
✅ **Rich Content**: Notification includes relevant session details
✅ **User Actions**: Notification actions work for workflow continuation
✅ **System Integration**: Respects system notification preferences
✅ **Reliability**: Consistent delivery across different system states

---

**Ready for Copilot implementation!** This feature completes the notification component of Sprint 3 and provides the foundation for enhanced user engagement.