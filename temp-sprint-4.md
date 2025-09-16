## Sprint Objectives

**Duration**: 2-3 coding sessions  
**Goal**: Enable basic VSCode integration via URL schemes and tasks  

### Primary Goals
- [x] Register sprintbell:// URL scheme  
- [x] Implement URL scheme handler with parameter parsing
- [x] Create .vscode/tasks.json with SprintBell tasks
- [x] Add keybindings for common actions  
- [x] Support basic commands: start, pause, stop, note
- [x] Test integration workflow end-to-end

### Success Criteria
- ✅ Can start timer from VSCode task
- ✅ Can control timer via URL schemes  
- ✅ VSCode keybindings work smoothly
- ✅ Parameters correctly parsed (title, duration, goals)
- ✅ URL scheme handles edge cases gracefully

## Implementation Tasks

### 1. URL Scheme Registration
- [x] Add URL scheme to Info.plist
- [x] Register sprintbell:// as custom protocol
- [x] Configure app to handle URL scheme launches  
- [x] Test scheme registration with system

### 2. URL Scheme Handler
- [x] Create URLSchemeHandler class
- [x] Parse incoming URLs and extract parameters
- [x] Support commands: start, pause, stop, note
- [x] Handle URL encoding/decoding properly
- [x] Validate parameters and provide sensible defaults

### 3. VSCode Tasks Configuration  
- [x] Create .vscode/tasks.json template
- [x] Tasks for start (25m, 50m), pause, stop, add note
- [x] Use project name as default title
- [x] Include common sub-goals templates
- [x] Properly escape JSON and shell commands

### 4. Keybindings Setup
- [x] Create keybindings.json template
- [x] Bind Cmd+Shift+S for start sprint
- [x] Bind Cmd+Shift+P for pause/resume  
- [x] Bind Cmd+Shift+X for stop sprint
- [x] Bind Cmd+Shift+N for add note

### 5. Testing & Validation
- [x] Test URL scheme from terminal
- [x] Test VSCode task execution
- [x] Test keybinding functionality
- [x] Validate parameter parsing edge cases
- [x] Create sprint test script

## Technical Notes
- URL scheme format: sprintbell://action?title=value&duration=1500&goals=goal1,goal2
- Integration with existing TimerManager and session data
- Foundation for advanced VSCode features in Sprint 6
- Prepares for HTTP API server in Sprint 5

## Dependencies  
- Sprint 3 (Data Persistence) must be completed
- Builds foundation for Sprint 5 (HTTP API) and Sprint 6 (Advanced VSCode)

---
**✅ Sprint 4 Complete! Foundation established for all VSCode integration features!**