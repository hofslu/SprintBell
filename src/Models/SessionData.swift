import Foundation

/// Represents a complete session for JSONL logging
struct SessionData: Codable {
    // MARK: - Basic Session Info
    let sessionId: UUID
    let title: String
    let plannedDurationSeconds: Int
    let actualDurationSeconds: Int?
    
    // MARK: - Timestamps
    let startTime: Date
    let endTime: Date?
    let loggedAt: Date
    
    // MARK: - Session Status
    let wasCompleted: Bool
    let wasInterrupted: Bool
    let completionPercentage: Double
    
    // MARK: - Sub-Goals Data
    let totalSubGoals: Int
    let completedSubGoals: Int
    let subGoalCompletionRate: Double
    let completedSubGoalTexts: [String]
    let pendingSubGoalTexts: [String]
    
    // MARK: - Metadata
    let appVersion: String?
    let platform: String
    
    init(
        title: String,
        plannedDurationSeconds: Int,
        actualDurationSeconds: Int?,
        startTime: Date,
        endTime: Date?,
        wasCompleted: Bool,
        wasInterrupted: Bool,
        subGoalsSummary: (completed: [String], pending: [String]),
        appVersion: String? = nil
    ) {
        self.sessionId = UUID()
        self.title = title
        self.plannedDurationSeconds = plannedDurationSeconds
        self.actualDurationSeconds = actualDurationSeconds
        self.startTime = startTime
        self.endTime = endTime
        self.loggedAt = Date()
        self.wasCompleted = wasCompleted
        self.wasInterrupted = wasInterrupted
        
        // Calculate completion percentage
        if let actual = actualDurationSeconds {
            self.completionPercentage = min(1.0, Double(actual) / Double(plannedDurationSeconds))
        } else {
            self.completionPercentage = wasCompleted ? 1.0 : 0.0
        }
        
        // Sub-goals data
        self.completedSubGoalTexts = subGoalsSummary.completed
        self.pendingSubGoalTexts = subGoalsSummary.pending
        self.totalSubGoals = subGoalsSummary.completed.count + subGoalsSummary.pending.count
        self.completedSubGoals = subGoalsSummary.completed.count
        self.subGoalCompletionRate = totalSubGoals > 0 ? 
            Double(completedSubGoals) / Double(totalSubGoals) : 1.0
        
        // Metadata
        self.appVersion = appVersion
        self.platform = "macOS"
    }
}

// MARK: - Session Status Helpers

extension SessionData {
    /// Human-readable session outcome
    var outcome: String {
        if wasCompleted {
            return "completed"
        } else if wasInterrupted {
            return "interrupted"
        } else {
            return "incomplete"
        }
    }
    
    /// Session effectiveness score (0.0 to 1.0)
    var effectivenessScore: Double {
        let durationScore = completionPercentage
        let subGoalScore = subGoalCompletionRate
        return (durationScore + subGoalScore) / 2.0
    }
    
    /// Format duration as human-readable string
    var formattedDuration: String {
        let seconds = actualDurationSeconds ?? 0
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
}