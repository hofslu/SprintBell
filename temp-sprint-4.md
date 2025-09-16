## Sprint Objectives

**Duration**: 2-3 coding sessions  
**Goal**: Enable basic VSCode integration via URL schemes and tasks  

### Primary Goals
- [ ] Register sprintbell:// URL scheme  
- [ ] Implement URL scheme handler with parameter parsing
- [ ] Create .vscode/tasks.json with SprintBell tasks
- [ ] Add keybindings for common actions  
- [ ] Support basic commands: start, pause, stop, note
- [ ] Test integration workflow end-to-end

### Success Criteria
- ✅ Can start timer from VSCode task
- ✅ Can control timer via URL schemes  
- ✅ VSCode keybindings work smoothly
- ✅ Parameters correctly parsed (title, duration, goals)
- ✅ URL scheme handles edge cases gracefully

## Implementation Tasks

### 1. URL Scheme Registration
- [ ] Add URL scheme to Info.plist
- [ ] Register sprintbell:// as custom protocol
- [ ] Configure app to handle URL scheme launches  
- [ ] Test scheme registration with system

### 2. URL Scheme Handler
- [ ] Create URLSchemeHandler class
- [ ] Parse incoming URLs and extract parameters
- [ ] Support commands: start, pause, stop, note
- [ ] Handle URL encoding/decoding properly
- [ ] Validate parameters and provide sensible defaults

### 3. VSCode Tasks Configuration  
- [ ] Create .vscode/tasks.json template
- [ ] Tasks for start (25m, 50m), pause, stop, add note
- [ ] Use project name as default title
- [ ] Include common sub-goals templates
- [ ] Properly escape JSON and shell commands

### 4. Keybindings Setup
- [ ] Create keybindings.json template
- [ ] Bind Cmd+Shift+S for start sprint
- [ ] Bind Cmd+Shift+P for pause/resume  
- [ ] Bind Cmd+Shift+X for stop sprint
- [ ] Bind Cmd+Shift+N for add note

### 5. Testing & Validation
- [ ] Test URL scheme from terminal
- [ ] Test VSCode task execution
- [ ] Test keybinding functionality
- [ ] Validate parameter parsing edge cases
- [ ] Create sprint test script

## Technical Notes
- URL scheme format: sprintbell://action?title=value&duration=1500&goals=goal1,goal2
- Integration with existing TimerManager and session data
- Foundation for advanced VSCode features in Sprint 6
- Prepares for HTTP API server in Sprint 5

## Dependencies  
- Sprint 3 (Data Persistence) must be completed
- Builds foundation for Sprint 5 (HTTP API) and Sprint 6 (Advanced VSCode)

---
**Sprint 4 establishes the foundation for all VSCode integration features!**