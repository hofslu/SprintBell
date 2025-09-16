# SprintBell Tests

This directory contains test scripts for each sprint of the SprintBell development process.

## Test Structure

Each sprint has its own test script:

- `test-sprint-1.sh` - Core Menu Bar Timer
- `test-sprint-2.sh` - Interactive Popover UI
- `test-sprint-3.sh` - Data Persistence & Notifications
- `test-sprint-4.sh` - VSCode Integration Foundation
- `test-sprint-5.sh` - HTTP API Server
- ... (more sprints)

## Running Tests

### Run All Tests

```bash
./tests/run-all-tests.sh
```

### Run Specific Sprint Test

```bash
./tests/test-sprint-1.sh
```

## Test Philosophy

Each test script:

- ✅ **Verifies sprint completion** - Checks that all sprint objectives are met
- 🧪 **Tests functionality** - Actually runs the code and validates behavior
- 📋 **Documents expectations** - Shows what each sprint should deliver
- 🚦 **Gates progression** - Sprint N+1 should only start after Sprint N passes

## Test Status

- ✅ **Sprint 1** - Core Menu Bar Timer (COMPLETE)
- ⏳ **Sprint 2** - Interactive Popover UI (PENDING)
- ⏳ **Sprint 3** - Data Persistence & Notifications (PENDING)
- ⏳ **Sprint 4** - VSCode Integration Foundation (PENDING)
- ⏳ **Sprint 5** - HTTP API Server (PENDING)
- ... (more sprints pending)

## CI/CD Integration

These tests can be integrated into GitHub Actions or other CI systems:

```yaml
name: Sprint Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v3
      - name: Run Sprint Tests
        run: ./tests/run-all-tests.sh
```
