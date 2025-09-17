import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var mainTitle: String = "Focus Session"
    @Published var displayText: String = "SprintBell"
    @Published var soundEnabled: Bool = true // Add published sound state
    
    private var timer: Timer?
    private var totalDuration: Int = 0
    private let persistence = TimerDefaults.shared
    
    // MARK: - Session Tracking
    private var sessionStartTime: Date?
    private let sessionLogger = SessionLogger.shared
    
    init() {
        // Initialize published sound state from persistence
        soundEnabled = persistence.soundEnabled
        
        restoreTimerState()
        updateDisplay()
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        sessionStartTime = Date() // Track session start
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        updateDisplay()
        saveTimerState()
        print("Timer started: \(remainingSeconds) seconds remaining")
    }
    
    func stopTimer() {
        // Log session if it was running and had a start time
        if isRunning, let startTime = sessionStartTime {
            logSession(startTime: startTime, wasCompleted: false, wasInterrupted: true)
        }
        
        isRunning = false
        timer?.invalidate()
        timer = nil
        sessionStartTime = nil // Clear session tracking
        updateDisplay()
        saveTimerState()
        print("Timer stopped")
    }
    
    func resetTimer(duration: Int, title: String) {
        stopTimer()
        remainingSeconds = duration
        totalDuration = duration
        mainTitle = title
        updateDisplay()
        saveTimerState()
        
        // Save as last used preferences
        persistence.lastUsedTitle = title
        persistence.defaultDuration = duration
        
        print("Timer reset: \(duration) seconds, title: \(title)")
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        guard isRunning else { return }
        
        if remainingSeconds > 0 {
            remainingSeconds -= 1
            
            // Save state every 10 seconds to prevent data loss
            if remainingSeconds % 10 == 0 {
                saveTimerState()
            }
        } else {
            // Timer completed
            timerCompleted()
        }
        
        updateDisplay()
    }
    
    private func timerCompleted() {
        // Log completed session
        if let startTime = sessionStartTime {
            logSession(startTime: startTime, wasCompleted: true, wasInterrupted: false)
            
            // Send completion notification
            let subGoalsSummary = SubGoalsManager.shared.getSessionSummary()
            NotificationManager.shared.sendCompletionNotification(
                sessionTitle: mainTitle,
                actualDuration: Int(Date().timeIntervalSince(startTime)),
                completedGoals: subGoalsSummary.completed.count,
                totalGoals: subGoalsSummary.completed.count + subGoalsSummary.pending.count
            )
        }
        
        // Play completion sound
        print("🔔 Timer completed! Attempting to play sound...")
        AudioManager.shared.playCompletionSound()
        
        stopTimer()
        sessionStartTime = nil // Clear session tracking
        persistence.clearTimerState() // Clear saved state when completed
        print("Timer completed! 🎉")
    }
    
    private func updateDisplay() {
        let timeString = formatTime(remainingSeconds)
        
        if remainingSeconds == 0 && !isRunning {
            displayText = "00:00 • \(mainTitle) ✅"
        } else if isRunning {
            displayText = "\(timeString) • \(mainTitle)"
        } else {
            displayText = "\(timeString) • \(mainTitle) ⏸"
        }
    }
    
    // Public method for formatting time (used by UI)
    func formatTime(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    // MARK: - Persistence Methods
    
    /// Save current timer state to UserDefaults
    private func saveTimerState() {
        persistence.saveTimerState(
            remainingSeconds: remainingSeconds,
            isRunning: isRunning,
            mainTitle: mainTitle,
            totalDuration: totalDuration
        )
    }
    
    /// Restore timer state from UserDefaults on app launch
    private func restoreTimerState() {
        // Validate data integrity first
        _ = persistence.validateData()
        
        // Load saved state
        if let savedState = persistence.loadTimerState() {
            remainingSeconds = savedState.remainingSeconds
            isRunning = savedState.isRunning // This will always be false after restoration
            mainTitle = savedState.mainTitle
            totalDuration = savedState.totalDuration
            
            print("🔄 Timer state restored from UserDefaults")
        } else {
            // No saved state, use preferences
            mainTitle = persistence.lastUsedTitle
            let defaultDuration = persistence.defaultDuration
            remainingSeconds = defaultDuration
            totalDuration = defaultDuration
            
            print("🆕 Using default timer state")
        }
    }
    
    /// Force save current state (useful for app lifecycle events)
    func forceSave() {
        saveTimerState()
    }
    
    /// Get user preferences
    func getDefaultDuration() -> Int {
        return persistence.defaultDuration
    }
    
    func getSoundEnabled() -> Bool {
        return persistence.soundEnabled
    }
    
    func setSoundEnabled(_ enabled: Bool) {
        soundEnabled = enabled // Update published property
        persistence.soundEnabled = enabled // Save to persistence
        print("🔊 Sound enabled changed to: \(enabled)")
    }
    
    // MARK: - Enhanced Reset Methods
    
    /// Reset timer to its original planned duration and title
    func resetToOriginal() {
        remainingSeconds = totalDuration
        updateDisplay()
        saveTimerState()
        print("Timer reset to original: \(totalDuration) seconds")
    }
    
    /// Start a completely new session (resets everything including sub-goals)
    func startNewSession(duration: Int? = nil, title: String? = nil, clearSubGoals: Bool = true) {
        // Log previous session if it was running
        if isRunning, let startTime = sessionStartTime {
            logSession(startTime: startTime, wasCompleted: false, wasInterrupted: true)
        }
        
        stopTimer()
        
        // Use provided values or defaults
        let newDuration = duration ?? persistence.defaultDuration
        let newTitle = title ?? persistence.lastUsedTitle
        
        remainingSeconds = newDuration
        totalDuration = newDuration
        mainTitle = newTitle
        
        // Optionally clear sub-goals for fresh session
        if clearSubGoals {
            SubGoalsManager.shared.clearAllGoals()
        }
        
        updateDisplay()
        saveTimerState()
        
        // Save as last used preferences
        persistence.lastUsedTitle = newTitle
        persistence.defaultDuration = newDuration
        
        print("New session started: \(newDuration) seconds, title: \(newTitle), sub-goals cleared: \(clearSubGoals)")
    }
    
    // MARK: - Session Logging
    
    /// Log a session with current timer and sub-goals state
    private func logSession(startTime: Date, wasCompleted: Bool, wasInterrupted: Bool) {
        let endTime = Date()
        let actualDuration = Int(endTime.timeIntervalSince(startTime))
        
        // Get sub-goals summary from SubGoalsManager
        let subGoalsSummary = SubGoalsManager.shared.getSessionSummary()
        
        sessionLogger.logSession(
            title: mainTitle,
            plannedDuration: totalDuration,
            actualDuration: actualDuration,
            startTime: startTime,
            endTime: endTime,
            wasCompleted: wasCompleted,
            wasInterrupted: wasInterrupted,
            subGoalsSummary: subGoalsSummary
        )
    }
    
    // MARK: - Test Methods
    
    /// Quick test method for sound system - starts a 2-second timer
    func startSoundTest() {
        print("🧪 Starting 2-second sound test...")
        startNewSession(duration: 2, title: "Sound Test", clearSubGoals: true)
        startTimer()
    }
}