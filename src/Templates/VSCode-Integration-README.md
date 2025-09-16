# VSCode Integration Setup

SprintBell now supports VSCode integration via URL schemes! This allows you to start, pause, stop, and add notes to your sprint sessions directly from VSCode.

## Quick Setup

### 1. Copy VSCode Templates

Copy the provided templates to your VSCode workspace:

```bash
# From SprintBell project root
cp src/Templates/tasks.json .vscode/tasks.json
cp src/Templates/keybindings.json .vscode/keybindings.json
```

### 2. Test URL Scheme

Ensure SprintBell is built and the URL scheme is registered:

```bash
# Test the URL scheme from terminal
open "sprintbell://start?mins=25&title=Test&goals=focus"
```

### 3. Use in VSCode

**Via Command Palette:**
1. Press `Cmd+Shift+P` 
2. Type "Tasks: Run Task"
3. Select any SprintBell task

**Via Keybindings:**
- `Cmd+Shift+S` - Start 25min Focus Sprint
- `Cmd+Shift+D` - Start 50min Deep Work Sprint  
- `Cmd+Shift+C` - Start Custom Sprint (with prompts)
- `Cmd+Shift+P` - Pause/Resume current sprint
- `Cmd+Shift+X` - Stop current sprint
- `Cmd+Shift+N` - Add note to current sprint

## Available Tasks

### Pre-configured Sprints
- **25min Focus**: Quick focused session with current project name
- **50min Deep Work**: Longer session with implementation, testing, documentation goals
- **Custom Sprint**: Prompts for duration, title, and goals

### Sprint Controls
- **Pause/Resume**: Toggle current sprint state
- **Stop Sprint**: End current sprint with completion status
- **Add Note**: Add timestamped note to current session

## URL Scheme Reference

SprintBell uses the `sprintbell://` URL scheme with these commands:

### Start Sprint
```
sprintbell://start?mins=25&title=My%20Project&goals=focus,implement,test
```

Parameters:
- `mins` - Duration in minutes (default: 25)
- `title` - Sprint title (default: "Focus Session") 
- `goals` - Comma-separated list of goals (optional)

### Control Commands
```
sprintbell://pause          # Pause/resume current sprint
sprintbell://stop?result=Complete     # Stop with completion status
sprintbell://note?text=Progress%20update   # Add note to current sprint
```

## Troubleshooting

### URL Scheme Not Working
1. Ensure SprintBell is built and has been run at least once
2. Check that Info.plist contains the URL scheme registration
3. Test from terminal: `open "sprintbell://start?mins=5&title=Test"`

### VSCode Tasks Not Appearing
1. Ensure `.vscode/tasks.json` exists in your workspace root
2. Reload VSCode window: `Cmd+Shift+P` > "Developer: Reload Window"
3. Check Command Palette: `Cmd+Shift+P` > "Tasks: Run Task"

### Keybindings Not Working
1. Ensure `.vscode/keybindings.json` exists in your workspace root
2. Check for conflicts: `Cmd+Shift+P` > "Preferences: Open Keyboard Shortcuts"
3. Verify keybindings are loaded: Look for "SprintBell" tasks in shortcuts

## Integration with Development Workflow

### Typical Sprint Workflow
1. **Start Sprint**: `Cmd+Shift+S` for 25min or `Cmd+Shift+D` for 50min
2. **Focus**: Work with timer visible in menu bar
3. **Add Progress Notes**: `Cmd+Shift+N` as needed
4. **Complete**: `Cmd+Shift+X` when finished

### Project-Specific Customization

You can customize the VSCode tasks for your specific project by editing `.vscode/tasks.json`:

```json
{
    "label": "My Custom Sprint",
    "type": "shell",
    "command": "open",
    "args": [
        "sprintbell://start?mins=45&title=Feature%20X&goals=research,prototype,test"
    ]
}
```

## Future Enhancements

Sprint 4 provides the foundation for advanced features coming in future sprints:
- **Sprint 5**: HTTP API for richer programmatic control
- **Sprint 6**: Advanced VSCode extension with status bar integration
- **Sprint 7**: MCP integration for AI assistant support

---

**Happy focused coding! 🎯**