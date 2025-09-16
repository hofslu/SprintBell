# Sprint 4: VSCode Integration Foundation

**Duration**: 2-3 coding sessions  
**Goal**: Enable basic VSCode integration via URL schemes and tasks

## 🎯 Sprint Objectives

### Primary Goals

- [x] Register `sprintbell://` URL scheme
- [x] Implement URL scheme handler with parameter parsing
- [x] Create `.vscode/tasks.json` with SprintBell tasks
- [x] Add keybindings for common actions
- [x] Support basic commands: start, pause, stop, note
- [x] Test integration workflow end-to-end

### Success Criteria

- ✅ Can start timer from VSCode task
- ✅ Can control timer via URL schemes
- ✅ VSCode keybindings work smoothly
- ✅ Parameters correctly parsed (title, duration, goals)
- ✅ URL scheme handles edge cases gracefully

## 📋 Detailed Tasks

### 1. URL Scheme Registration

- Add URL scheme to `Info.plist`
- Register `sprintbell://` as custom protocol
- Configure app to handle URL scheme launches
- Test scheme registration with system

### 2. URL Scheme Handler

- Create `URLSchemeHandler` class
- Parse incoming URLs and extract parameters
- Support commands: `start`, `pause`, `stop`, `note`
- Handle URL encoding/decoding properly
- Validate parameters and provide sensible defaults

### 3. VSCode Tasks Configuration

- Create `.vscode/tasks.json` template
- Tasks for start (25m, 50m), pause, stop, add note
- Use project name as default title
- Include common sub-goals templates
- Properly escape JSON and shell commands

### 4. Keybindings Setup

- Create `keybindings.json` template
- Logical key combinations (⌘⇧9 start, ⌘⇧0 stop)
- Avoid conflicts with common VSCode shortcuts
- Document keybindings clearly

### 5. Parameter Parsing

- Title from URL parameters
- Duration in minutes
- Sub-goals as comma-separated list
- Notes with timestamp
- Result status (Complete, Progress, Postponed)

## 🛠 Technical Implementation Notes

### URL Scheme Commands

**Start Sprint**

```
sprintbell://start?mins=50&title=API%20Endpoints&goals=tests,docs,refactor
```

**Control Commands**

```
sprintbell://pause
sprintbell://stop?result=Complete
sprintbell://note?text=Found%20edge%20case%20in%20validation
```

### Key Files to Create/Modify

```
SprintBell/
├── Integration/
│   ├── URLSchemeHandler.swift      # URL scheme processing
│   └── VSCodeIntegration.swift     # VSCode-specific helpers
├── Templates/
│   ├── tasks.json                  # VSCode tasks template
│   └── keybindings.json           # VSCode keybindings template
└── Info.plist                     # URL scheme registration
```

### URLSchemeHandler Implementation

```swift
class URLSchemeHandler: ObservableObject {
    @ObservedObject var timerManager: TimerManager

    func handleURL(_ url: URL) {
        guard url.scheme == "sprintbell" else { return }

        switch url.host {
        case "start":
            handleStartCommand(url)
        case "pause":
            timerManager.pauseTimer()
        case "stop":
            handleStopCommand(url)
        case "note":
            handleNoteCommand(url)
        default:
            print("Unknown command: \(url.host ?? "nil")")
        }
    }

    private func handleStartCommand(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []

        let minutes = queryItems.first(where: { $0.name == "mins" })?.value.flatMap(Int.init) ?? 25
        let title = queryItems.first(where: { $0.name == "title" })?.value ?? "Focus Session"
        let goalsString = queryItems.first(where: { $0.name == "goals" })?.value ?? ""
        let goals = goalsString.split(separator: ",").map(String.init)

        timerManager.startTimer(duration: minutes * 60, title: title, goals: goals)
    }
}
```

### VSCode Tasks Template

```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "SprintBell: Start 25min",
      "type": "shell",
      "command": "open",
      "args": [
        "sprintbell://start?mins=25&title=${workspaceFolderBasename}&goals=implement,test,document"
      ],
      "group": "build",
      "presentation": {
        "echo": false,
        "reveal": "never",
        "focus": false,
        "panel": "shared"
      }
    },
    {
      "label": "SprintBell: Start 50min Deep Work",
      "type": "shell",
      "command": "open",
      "args": [
        "sprintbell://start?mins=50&title=${workspaceFolderBasename}&goals=architecture,implementation,testing"
      ]
    },
    {
      "label": "SprintBell: Pause",
      "type": "shell",
      "command": "open",
      "args": ["sprintbell://pause"]
    },
    {
      "label": "SprintBell: Stop Complete",
      "type": "shell",
      "command": "open",
      "args": ["sprintbell://stop?result=Complete"]
    },
    {
      "label": "SprintBell: Add Note",
      "type": "shell",
      "command": "sh",
      "args": [
        "-c",
        "read -p 'Note: ' note && open \"sprintbell://note?text=$note\""
      ]
    }
  ]
}
```

### Keybindings Template

```json
[
  {
    "key": "cmd+shift+9",
    "command": "workbench.action.tasks.runTask",
    "args": "SprintBell: Start 25min"
  },
  {
    "key": "cmd+shift+0",
    "command": "workbench.action.tasks.runTask",
    "args": "SprintBell: Stop Complete"
  },
  {
    "key": "cmd+shift+p",
    "command": "workbench.action.tasks.runTask",
    "args": "SprintBell: Pause"
  },
  {
    "key": "cmd+shift+n",
    "command": "workbench.action.tasks.runTask",
    "args": "SprintBell: Add Note"
  }
]
```

### Info.plist URL Scheme Registration

```xml
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleURLName</key>
        <string>SprintBell URL Scheme</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <string>sprintbell</string>
        </array>
    </dict>
</array>
```

## 🔗 Integration Workflow

### Typical Developer Workflow

1. **Start coding session**: ⌘⇧9 in VSCode → launches 25min timer with project name
2. **Add progress notes**: ⌘⇧N → quick note about current progress
3. **Complete session**: ⌘⇧0 → stops timer, logs session as complete
4. **Menu bar shows progress**: Live countdown with project context

### URL Parameter Details

- `mins`: Duration in minutes (default: 25)
- `title`: Session title (default: "Focus Session", URL encoded)
- `goals`: Comma-separated goals list (URL encoded)
- `text`: Note text for note command (URL encoded)
- `result`: Session result - "Complete", "Progress", or "Postponed"

## 🧪 Testing Checklist

- [ ] URL scheme registered and recognized by macOS
- [ ] Can launch SprintBell via `open sprintbell://start`
- [ ] Parameters parsed correctly from URLs
- [ ] VSCode tasks execute without errors
- [ ] Keybindings don't conflict with existing shortcuts
- [ ] Special characters in titles/notes handled properly
- [ ] App handles invalid/malformed URLs gracefully
- [ ] Integration works from VSCode terminal
- [ ] URL scheme works when app not already running

## 🎁 Sprint Deliverables

At the end of Sprint 4, you should have:

1. **Working URL scheme** - `sprintbell://` commands control the app
2. **VSCode tasks** - ready-to-use `.vscode/tasks.json` template
3. **Keybindings** - convenient keyboard shortcuts for common actions
4. **Parameter parsing** - robust handling of URL parameters
5. **Integration templates** - easy setup for any project

## 🔄 Transition to Sprint 5

Sprint 4 establishes the foundation for external tool integration. Sprint 5 will add:

- HTTP API server for programmatic control
- More robust parameter handling
- JSON request/response format
- Foundation for advanced integrations

The URL scheme system from Sprint 4 provides the basic automation layer, while Sprint 5's HTTP API will enable more sophisticated tooling and integrations!
