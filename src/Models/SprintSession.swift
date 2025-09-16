import Foundation

struct SprintSession: Identifiable {
    let id = UUID()
    var title: String
    var plannedDurationSeconds: Int
    var startTime: Date?
    var endTime: Date?
    var isRunning: Bool = false
    var remainingSeconds: Int
    
    init(title: String, durationSeconds: Int) {
        self.title = title
        self.plannedDurationSeconds = durationSeconds
        self.remainingSeconds = durationSeconds
    }
    
    // MARK: - Computed Properties
    
    var actualDurationSeconds: Int? {
        guard let start = startTime, let end = endTime else { return nil }
        return Int(end.timeIntervalSince(start))
    }
    
    var isCompleted: Bool {
        return endTime != nil && remainingSeconds == 0
    }
    
    var progressPercentage: Double {
        let elapsed = plannedDurationSeconds - remainingSeconds
        return Double(elapsed) / Double(plannedDurationSeconds)
    }
    
    // MARK: - State Management
    
    mutating func start() {
        isRunning = true
        startTime = Date()
    }
    
    mutating func stop() {
        isRunning = false
        endTime = Date()
    }
    
    mutating func reset() {
        isRunning = false
        startTime = nil
        endTime = nil
        remainingSeconds = plannedDurationSeconds
    }
}