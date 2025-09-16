# Sprint 2: Interactive Popover UI

**Duration**: 2-3 coding sessions  
**Goal**: Add clickable popover with timer controls, title editing, and sub-goals checklist

## 🎯 Sprint Objectives

### Primary Goals

- [x] Make menu bar item clickable to show popover
- [x] Create SwiftUI popover interface
- [x] Add timer control buttons (Start, Pause, Reset)
- [x] Implement editable main title
- [x] Create sub-goals checklist with add/remove functionality
- [x] Add preset timer buttons (25m, 50m, custom)

### Success Criteria

- ✅ Click menu bar → popover appears
- ✅ Timer controls work from popover UI
- ✅ Can edit main title in popover
- ✅ Can add/remove/check sub-goals
- ✅ Preset buttons set timer duration
- ✅ Popover state syncs with timer state

## 📋 Detailed Tasks

### 1. Popover Infrastructure

- Convert NSStatusItem to show popover on click
- Create SwiftUI view for popover content
- Handle popover show/hide logic
- Size popover appropriately (~300x400px)

### 2. Timer Controls UI

- Start button (▶️) - starts timer if stopped
- Pause button (⏸️) - pauses if running
- Reset button (🔄) - resets to original duration
- Display current state visually
- Show remaining time prominently

### 3. Title Editor

- TextField for main title
- Live updates to menu bar display
- Placeholder text: "Focus Session"
- Character limit (reasonable for menu bar)

### 4. Sub-Goals Checklist

- List of checkable sub-goals
- Add new sub-goal (+) button
- Remove sub-goal (X) button per item
- Check/uncheck functionality
- Persist state during session

### 5. Timer Presets

- 25-minute button (Pomodoro)
- 50-minute button (Deep work)
- Custom duration picker/input
- Apply preset sets both timer and updates display

### 6. Visual Design

- Clean, modern SwiftUI interface
- Clear visual hierarchy
- Appropriate spacing and padding
- Icons for buttons where helpful
- Status indication (running/paused/stopped)

## 🛠 Technical Implementation Notes

### Key Files to Create/Modify

```
SprintBell/
├── Views/
│   ├── SprintPopoverView.swift     # Main popover UI
│   ├── TimerControlsView.swift     # Start/pause/reset buttons
│   ├── SubGoalsView.swift          # Goals checklist
│   └── PresetButtonsView.swift     # Duration presets
├── Models/
│   └── SubGoal.swift               # Individual sub-goal model
└── StatusBarController.swift       # Modified for popover
```

### Core Views

**SprintPopoverView**

```swift
struct SprintPopoverView: View {
    @ObservedObject var timerManager: TimerManager
    @State private var subGoals: [SubGoal] = []

    var body: some View {
        VStack(spacing: 16) {
            TimerDisplayView()
            TitleEditorView()
            TimerControlsView()
            Divider()
            SubGoalsView()
            Divider()
            PresetButtonsView()
        }
        .padding()
        .frame(width: 300, height: 400)
    }
}
```

**TimerControlsView**

```swift
struct TimerControlsView: View {
    @ObservedObject var timerManager: TimerManager

    var body: some View {
        HStack(spacing: 12) {
            if timerManager.isRunning {
                Button("⏸️ Pause") { timerManager.pauseTimer() }
            } else {
                Button("▶️ Start") { timerManager.startTimer() }
            }
            Button("🔄 Reset") { timerManager.resetTimer() }
        }
        .buttonStyle(.borderedProminent)
    }
}
```

**SubGoalsView**

```swift
struct SubGoalsView: View {
    @Binding var subGoals: [SubGoal]
    @State private var newGoalText = ""

    var body: some View {
        VStack(alignment: .leading) {
            Text("Sub-Goals")
                .font(.headline)

            ForEach(subGoals) { goal in
                SubGoalRowView(goal: goal, onToggle: { toggleGoal(goal) }, onDelete: { deleteGoal(goal) })
            }

            HStack {
                TextField("Add sub-goal...", text: $newGoalText)
                Button("+") { addGoal() }
            }
        }
    }
}
```

### StatusBarController Updates

- Add popover property: `NSPopover`
- Handle click events to show/hide popover
- Position popover relative to status item
- Manage popover lifecycle

## 🎨 UI/UX Considerations

### Visual States

- **Stopped**: Grey/neutral colors
- **Running**: Green/active colors
- **Paused**: Yellow/warning colors
- **Overtime**: Red/urgent colors

### Interaction Design

- Smooth transitions between states
- Clear visual feedback for actions
- Keyboard shortcuts where appropriate
- Auto-close popover on outside click

### Accessibility

- Proper button labels
- Keyboard navigation support
- Voice Over compatibility
- Appropriate contrast ratios

## 🧪 Testing Checklist

- [ ] Click menu bar item opens popover
- [ ] Timer controls work correctly from popover
- [ ] Title editing updates menu bar display live
- [ ] Can add new sub-goals
- [ ] Can check/uncheck sub-goals
- [ ] Can delete sub-goals
- [ ] Preset buttons set correct durations
- [ ] Popover closes when clicking outside
- [ ] UI state matches timer state
- [ ] No memory leaks or performance issues

## 🎁 Sprint Deliverables

At the end of Sprint 2, you should have:

1. **Fully interactive menu bar** with clickable popover
2. **Complete timer controls** accessible via UI
3. **Editable session title** with live updates
4. **Working sub-goals system** with CRUD operations
5. **Timer presets** for common durations
6. **Professional-looking UI** ready for real use

## 🔄 Transition to Sprint 3

Sprint 2 provides the complete user interface foundation. Sprint 3 will add:

- Session persistence (save/restore state)
- Completion notifications and sounds
- Session history logging
- Data models for persistent storage

The UI components from Sprint 2 will remain largely unchanged, with Sprint 3 focusing on the data layer and system integrations!
