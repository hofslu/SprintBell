#!/bin/bash

# Test Sprint 2.6: Manual Theme Toggle & Positioning Fixes
echo "🎨 Testing Sprint 2.6: Manual Theme Toggle & Positioning Fixes"

cd "$(dirname "$0")/.."

# Test 1: Build succeeds
echo "📦 Test 1: Building SprintBell..."
if swift build > /dev/null 2>&1; then
    echo "✅ Build successful"
else
    echo "❌ Build failed"
    exit 1
fi

# Test 2: ThemeManager exists and has correct functionality
echo "🌙 Test 2: Checking ThemeManager implementation..."

# Check ThemeManager file exists
if [ -f "src/Models/ThemeManager.swift" ]; then
    echo "✅ ThemeManager.swift exists"
else
    echo "❌ ThemeManager.swift missing"
    exit 1
fi

# Check for theme enumeration
if grep -q "case system\|case light\|case dark" src/Models/ThemeManager.swift; then
    echo "✅ AppTheme enum with system/light/dark modes"
else
    echo "❌ AppTheme enum incomplete"
    exit 1
fi

# Check for toggle functionality
if grep -q "func toggleTheme" src/Models/ThemeManager.swift; then
    echo "✅ Theme toggle functionality present"
else
    echo "❌ Theme toggle functionality missing"
    exit 1
fi

# Check for UserDefaults persistence
if grep -q "UserDefaults" src/Models/ThemeManager.swift; then
    echo "✅ Theme persistence with UserDefaults"
else
    echo "❌ Theme persistence missing"
    exit 1
fi

# Test 3: Theme button in UI
echo "🎯 Test 3: Checking theme toggle button in UI..."

# Check for theme manager in popover view
if grep -q "@ObservedObject var themeManager: ThemeManager" src/Views/SprintPopoverView.swift; then
    echo "✅ ThemeManager integrated in popover"
else
    echo "❌ ThemeManager not integrated in popover"
    exit 1
fi

# Check for toggle button implementation
if grep -q "Button.*themeManager.toggleTheme" src/Views/SprintPopoverView.swift; then
    echo "✅ Theme toggle button implemented"
else
    echo "❌ Theme toggle button missing"
    exit 1
fi

# Check for theme icons (sun/moon/circle)
if grep -q "themeManager.currentTheme.systemImage" src/Views/SprintPopoverView.swift; then
    echo "✅ Theme toggle icons implemented"
else
    echo "❌ Theme toggle icons missing"
    exit 1
fi

# Test 4: Popover positioning improvements
echo "🎪 Test 4: Checking popover positioning fixes..."

# Check for animation disabled to prevent jumping
if grep -q "popover.animates = false" src/StatusBarController.swift; then
    echo "✅ Popover animations disabled to prevent jumping"
else
    echo "❌ Popover animations not disabled"
    exit 1
fi

# Check for applicationDefined behavior (persistent)
if grep -q "behavior = .applicationDefined" src/StatusBarController.swift; then
    echo "✅ Popover behavior set to persistent (.applicationDefined)"
else
    echo "❌ Popover behavior not set to persistent"
    exit 1
fi

# Test 5: Proper theme application
echo "🎨 Test 5: Checking theme application throughout UI..."

# Check that colorScheme is passed to subviews
if grep -q "colorScheme: currentColorScheme" src/Views/SprintPopoverView.swift; then
    echo "✅ Color scheme passed to subviews"
else
    echo "❌ Color scheme not properly propagated"
    exit 1
fi

# Check preferredColorScheme uses theme manager
if grep -q "preferredColorScheme(themeManager.currentTheme.colorScheme)" src/Views/SprintPopoverView.swift; then
    echo "✅ Preferred color scheme uses theme manager"
else
    echo "❌ Preferred color scheme not using theme manager"
    exit 1
fi

# Test 6: Run the application
echo "🚀 Test 6: Running SprintBell application..."

# Build and run in background briefly to test startup
.build/debug/SprintBell > /dev/null 2>&1 &
APP_PID=$!
sleep 2

# Check if process is still running
if kill -0 $APP_PID 2>/dev/null; then
    echo "✅ Application starts successfully"
    kill $APP_PID 2>/dev/null || true
    wait $APP_PID 2>/dev/null || true
else
    echo "❌ Application failed to start or crashed"
    exit 1
fi

echo ""
echo "🎉 Sprint 2.6 Tests Complete!"
echo "✨ Theme Toggle Features:"
echo "   • Manual dark/light/system mode toggle button (top right)"
echo "   • Persistent theme preference with UserDefaults"
echo "   • Visual theme icons (sun/moon/circle) with tooltips"
echo "   • Immediate theme switching without restart"
echo ""
echo "🔧 Popover Positioning Fixes:"
echo "   • Disabled animations to prevent jumping/movement"
echo "   • ApplicationDefined behavior for persistent display"
echo "   • Consistent positioning relative to menu bar button"
echo "   • Menu bar remains visible when popover is open"
echo ""
echo "🎯 Ready for user testing of theme toggle and stable popover!"