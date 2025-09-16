# SprintBell — Menu Bar Coding Session Timer

A tiny macOS **menu bar** app for focused coding sprints. Shows a **live countdown** in the top bar (center-aligned via notch‑safe spacing trick), displays your **main title** beside the timer, and reveals **sub‑goals** in a dropdown popover. Plays a gentle **alarm** at the end and optionally notifies your **VSCode Coding Agent (Arno)** to summarize the session, store notes, or suggest next steps.

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

---

## License

Choose your favorite permissive license (MIT recommended for tiny utility apps).

---

## Credits

Built with ❤️ for focused makers. Inspired by Vienna’s rhythm and Arno’s calm guidance.
