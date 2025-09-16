import Foundation
import Combine

class TimerManager: ObservableObject {
    @Published var remainingSeconds: Int = 0
    @Published var isRunning: Bool = false
    @Published var mainTitle: String = "Focus Session"
    @Published var displayText: String = "SprintBell"
    
    private var timer: Timer?
    private var totalDuration: Int = 0
    
    init() {
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
        print("Timer started: \(remainingSeconds) seconds remaining")
    }
    
    func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timer = nil
        updateDisplay()
        print("Timer stopped")
    }
    
    func resetTimer(duration: Int, title: String) {
        stopTimer()
        remainingSeconds = duration
        totalDuration = duration
        mainTitle = title
        updateDisplay()
        print("Timer reset: \(duration) seconds, title: \(title)")
    }
    
    // MARK: - Private Methods
    
    private func tick() {
        guard isRunning else { return }
        
        if remainingSeconds > 0 {
            remainingSeconds -= 1
        } else {
            // Timer completed
            timerCompleted()
        }
        
        updateDisplay()
    }
    
    private func timerCompleted() {
        stopTimer()
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
}