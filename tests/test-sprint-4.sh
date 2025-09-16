#!/bin/bash

# Sprint 4 Test Script
# Tests VSCode integration foundation

echo "🧪 Sprint 4: VSCode Integration Foundation - Test Script"
echo "======================================================="

# Navigate to project root
cd "$(dirname "$0")/.."

# Test 1: Check URL scheme registration in Info.plist
echo "📋 Test 1: URL scheme registration in Info.plist"
if grep -q "sprintbell" src/Info.plist; then
    echo "✅ sprintbell URL scheme found in Info.plist"
else
    echo "❌ sprintbell URL scheme missing from Info.plist"
    exit 1
fi

if grep -q "CFBundleURLTypes" src/Info.plist; then
    echo "✅ CFBundleURLTypes registration found"
else
    echo "❌ CFBundleURLTypes registration missing"
    exit 1
fi

# Test 2: Check URLSchemeHandler implementation
echo ""
echo "📋 Test 2: URLSchemeHandler implementation"
if [ -f "src/Integration/URLSchemeHandler.swift" ]; then
    echo "✅ URLSchemeHandler.swift exists"
    
    # Check for key methods
    if grep -q "handleURL.*URL" src/Integration/URLSchemeHandler.swift; then
        echo "✅ handleURL method found"
    else
        echo "❌ handleURL method missing"
        exit 1
    fi
    
    if grep -q "handleStartCommand" src/Integration/URLSchemeHandler.swift; then
        echo "✅ handleStartCommand method found"
    else
        echo "❌ handleStartCommand method missing"
        exit 1
    fi
    
    if grep -q "handlePauseCommand" src/Integration/URLSchemeHandler.swift; then
        echo "✅ handlePauseCommand method found"
    else
        echo "❌ handlePauseCommand method missing"
        exit 1
    fi
    
else
    echo "❌ URLSchemeHandler.swift missing"
    exit 1
fi

# Test 3: Check App integration
echo ""
echo "📋 Test 3: AppDelegate URL scheme integration"
if grep -q "URLSchemeHandler" src/SprintBellApp.swift; then
    echo "✅ URLSchemeHandler integration found in AppDelegate"
else
    echo "❌ URLSchemeHandler integration missing from AppDelegate"
    exit 1
fi

if grep -q "application.*open urls" src/SprintBellApp.swift; then
    echo "✅ URL handling method found in AppDelegate"
else
    echo "❌ URL handling method missing from AppDelegate"
    exit 1
fi

# Test 4: Check VSCode templates
echo ""
echo "📋 Test 4: VSCode templates"
if [ -f "src/Templates/tasks.json" ]; then
    echo "✅ tasks.json template exists"
    
    if grep -q "sprintbell://start" src/Templates/tasks.json; then
        echo "✅ Start task with URL scheme found"
    else
        echo "❌ Start task with URL scheme missing"
        exit 1
    fi
    
else
    echo "❌ tasks.json template missing"
    exit 1
fi

if [ -f "src/Templates/keybindings.json" ]; then
    echo "✅ keybindings.json template exists"
    
    if grep -q "cmd+shift+s" src/Templates/keybindings.json; then
        echo "✅ Keybinding for start sprint found"
    else
        echo "❌ Keybinding for start sprint missing"
        exit 1
    fi
    
else
    echo "❌ keybindings.json template missing"
    exit 1
fi

# Test 5: Check VSCodeIntegration helper
echo ""
echo "📋 Test 5: VSCodeIntegration helper class"
if [ -f "src/Integration/VSCodeIntegration.swift" ]; then
    echo "✅ VSCodeIntegration.swift exists"
    
    if grep -q "createStartURL" src/Integration/VSCodeIntegration.swift; then
        echo "✅ URL creation helpers found"
    else
        echo "❌ URL creation helpers missing"
        exit 1
    fi
    
else
    echo "❌ VSCodeIntegration.swift missing"
    exit 1
fi

echo ""
echo "🎉 Sprint 4 Tests Completed Successfully!"
echo "✅ All URL scheme integration components are in place"
echo ""
echo "📝 Next Steps:"
echo "1. Build and test the app in Xcode"
echo "2. Test URL schemes manually:"
echo "   open 'sprintbell://start?mins=25&title=Test&goals=focus'"
echo "3. Set up VSCode workspace with templates"
echo "4. Validate end-to-end workflow"
echo ""
echo "🚀 Foundation ready for Sprint 5 (HTTP API) and Sprint 6 (Advanced VSCode Integration)"