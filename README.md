# SprintBell 🔔

**A macOS focus timer with deep VSCode and AI coding agent integration**

SprintBell is a menu bar timer designed specifically for developers, featuring automated project tracking, coding session analytics, and seamless integration with AI development workflows.

## ✨ Features

- **Live menu bar countdown** with session title display
- **Interactive popover** with timer controls and sub-goals checklist  
- **Theme management** (system/light/dark) with manual toggle
- **Session persistence** across app restarts
- **VSCode integration** via tasks, keybindings, and HTTP API
- **AI coding agent support** with MCP server integration

## 🚀 Quick Start

```bash
# Clone and build
git clone https://github.com/hofslu/SprintBell.git
cd SprintBell
swift run

# The app appears in your menu bar - click to start a focus session!
```

## 📋 Project Structure

```
SprintBell/
├── src/                             # Swift source code
│   ├── SprintBellApp.swift          # Main app entry point
│   ├── StatusBarController.swift    # Menu bar management  
│   ├── TimerManager.swift           # Core timer logic
│   ├── Models/                      # Data models and managers
│   └── Views/                       # SwiftUI interface components
├── docs/                           # Documentation and guides
│   ├── integration-sprints/         # Sprint planning documentation
│   └── Coding-Agent-Integration-Guide.md  # AI agent instructions
└── tests/                          # Sprint validation scripts
```

## 🤖 For AI Coding Agents

**👉 See [`docs/Coding-Agent-Integration-Guide.md`](docs/Coding-Agent-Integration-Guide.md)** for comprehensive instructions on:
- Project navigation and architecture
- Development workflow and branch strategy
- Issue assignment and status tracking
- Technical implementation guidelines
- MCP integration details

**Quick Agent Assignment**: Look for issues labeled `Agent-Issue` + `status: active-session`

## 🎯 Development Workflow

**Project Hierarchy**: Project → Run → Sprint → Feature → Session

**Current Status**:
- ✅ Sprint 1: Core Menu Bar Timer
- ✅ Sprint 2: Interactive Popover UI  
- ✅ Sprint 2.5: UX Improvements (Theme Toggle)
- 🔄 **Sprint 3: Data Persistence & Notifications** (Active)

**Branch Strategy**:
- `main` - Stable release
- `feature/*` - Feature development branches
- Follow GitHub Issues workflow with status labels

## 🔧 Integration

### VSCode Integration
- **Tasks**: Start/stop sprints from Command Palette
- **Keybindings**: Quick sprint control shortcuts
- **HTTP API**: Programmatic timer control (port 5757)
- **Status Bar Extension**: Live sprint status in VSCode

### AI Assistant Integration  
- **MCP Server**: Expose sprint context to AI assistants
- **Webhook Support**: Notify external coding agents
- **Session Analytics**: AI-powered productivity insights

## 📊 Project Management

- **GitHub Project**: "holu's Coding Agent"
- **Issue Tracking**: Feature-based with sprint milestones
- **Status Labels**: `sprint-backlog` → `active-session` → `testing` → `complete`

## 🤝 Contributing

1. Check sprint documentation in `docs/integration-sprints/`
2. Pick up available features from current sprint backlog
3. Create feature branch: `git checkout -b feature/your-feature`
4. Use SprintBell timer for focused development sessions!
5. Update issue status as you progress

---

**Happy focused coding! 🎯**
