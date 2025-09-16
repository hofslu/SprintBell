import SwiftUI

struct SprintPopoverView: View {
    @ObservedObject var timerManager: TimerManager
    @ObservedObject var themeManager: ThemeManager
    @ObservedObject private var subGoalsManager = SubGoalsManager.shared
    @State private var newGoalText = ""
    @Environment(\.colorScheme) private var systemColorScheme
    
    // Computed property for current color scheme
    private var currentColorScheme: ColorScheme {
        return themeManager.currentTheme.colorScheme ?? systemColorScheme
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Header with theme toggle
                HStack {
                    Spacer()
                    Button(action: { themeManager.toggleTheme() }) {
                        Image(systemName: themeManager.currentTheme.systemImage)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(currentColorScheme == .dark ? .yellow : .orange)
                            .background(
                                Circle()
                                    .fill(currentColorScheme == .dark ? 
                                          Color.yellow.opacity(0.1) : 
                                          Color.orange.opacity(0.1))
                                    .frame(width: 28, height: 28)
                            )
                    }
                    .buttonStyle(.plain)
                    .help("Theme: \(themeManager.currentTheme.displayName)")
                }
                .padding(.horizontal, 4)
                
                // Large timer display
                TimerDisplayView(timerManager: timerManager, colorScheme: currentColorScheme)
                
                Divider()
                    .background(dividerColor)
                
                // Title editor
                TitleEditorView(timerManager: timerManager)
                
                // Timer controls
                TimerControlsView(timerManager: timerManager, colorScheme: currentColorScheme)
                
                Divider()
                    .background(dividerColor)
                
                // Sub-goals section (scrollable)
                SubGoalsView(subGoalsManager: subGoalsManager, colorScheme: currentColorScheme)
                
                Spacer(minLength: 8)
                
                Divider()
                    .background(dividerColor)
                
                // Preset buttons
                PresetButtonsView(timerManager: timerManager, colorScheme: currentColorScheme)
            }
            .padding(20)
        }
        .frame(width: 320, height: 450)
        .background(backgroundGradient)
        .preferredColorScheme(themeManager.currentTheme.colorScheme) // Use theme manager
    }
    
    private var backgroundGradient: some View {
        LinearGradient(
            colors: currentColorScheme == .dark ? 
                [Color(NSColor.windowBackgroundColor), Color(NSColor.controlBackgroundColor)] :
                [Color(NSColor.controlBackgroundColor), Color(NSColor.windowBackgroundColor)],
            startPoint: .top,
            endPoint: .bottom
        )
    }
    
    private var dividerColor: Color {
        currentColorScheme == .dark ? Color.white.opacity(0.1) : Color.black.opacity(0.1)
    }
}

struct TimerDisplayView: View {
    @ObservedObject var timerManager: TimerManager
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 4) {
            Text(timerManager.formatTime(timerManager.remainingSeconds))
                .font(.system(size: 36, weight: .light, design: .monospaced))
                .foregroundColor(timerDisplayColor)
                .shadow(color: shadowColor, radius: 1, x: 0, y: 1)
            
            Text(timerManager.mainTitle)
                .font(.headline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(timerBackgroundColor)
                .shadow(color: shadowColor, radius: 2, x: 0, y: 1)
        )
    }
    
    private var timerDisplayColor: Color {
        if timerManager.remainingSeconds == 0 {
            return colorScheme == .dark ? .green : .green
        } else if timerManager.isRunning {
            return colorScheme == .dark ? .white : .primary
        } else {
            return .secondary
        }
    }
    
    private var timerBackgroundColor: Color {
        colorScheme == .dark ? 
            Color(NSColor.controlBackgroundColor).opacity(0.8) :
            Color.white.opacity(0.8)
    }
    
    private var shadowColor: Color {
        colorScheme == .dark ? 
            Color.black.opacity(0.3) : 
            Color.black.opacity(0.1)
    }
}

struct TitleEditorView: View {
    @ObservedObject var timerManager: TimerManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Session Title")
                .font(.caption)
                .foregroundColor(.secondary)
            
            TextField("Focus Session", text: $timerManager.mainTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}

struct TimerControlsView: View {
    @ObservedObject var timerManager: TimerManager
    let colorScheme: ColorScheme
    
    var body: some View {
        HStack(spacing: 12) {
            if timerManager.isRunning {
                Button(action: { timerManager.stopTimer() }) {
                    Label("Pause", systemImage: "pause.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorScheme == .dark ? .orange.opacity(0.8) : .orange)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            } else {
                Button(action: { timerManager.startTimer() }) {
                    Label("Start", systemImage: "play.fill")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white)
                }
                .buttonStyle(.borderedProminent)
                .tint(colorScheme == .dark ? .green.opacity(0.8) : .green)
                .shadow(color: .black.opacity(0.2), radius: 2, x: 0, y: 1)
            }
            
            Button(action: { timerManager.resetToOriginal() }) {
                Label("Reset", systemImage: "arrow.clockwise")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.bordered)
            .tint(colorScheme == .dark ? .blue.opacity(0.8) : .blue)
            
            Button(action: { timerManager.startNewSession() }) {
                Label("New", systemImage: "plus.circle")
                    .font(.system(size: 14, weight: .medium))
            }
            .buttonStyle(.bordered)
            .tint(colorScheme == .dark ? .purple.opacity(0.8) : .purple)
        }
    }
}

struct PresetButtonsView: View {
    @ObservedObject var timerManager: TimerManager
    let colorScheme: ColorScheme
    
    var body: some View {
        VStack(spacing: 8) {
            Text("Quick Start")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 8) {
                Button("25 min") {
                    timerManager.startNewSession(duration: 25 * 60, title: "Pomodoro Session", clearSubGoals: false)
                }
                .buttonStyle(.bordered)
                .tint(colorScheme == .dark ? .blue.opacity(0.7) : .blue)
                
                Button("50 min") {
                    timerManager.startNewSession(duration: 50 * 60, title: "Deep Work Session", clearSubGoals: false)
                }
                .buttonStyle(.bordered)
                .tint(colorScheme == .dark ? .purple.opacity(0.7) : .purple)
                
                Button("Custom") {
                    // TODO: Show custom duration picker in future
                    timerManager.startNewSession(duration: 30 * 60, title: "Focus Session", clearSubGoals: false)
                }
                .buttonStyle(.bordered)
                .tint(colorScheme == .dark ? .orange.opacity(0.7) : .orange)
            }
        }
        .padding(.bottom, 8)
    }
}