# Sprint 1: Core Menu Bar Timer

**Duration**: 1-2 coding sessions  
**Goal**: Get a basic functional timer running in the macOS menu bar with live countdown display

## 🎯 Sprint Objectives

### Primary Goals

- [x] Set up Xcode macOS SwiftUI project with proper configuration
- [x] Implement basic NSStatusItem in menu bar
- [x] Create countdown timer that updates every second
- [x] Display timer in format: `MM:SS • Main Title`
- [x] Basic start/stop functionality (can be minimal UI for now)

### Success Criteria

- ✅ Timer visible in macOS menu bar
- ✅ Live countdown updates every second
- ✅ Can start and stop timer programmatically
- ✅ Shows current title alongside timer
- ✅ Clean, readable display format

## 📋 Detailed Tasks

### 1. Project Setup

- Create new macOS SwiftUI app in Xcode
- Product Name: `SprintBell`
- Bundle ID: `ai.arno.sprintbell` (or your preference)
- Enable necessary capabilities:
  - App Sandbox (for future networking)
  - User Notifications (for future alerts)
- Disable Core Data (not needed for this project)

### 2. Menu Bar Integration

- Import AppKit for NSStatusItem
- Create `StatusBarController` class
- Initialize status item in app delegate/main app
- Set initial menu bar text

### 3. Timer Logic

- Create `TimerManager` ObservableObject
- Implement countdown logic with Timer.scheduledTimer
- Track state: remaining seconds, is running, main title
- Update status item text every second

### 4. Basic Controls

- Simple in-code timer controls for testing
- Start timer function (with default 25 minutes)
- Stop/pause timer function
- Reset timer function

### 5. Display Format

- Format time as `MM:SS` (e.g., "47:32")
- Concatenate with separator and title: `47:32 • Vector DB layer`
- Handle edge cases (overtime, paused states)

## 🛠 Technical Implementation Notes

### Key Files to Create

```
SprintBell/
├── SprintBellApp.swift           # Main app entry point
├── StatusBarController.swift     # NSStatusItem management
├── TimerManager.swift           # Timer logic and state
└── Models/
    └── SprintSession.swift      # Data model for sprint
```

### Core Classes

**StatusBarController**

```swift
class StatusBarController: ObservableObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    @Published var currentText: String = "SprintBell"

    func updateDisplay(_ text: String) {
        statusItem.button?.title = text
    }
}
```

**TimerManager**

```swift
class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var mainTitle: String = "Focus Session"
    private var timer: Timer?

    func startTimer(duration: Int) { /* ... */ }
    func stopTimer() { /* ... */ }
    func formatDisplay() -> String { /* ... */ }
}
```

## 🧪 Testing Checklist

- [ ] Timer appears in menu bar on app launch
- [ ] Timer counts down correctly (test with 30 seconds)
- [ ] Display format matches specification (`MM:SS • Title`)
- [ ] Can start timer programmatically
- [ ] Can stop timer and see it pause
- [ ] Timer resets correctly
- [ ] App doesn't crash or freeze during countdown
- [ ] Menu bar updates smoothly every second

## 🎁 Sprint Deliverables

At the end of Sprint 1, you should have:

1. **Working Xcode project** properly configured
2. **Visible menu bar timer** that counts down
3. **Basic timer controls** (even if just in code)
4. **Foundation classes** ready for Sprint 2 expansion

## 🔄 Transition to Sprint 2

Sprint 1 provides the core foundation. Sprint 2 will add:

- Clickable popover interface
- Visual timer controls (start/stop/reset buttons)
- Editable title and sub-goals
- Timer presets (25m, 50m, custom)

The `TimerManager` and `StatusBarController` from Sprint 1 will be the backbone for all future functionality!
