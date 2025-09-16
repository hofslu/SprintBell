# SprintBell — Menu Bar Coding Session Timer

A tiny macOS **menu bar** app for focused coding sprints. Shows a **live countdown** in the top bar (center-aligned via notch‑safe spacing trick), displays your **main title** beside the timer, and reveals **sub‑goals** in a dropdown popover. Plays a gentle **alarm** at the end and optionally notifies your **VSCode Coding Agent (Arno)** to summarize the session, s## Troubleshooting

- **No sound**: Verify macOS Focus Mode and app notification permission.
- **Timer not centered**: macOS doesn't support perfect centering—ensure the auxiliary spacing items are enabled.
- **VSCode tasks don't run**: Check that `curl` is available and no shell protections block the JSON quoting; try using the URL scheme variant.
- **Port 5757 in use**: Change SprintBell's port in Preferences → Integrations.
- **MCP connection issues**:
  - Ensure MCP server is enabled in SprintBell preferences
  - Check that your AI assistant's MCP client configuration points to the correct endpoint
  - Verify firewall settings allow local connections to port 5757
  - Test MCP connectivity with `curl -N http://127.0.0.1:5757/mcp/sse`
- **AI assistant not seeing sprint context**: Check MCP resource permissions and ensure SprintBell is running with active session data.otes, or suggest next steps.

---

## Features

- **Menu bar countdown** (e.g., `47:32 • Vector DB layer`), updates every second.
- **One‑click popover** with:
  - Main title & editable **sub‑goals** checklist
  - Start/Pause/Resume/Reset controls
  - Presets (50m, 25m, custom)
- **Alarm + system notification** at finish.
- **Session log** stored locally as JSONL.
- **Hooks** for VSCode integration (CLI, URL scheme, local HTTP).

---

## Quick Start (dev build)

> **Stack**: Swift 5.9+, SwiftUI + AppKit bridge (for `NSStatusBar`, global hotkey), macOS 13+

1. **Create project**

   - Open Xcode → App → macOS → SwiftUI App.
   - Product Name: `SprintBell` (Bundle ID e.g. `ai.arno.sprintbell`).
   - Check _"Use Core Data"_ off; check _"Include Tests"_ as you like.

2. **Add capabilities**

   - _App Sandbox_: enable **Outgoing Network** (for local HTTP callbacks), **User Notifications**.

3. **Add targets / groups**

   - `Sources/StatusItem/` – menu bar controller (NSStatusItem + Timer)
   - `Sources/UI/` – SwiftUI views for popover (Title, Sub‑goals, Controls)
   - `Sources/Integration/` – URL scheme & tiny HTTP server (NWListener on 127.0.0.1:5757)
   - `Sources/Storage/` – JSONL logger (~/Library/Application Support/SprintBell/log.jsonl)
   - `Resources/Sounds/` – `alarm.mp3` or use `SystemSoundID` 1304 as fallback

4. **Status item title format**

   - Show: `MM:SS • <MainTitle>`
   - When paused: prefix `⏸` ; when running: `▶︎` ; when overtime: `⏱ +MM:SS`.

5. **Center-ish alignment**

   - Add leading and trailing flexible space menu bar items: an _optional_ trick is to insert two auxiliary status items named `"\u2007\u2007\u2007"` (figure spaces) before/after your main item to visually center near the notch on most MacBooks. (Pure centering isn’t supported by API, so this is a tasteful hack.)

6. **Notifications & sound**

   - Use `UNUserNotificationCenter` to request authorization on first run.
   - On finish, post notification (title = main title; body = goals summary) and play alarm.

7. **Persistence**
   - `UserDefaults` for last duration, main title, sub‑goals.
   - `log.jsonl` appends one object per session:
     ```json
     {
       "ts_start": "2025-09-16T09:00:00+02:00",
       "ts_end": "2025-09-16T09:50:00+02:00",
       "title": "RAG retriever",
       "goals": ["write tests", "benchmark HNSW"],
       "duration_sec": 3000,
       "notes": "...",
       "result": "Complete"
     }
     ```

---

## Command Interfaces (pick any)

### 1) Custom URL scheme

- Register `sprintbell://` in `Info.plist` → URL Types.
- Example invocations:
  - **Start**: `sprintbell://start?mins=50&title=API%20Endpoints&goals=tests,docs,refactor`
  - **Pause**: `sprintbell://pause`
  - **Stop**: `sprintbell://stop?result=Complete`
  - **Note**: `sprintbell://note?text=Covered%20edge%20cases`

### 2) Local HTTP control (default: `127.0.0.1:5757`)

**POST** `http://127.0.0.1:5757/start`

```json
{
  "minutes": 50,
  "title": "Vector DB layer",
  "goals": ["schema", "bench", "docs"]
}
```

**POST** `/pause`, `/resume`, `/stop`, `/note`

```json
{ "text": "Found better recall@10 at ef=200" }
```

**GET** `/status` → current countdown & state.

### 3) Tiny CLI shim (optional)

Install a helper script `sprintbell` into your `$PATH` that just opens the URL scheme or hits the HTTP port:

```bash
sprintbell start --mins 50 --title "API" --goals "tests,docs"
sprintbell pause
sprintbell note "Commit 9b2 adds caching"
```

---

## VSCode Integration (Coding Agent friendly)

### A. Tasks to start/stop a sprint

`.vscode/tasks.json`

```jsonc
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "SprintBell: Start 50m",
      "type": "shell",
      "command": "curl -s -X POST http://127.0.0.1:5757/start -H 'Content-Type: application/json' -d '{\"minutes\":50,\"title\":\"${workspaceFolderBasename}\",\"goals\":[\"Write tests\",\"Implement\",\"Docs\"]}'"
    },
    {
      "label": "SprintBell: Stop",
      "type": "shell",
      "command": "curl -s -X POST http://127.0.0.1:5757/stop -H 'Content-Type: application/json' -d '{\"result\":\"Complete\"}'"
    },
    {
      "label": "SprintBell: Note",
      "type": "shell",
      "command": "sh -c 'read -p \"Note: \" N; curl -s -X POST http://127.0.0.1:5757/note -H \"Content-Type: application/json\" -d "'"'{"text":"'"'"$N'"'""}'"'"'
    }
  ]
}
```

### B. Keybindings for sprint control

`keybindings.json`

```jsonc
[
  {
    "key": "cmd+shift+9",
    "command": "workbench.action.tasks.runTask",
    "args": "SprintBell: Start 50m"
  },
  {
    "key": "cmd+shift+0",
    "command": "workbench.action.tasks.runTask",
    "args": "SprintBell: Stop"
  }
]
```

### C. Surface sprint status in VSCode status bar

Create an **extension snippet** with `statusBarItem` that polls `/status` each 5s and shows `25:14 • API`. On click, open the SprintBell popover via URL scheme `sprintbell://focus`.

**Extension skeleton (TypeScript) sketch:**

```ts
import * as vscode from "vscode";
import fetch from "node-fetch";
export function activate(ctx: vscode.ExtensionContext) {
  const item = vscode.window.createStatusBarItem(
    vscode.StatusBarAlignment.Left,
    10
  );
  item.text = "SprintBell: --:--";
  item.show();
  const tick = async () => {
    try {
      const r = await fetch("http://127.0.0.1:5757/status");
      const s = await r.json();
      item.text = `$(watch) ${s.remaining} • ${s.title}`;
      item.command = {
        command: "vscode.open",
        arguments: [vscode.Uri.parse("sprintbell://focus")],
      };
    } catch {
      item.text = "SprintBell: idle";
    }
  };
  const iv = setInterval(tick, 5000);
  tick();
  ctx.subscriptions.push({
    dispose() {
      clearInterval(iv);
    },
  });
}
```

### D. Hook into your Coding Agent (Arno)

When a sprint **starts/stops**, SprintBell can call your agent:

- **Configure env** in SprintBell (Preferences → Integrations):

  - `ARNO_WEBHOOK_START` (e.g., `http://127.0.0.1:7049/hooks/sprint/start`)
  - `ARNO_WEBHOOK_STOP` (e.g., `http://127.0.0.1:7049/hooks/sprint/stop`)
  - Optional `ARNO_TOKEN` for `Authorization: Bearer ...`

- **Payload**

  ```json
  {
    "title": "Vector DB layer",
    "goals": ["schema", "bench", "docs"],
    "ts_start": "2025-09-16T09:00:00+02:00",
    "duration_sec": 3000,
    "notes": ["Found better recall@10 at ef=200"],
    "result": "Complete" // only on stop
  }
  ```

- **Example cURL** (sent by SprintBell):

  ```bash
  curl -s -X POST "$ARNO_WEBHOOK_START" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $ARNO_TOKEN" \
    -d @/path/to/tmp/sprintbell_last_start.json
  ```

- **Agent ideas**
  - Auto‑create a _journal_ entry with title, diff summary, and PR links.
  - Trigger a _review checklist_ if sprint result is `Progress` or `Postponed`.
  - Draft a _commit message_ from the notes + changed files.

### E. MCP (Model Context Protocol) Integration

SprintBell can act as an **MCP server** to expose sprint context to AI assistants like Claude, ChatGPT, or local models. This enables seamless integration with AI-powered development workflows.

#### MCP Server Setup

SprintBell runs an integrated MCP server alongside the HTTP API:

- **Default endpoint**: `http://127.0.0.1:5757/mcp`
- **Transport**: Server-Sent Events (SSE) or WebSocket
- **Configuration**: Enable in Preferences → Integrations → MCP Server

#### Available MCP Tools

```typescript
// Get current sprint status and context
{
  "name": "sprintbell_get_status",
  "description": "Get current sprint timer status, goals, and progress",
  "inputSchema": {
    "type": "object",
    "properties": {}
  }
}

// Start a new sprint with AI-suggested parameters
{
  "name": "sprintbell_start_sprint",
  "description": "Start a new focused coding sprint",
  "inputSchema": {
    "type": "object",
    "properties": {
      "title": {"type": "string", "description": "Main sprint objective"},
      "duration_minutes": {"type": "number", "description": "Sprint duration"},
      "goals": {"type": "array", "items": {"type": "string"}, "description": "Sub-goals checklist"}
    },
    "required": ["title", "duration_minutes"]
  }
}

// Add contextual notes during sprint
{
  "name": "sprintbell_add_note",
  "description": "Add a timestamped note to current sprint",
  "inputSchema": {
    "type": "object",
    "properties": {
      "note": {"type": "string", "description": "Note content"},
      "category": {"type": "string", "enum": ["progress", "blocker", "idea", "decision"]}
    },
    "required": ["note"]
  }
}

// Query sprint history and patterns
{
  "name": "sprintbell_get_history",
  "description": "Retrieve past sprint sessions for analysis",
  "inputSchema": {
    "type": "object",
    "properties": {
      "days": {"type": "number", "description": "Number of days to look back"},
      "project_filter": {"type": "string", "description": "Filter by project/title keyword"}
    }
  }
}
```

#### MCP Resources

SprintBell exposes sprint context as resources:

```json
{
  "resources": [
    {
      "uri": "sprintbell://current-session",
      "name": "Current Sprint Session",
      "description": "Live sprint context including timer, goals, and notes",
      "mimeType": "application/json"
    },
    {
      "uri": "sprintbell://session-log",
      "name": "Sprint Session Log",
      "description": "Complete JSONL log of all sprint sessions",
      "mimeType": "application/x-jsonlines"
    },
    {
      "uri": "sprintbell://productivity-stats",
      "name": "Productivity Statistics",
      "description": "Aggregated sprint analytics and patterns",
      "mimeType": "application/json"
    }
  ]
}
```

#### AI Assistant Integration Examples

**Claude/Copilot Chat Integration:**

```json
// MCP client configuration for Claude
{
  "mcpServers": {
    "sprintbell": {
      "command": "curl",
      "args": ["-N", "http://127.0.0.1:5757/mcp/sse"],
      "env": {}
    }
  }
}
```

**Workflow Examples:**

1. **Sprint Planning**: AI analyzes your codebase and suggests sprint titles, durations, and goals
2. **Progress Tracking**: AI monitors your sprint and suggests breaking down complex goals
3. **Retrospective Analysis**: AI reviews sprint history to identify productivity patterns
4. **Context Switching**: AI helps resume work by summarizing previous sprint progress

**Sample AI Conversation:**

```
User: "Help me plan a 50-minute sprint for the authentication module"

AI: Let me check your current codebase and start a focused sprint.
[Uses sprintbell_start_sprint]
✓ Started "Auth Module Implementation" (50min)
Goals: JWT token handling, password validation, session management

User: "I'm stuck on the JWT validation logic"

AI: [Uses sprintbell_add_note with category "blocker"]
Let me help you with JWT validation patterns...
```

#### Configuration in VS Code Settings

```json
{
  "mcp.servers": {
    "sprintbell": {
      "command": "http",
      "args": ["127.0.0.1:5757/mcp"],
      "initializationOptions": {
        "apiKey": "${env:SPRINTBELL_MCP_KEY}"
      }
    }
  }
}
```

#### Quick MCP Integration Reference

**Enable MCP Server**: SprintBell → Preferences → Integrations → Enable MCP Server  
**MCP Endpoint**: `http://127.0.0.1:5757/mcp`  
**Available Tools**: `sprintbell_get_status`, `sprintbell_start_sprint`, `sprintbell_add_note`, `sprintbell_get_history`  
**Resources**: Current session, session log, productivity stats  
**AI Use Cases**: Sprint planning, progress tracking, retrospective analysis, context switching

---

## JSON Log Format

Each finished session appends one line to `log.jsonl`:

```json
{"ts_start":"...","ts_end":"...","title":"...","goals":["..."],"duration_sec":...,"notes":["..."],"result":"Complete|Progress|Postponed"}
```

---

## Privacy & Security

- Data stays local by default.
- HTTP control binds to `127.0.0.1` only.
- Webhooks only fire to user‑configured endpoints.

---

## Troubleshooting

- **No sound**: Verify macOS Focus Mode and app notification permission.
- **Timer not centered**: macOS doesn’t support perfect centering—ensure the auxiliary spacing items are enabled.
- **VSCode tasks don’t run**: Check that `curl` is available and no shell protections block the JSON quoting; try using the URL scheme variant.
- **Port 5757 in use**: Change SprintBell’s port in Preferences → Integrations.

---

## Roadmap

- Pomodoro cycles (work/break), multi‑sprint plans.
- iCloud sync of presets.
- Per‑project default titles & sub‑goal templates.
- Advanced stats dashboard.
- **Enhanced MCP Integration**:
  - Real-time sprint context streaming to AI assistants
  - AI-powered sprint goal suggestions based on codebase analysis
  - Automatic sprint retrospectives with productivity insights
  - Integration with GitHub Copilot workspace context
  - Smart break recommendations based on focus patterns

---

## License

Choose your favorite permissive license (MIT recommended for tiny utility apps).

---

## Credits

Built with ❤️ for focused makers. Inspired by Vienna’s rhythm and Arno’s calm guidance.
