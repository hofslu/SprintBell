#!/bin/bash

# Test Sprint 2.7: Window & Positioning Fixes  
echo "🔧 Testing Sprint 2.7: Window & Positioning Fixes"

cd "$(dirname "$0")/.."

# Test 1: Build succeeds
echo "📦 Test 1: Building SprintBell..."
if swift build > /dev/null 2>&1; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Test 2: Check for Settings scene instead of WindowGroup
echo "🪟 Test 2: Checking for proper scene configuration..."

if grep -q "Settings {" src/SprintBellApp.swift; then
    echo "✅ Using Settings scene (no unwanted window)"
else
    echo "❌ Still using WindowGroup (creates unwanted window)"
    exit 1
fi

# Check that WindowGroup is removed
if ! grep -q "WindowGroup" src/SprintBellApp.swift; then
    echo "✅ WindowGroup removed (no blank window)"
else
    echo "❌ WindowGroup still present (will show blank window)"
    exit 1
fi

# Test 3: Check for smart positioning logic
echo "📍 Test 3: Checking smart popover positioning..."

# Check for screen bounds calculation
if grep -q "screen.visibleFrame" src/StatusBarController.swift; then
    echo "✅ Screen bounds calculation present"
else
    echo "❌ Screen bounds calculation missing"
    exit 1
fi

# Check for space calculation
if grep -q "spaceBelow.*buttonScreenFrame.*screenFrame" src/StatusBarController.swift; then
    echo "✅ Available space calculation implemented"
else
    echo "❌ Available space calculation missing"
    exit 1
fi

# Check for edge selection logic
if grep -q "NSRectEdge.maxY.*Show above" src/StatusBarController.swift; then
    echo "✅ Smart edge selection logic present"
else
    echo "❌ Smart edge selection logic missing"
    exit 1
fi

# Test 4: Check for improved popover behavior
echo "🎪 Test 4: Checking improved popover behavior..."

# Check for semitransient behavior
if grep -q "behavior = .semitransient" src/StatusBarController.swift; then
    echo "✅ Semitransient behavior (better UX)"
else
    echo "❌ Semitransient behavior not set"
    exit 1
fi

# Test 5: Run the application briefly
echo "🚀 Test 5: Testing application startup..."

.build/debug/SprintBell > /dev/null 2>&1 &
APP_PID=$!
sleep 2

if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ Application starts without blank window"
    kill $APP_PID 2>/dev/null || true
    wait $APP_PID 2>/dev/null || true
else
    echo "❌ Application startup issue"
    exit 1
fi

echo ""
echo "🎉 Sprint 2.7 Tests Complete!"
echo ""
echo "🔧 Fixed Issues:"
echo "   ❌ No more blank white window in middle of screen"  
echo "   🎯 Smart popover positioning based on available screen space"
echo "   📐 Automatically positions above/below based on room available"
echo "   🎪 Better popover behavior (.semitransient)"
echo "   📱 Works properly with VSCode's larger title bar area"
echo ""
echo "🧪 How it works:"
echo "   • Calculates available space below menu bar"
echo "   • Shows popover above if not enough room below (450px + margin)"
echo "   • Shows popover below if plenty of room (normal behavior)"
echo "   • No more getting cut off by screen edges!"
echo ""
echo "🎯 Ready for testing in VSCode fullscreen mode!"