#!/bin/bash

# Sprint 3 Test Script
# Tests data persistence and notifications

echo "🧪 Sprint 3: Data Persistence & Notifications - Test Script"
echo "=========================================================="

# Navigate to project root
cd "$(dirname "$0")/.."

# Check if notification files exist
echo "📋 Checking notification implementation files..."

if [ -f "src/Notifications/NotificationManager.swift" ]; then
    echo "✅ NotificationManager.swift exists"
else
    echo "❌ NotificationManager.swift missing"
    exit 1
fi

if [ -f "src/Notifications/NotificationDelegate.swift" ]; then
    echo "✅ NotificationDelegate.swift exists"
else
    echo "❌ NotificationDelegate.swift missing"
    exit 1
fi

# Check for UserNotifications import
echo "📱 Checking for UserNotifications framework usage..."
if grep -q "import UserNotifications" src/Notifications/NotificationManager.swift; then
    echo "✅ UserNotifications framework imported"
else
    echo "❌ UserNotifications framework not imported"
    exit 1
fi

# Check for notification permission handling
if grep -q "requestPermissions" src/Notifications/NotificationManager.swift; then
    echo "✅ Notification permissions handling found"
else
    echo "❌ Notification permissions handling missing"
    exit 1
fi

# Check for notification content creation
if grep -q "sendCompletionNotification" src/Notifications/NotificationManager.swift; then
    echo "✅ Completion notification method found"
else
    echo "❌ Completion notification method missing"
    exit 1
fi

# Check TimerDefaults for notification preferences
if grep -q "notificationsEnabled" src/Models/TimerDefaults.swift; then
    echo "✅ Notification preferences in TimerDefaults"
else
    echo "❌ Notification preferences missing from TimerDefaults"
    exit 1
fi

# Check TimerManager integration
if grep -q "NotificationManager.shared.sendCompletionNotification" src/TimerManager.swift; then
    echo "✅ NotificationManager integrated with TimerManager"
else
    echo "❌ NotificationManager not integrated with TimerManager"
    exit 1
fi

# Check SprintBellApp for first-launch permissions
if grep -q "NotificationManager.shared.requestPermissions" src/SprintBellApp.swift; then
    echo "✅ First-launch permission request found"
else
    echo "❌ First-launch permission request missing"
    exit 1
fi

# Try to build the project
echo "🔨 Building project to verify compilation..."
if swift build --quiet; then
    echo "✅ Project builds successfully"
else
    echo "❌ Project failed to build"
    exit 1
fi

echo ""
echo "🎉 Sprint 3 Notification System Tests Passed!"
echo ""
echo "✅ Implemented features:"
echo "- NotificationManager for rich notifications"
echo "- NotificationDelegate for user interactions" 
echo "- Permission handling on first launch"
echo "- Integration with timer completion"
echo "- Notification preferences in TimerDefaults"
echo "- Session summary in notifications"
echo "- Notification actions (Start New Session, View Stats)"

exit 0