import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var mainTitle: String = "Focus Session"
    @Published var displayText: String = "SprintBell"
    
    private var timer: Timer?
    private var totalDuration: Int = 0
    private let persistence = TimerDefaults.shared
    
    init() {
        restoreTimerState()
        updateDisplay()
    }
    
    // MARK: - Timer Control
    
    func startTimer() {
        guard !isRunning else { return }
        
        isRunning = true
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.tick()
        }
        
        updateDisplay()
        saveTimerState()
        print("Timer started: \(remainingSeconds) seconds remaining")
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
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
        stopTimer()
        persistence.clearTimerState() // Clear saved state when completed
        print("Timer completed! 🎉")
        // TODO: In future sprints, we'll add sound and notifications here
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
        persistence.soundEnabled = enabled
    }
}