import Foundation

/// UserDefaults-based persistence layer for SprintBell timer state
class TimerDefaults: ObservableObject {
    
    // MARK: - UserDefaults Keys
    
    private enum Keys: String, CaseIterable {
        case timerRemainingSeconds = "SprintBell.timer.remainingSeconds"
        case timerIsRunning = "SprintBell.timer.isRunning"
        case timerMainTitle = "SprintBell.timer.mainTitle"
        case timerTotalDuration = "SprintBell.timer.totalDuration"
        case timerLastSaved = "SprintBell.timer.lastSaved"
        
        // Sub-goals persistence
        case subGoals = "SprintBell.subGoals"
        
        // User preferences
        case defaultDuration = "SprintBell.preferences.defaultDuration"
        case soundEnabled = "SprintBell.preferences.soundEnabled"
        case lastUsedTitle = "SprintBell.preferences.lastUsedTitle"
        
        // App state
        case firstLaunch = "SprintBell.app.firstLaunch"
        case appVersion = "SprintBell.app.version"
        
        // Notification preferences  
        case notificationsEnabled = "SprintBell.preferences.notificationsEnabled"
        case showNotificationActions = "SprintBell.preferences.showNotificationActions"
    }
    
    // MARK: - Singleton
    
    static let shared = TimerDefaults()
    private let userDefaults = UserDefaults.standard
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    private init() {
        setupISO8601DateFormatting()
    }
    
    private func setupISO8601DateFormatting() {
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Timer State Persistence
    
    /// Save current timer state
    func saveTimerState(
        remainingSeconds: Int,
        isRunning: Bool,
        mainTitle: String,
        totalDuration: Int
    ) {
        userDefaults.set(remainingSeconds, forKey: Keys.timerRemainingSeconds.rawValue)
        userDefaults.set(isRunning, forKey: Keys.timerIsRunning.rawValue)
        userDefaults.set(mainTitle, forKey: Keys.timerMainTitle.rawValue)
        userDefaults.set(totalDuration, forKey: Keys.timerTotalDuration.rawValue)
        userDefaults.set(Date(), forKey: Keys.timerLastSaved.rawValue)
        
        print("✅ Timer state saved: \(remainingSeconds)s, running: \(isRunning), title: '\(mainTitle)'")
    }
    
    /// Load saved timer state
    func loadTimerState() -> (remainingSeconds: Int, isRunning: Bool, mainTitle: String, totalDuration: Int)? {
        // Check if we have saved data
        guard userDefaults.object(forKey: Keys.timerRemainingSeconds.rawValue) != nil else {
            print("ℹ️ No saved timer state found")
            return nil
        }
        
        let remainingSeconds = userDefaults.integer(forKey: Keys.timerRemainingSeconds.rawValue)
        let isRunning = userDefaults.bool(forKey: Keys.timerIsRunning.rawValue)
        let mainTitle = userDefaults.string(forKey: Keys.timerMainTitle.rawValue) ?? "Focus Session"
        let totalDuration = userDefaults.integer(forKey: Keys.timerTotalDuration.rawValue)
        
        // Check how long ago this was saved
        if let lastSaved = userDefaults.object(forKey: Keys.timerLastSaved.rawValue) as? Date {
            let timeSinceLastSave = Date().timeIntervalSince(lastSaved)
            
            // If timer was running and significant time has passed, adjust remaining time
            if isRunning && timeSinceLastSave > 60 { // More than 1 minute
                let adjustedRemaining = max(0, remainingSeconds - Int(timeSinceLastSave))
                print("⏰ Timer was running for \(Int(timeSinceLastSave))s while app was closed")
                print("✅ Timer state loaded: \(adjustedRemaining)s (adjusted), title: '\(mainTitle)'")
                return (adjustedRemaining, false, mainTitle, totalDuration) // Stop running timer after restore
            }
        }
        
        print("✅ Timer state loaded: \(remainingSeconds)s, running: \(isRunning), title: '\(mainTitle)'")
        return (remainingSeconds, false, mainTitle, totalDuration) // Always stop running timer on app launch
    }
    
    /// Clear saved timer state (useful after completion)
    func clearTimerState() {
        userDefaults.removeObject(forKey: Keys.timerRemainingSeconds.rawValue)
        userDefaults.removeObject(forKey: Keys.timerIsRunning.rawValue)
        userDefaults.removeObject(forKey: Keys.timerMainTitle.rawValue)
        userDefaults.removeObject(forKey: Keys.timerTotalDuration.rawValue)
        userDefaults.removeObject(forKey: Keys.timerLastSaved.rawValue)
        print("🗑️ Timer state cleared")
    }
    
    // MARK: - Sub-Goals Persistence
    
    /// Save sub-goals array
    func saveSubGoals(_ subGoals: [SubGoal]) {
        do {
            let data = try encoder.encode(subGoals)
            userDefaults.set(data, forKey: Keys.subGoals.rawValue)
            print("✅ Sub-goals saved: \(subGoals.count) items")
        } catch {
            print("❌ Failed to save sub-goals: \(error)")
        }
    }
    
    /// Load sub-goals array
    func loadSubGoals() -> [SubGoal] {
        guard let data = userDefaults.data(forKey: Keys.subGoals.rawValue) else {
            print("ℹ️ No saved sub-goals found")
            return []
        }
        
        do {
            let subGoals = try decoder.decode([SubGoal].self, from: data)
            print("✅ Sub-goals loaded: \(subGoals.count) items")
            return subGoals
        } catch {
            print("❌ Failed to load sub-goals: \(error)")
            // Return empty array on corruption
            return []
        }
    }
    
    // MARK: - User Preferences
    
    var defaultDuration: Int {
        get {
            let duration = userDefaults.integer(forKey: Keys.defaultDuration.rawValue)
            return duration > 0 ? duration : 1500 // Default to 25 minutes
        }
        set {
            userDefaults.set(newValue, forKey: Keys.defaultDuration.rawValue)
        }
    }
    
    var soundEnabled: Bool {
        get {
            // Default to true if not set
            return userDefaults.object(forKey: Keys.soundEnabled.rawValue) == nil ? true : userDefaults.bool(forKey: Keys.soundEnabled.rawValue)
        }
        set {
            userDefaults.set(newValue, forKey: Keys.soundEnabled.rawValue)
        }
    }
    
    var lastUsedTitle: String {
        get {
            return userDefaults.string(forKey: Keys.lastUsedTitle.rawValue) ?? "Focus Session"
        }
        set {
            userDefaults.set(newValue, forKey: Keys.lastUsedTitle.rawValue)
        }
    }
    
    // MARK: - App State
    
    var isFirstLaunch: Bool {
        get {
            return userDefaults.object(forKey: Keys.firstLaunch.rawValue) == nil
        }
        set {
            if !newValue {
                userDefaults.set(false, forKey: Keys.firstLaunch.rawValue)
            }
        }
    }
    
    var appVersion: String {
        get {
            return userDefaults.string(forKey: Keys.appVersion.rawValue) ?? "1.0.0"
        }
        set {
            userDefaults.set(newValue, forKey: Keys.appVersion.rawValue)
        }
    }
    
    // MARK: - Notification Preferences
    
    var notificationsEnabled: Bool {
        get { 
            // Default to true if not set, let the system handle actual permissions
            return userDefaults.object(forKey: Keys.notificationsEnabled.rawValue) == nil ? true : userDefaults.bool(forKey: Keys.notificationsEnabled.rawValue)
        }
        set { 
            userDefaults.set(newValue, forKey: Keys.notificationsEnabled.rawValue) 
        }
    }
    
    var showNotificationActions: Bool {
        get { 
            // Default to true if not set
            return userDefaults.object(forKey: Keys.showNotificationActions.rawValue) == nil ? true : userDefaults.bool(forKey: Keys.showNotificationActions.rawValue)
        }
        set { 
            userDefaults.set(newValue, forKey: Keys.showNotificationActions.rawValue) 
        }
    }
    
    // MARK: - Utility Methods
    
    /// Reset all SprintBell UserDefaults (for debugging/testing)
    func resetAllData() {
        for key in Keys.allCases {
            userDefaults.removeObject(forKey: key.rawValue)
        }
        print("🗑️ All SprintBell data cleared")
    }
    
    /// Check if UserDefaults contains corrupted data
    func validateData() -> Bool {
        // Test sub-goals decoding
        if userDefaults.data(forKey: Keys.subGoals.rawValue) != nil {
            let _ = loadSubGoals() // This will handle corruption gracefully
        }
        
        // Validate timer state keys exist together or not at all
        let hasTimerData = userDefaults.object(forKey: Keys.timerRemainingSeconds.rawValue) != nil
        let hasTitleData = userDefaults.object(forKey: Keys.timerMainTitle.rawValue) != nil
        
        if hasTimerData != hasTitleData {
            print("⚠️ Inconsistent timer state detected, clearing...")
            clearTimerState()
            return false
        }
        
        return true
    }
}