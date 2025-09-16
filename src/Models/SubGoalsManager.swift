import Foundation
import SwiftUI

/// Manages sub-goals with automatic UserDefaults persistence
class SubGoalsManager: ObservableObject {
    @Published var subGoals: [SubGoal] = []
    
    private let persistence = TimerDefaults.shared
    
    init() {
        loadSubGoals()
    }
    
    // MARK: - Sub-Goal Management
    
    func addGoal(_ text: String) {
        let newGoal = SubGoal(text: text.trimmingCharacters(in: .whitespacesAndNewlines))
        subGoals.append(newGoal)
        saveSubGoals()
        print("➕ Added sub-goal: '\(newGoal.text)'")
    }
    
    func toggleGoal(_ goal: SubGoal) {
        if let index = subGoals.firstIndex(where: { $0.id == goal.id }) {
            subGoals[index].isCompleted.toggle()
            saveSubGoals()
            print("✅ Toggled sub-goal: '\(subGoals[index].text)' -> \(subGoals[index].isCompleted ? "completed" : "pending")")
        }
    }
    
    func deleteGoal(_ goal: SubGoal) {
        subGoals.removeAll { $0.id == goal.id }
        saveSubGoals()
        print("🗑️ Deleted sub-goal: '\(goal.text)'")
    }
    
    func clearAllGoals() {
        subGoals.removeAll()
        saveSubGoals()
        print("🗑️ Cleared all sub-goals")
    }
    
    // MARK: - Computed Properties
    
    var completedGoalsCount: Int {
        return subGoals.filter(\.isCompleted).count
    }
    
    var totalGoalsCount: Int {
        return subGoals.count
    }
    
    var progressPercentage: Double {
        guard totalGoalsCount > 0 else { return 0.0 }
        return Double(completedGoalsCount) / Double(totalGoalsCount)
    }
    
    var allGoalsCompleted: Bool {
        return totalGoalsCount > 0 && completedGoalsCount == totalGoalsCount
    }
    
    // MARK: - Persistence Methods
    
    private func saveSubGoals() {
        persistence.saveSubGoals(subGoals)
    }
    
    private func loadSubGoals() {
        subGoals = persistence.loadSubGoals()
        print("🔄 Loaded \(subGoals.count) sub-goals from UserDefaults")
    }
    
    /// Force save current sub-goals (useful for app lifecycle events)
    func forceSave() {
        saveSubGoals()
    }
    
    // MARK: - Session Management
    
    /// Reset all sub-goals for a new session (optionally keep completed ones)
    func resetForNewSession(keepCompleted: Bool = false) {
        if keepCompleted {
            // Only remove uncompleted goals
            subGoals.removeAll { !$0.isCompleted }
        } else {
            // Clear all goals
            subGoals.removeAll()
        }
        saveSubGoals()
        print("🔄 Reset sub-goals for new session (kept completed: \(keepCompleted))")
    }
    
    /// Mark all goals as completed (for bulk operations)
    func markAllCompleted() {
        for index in subGoals.indices {
            subGoals[index].isCompleted = true
        }
        saveSubGoals()
        print("✅ Marked all \(subGoals.count) sub-goals as completed")
    }
    
    /// Get summary for session logging
    func getSessionSummary() -> (completed: [String], pending: [String]) {
        let completed = subGoals.filter(\.isCompleted).map(\.text)
        let pending = subGoals.filter { !$0.isCompleted }.map(\.text)
        return (completed: completed, pending: pending)
    }
}