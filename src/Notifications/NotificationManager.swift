import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        setupNotificationDelegate()
        setupNotificationCategories()
    }
    
    // MARK: - Public Interface
    
    /// Request notification permissions on first launch
    func requestPermissions() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            if granted {
                print("✅ Notification permissions granted")
            } else {
                print("❌ Notification permissions denied")
            }
            
            return granted
        } catch {
            print("❌ Error requesting notification permissions: \(error)")
            return false
        }
    }
    
    /// Send notification when timer completes
    func sendCompletionNotification(
        sessionTitle: String,
        actualDuration: Int,
        completedGoals: Int,
        totalGoals: Int
    ) {
        Task {
            let hasPermission = await areNotificationsEnabled()
            guard hasPermission else {
                print("⚠️ Notifications not enabled, skipping notification")
                return
            }
            
            let sessionSummary = SessionSummary(
                title: sessionTitle,
                actualDuration: actualDuration,
                plannedDuration: actualDuration, // We'll use actual as planned for now
                completedGoals: completedGoals,
                totalGoals: totalGoals,
                completionRate: totalGoals > 0 ? Double(completedGoals) / Double(totalGoals) : 0.0
            )
            
            let content = createNotificationContent(
                sessionData: sessionSummary
            )
            
            let request = UNNotificationRequest(
                identifier: "timer-completion-\(UUID().uuidString)",
                content: content,
                trigger: nil // Send immediately
            )
            
            do {
                try await notificationCenter.add(request)
                print("✅ Notification sent for completed session: \(sessionTitle)")
            } catch {
                print("❌ Failed to send notification: \(error)")
            }
        }
    }
    
    /// Check if notifications are enabled
    func areNotificationsEnabled() async -> Bool {
        let settings = await notificationCenter.notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationDelegate() {
        notificationCenter.delegate = NotificationDelegate.shared
    }
    
    private func setupNotificationCategories() {
        let startNewSessionAction = UNNotificationAction(
            identifier: "START_NEW_SESSION",
            title: "Start New Session",
            options: [.foreground]
        )
        
        let viewStatsAction = UNNotificationAction(
            identifier: "VIEW_STATS",
            title: "View Stats", 
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: "TIMER_COMPLETION",
            actions: [startNewSessionAction, viewStatsAction],
            intentIdentifiers: [],
            options: []
        )
        
        notificationCenter.setNotificationCategories([category])
    }
    
    private func createNotificationContent(
        sessionData: SessionSummary
    ) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        // Main title
        content.title = "🎯 Focus Session Complete!"
        
        // Rich body content with session details
        let duration = formatDuration(sessionData.actualDuration)
        let progressText = sessionData.totalGoals > 0 
            ? "\(sessionData.completedGoals)/\(sessionData.totalGoals) goals completed"
            : "Session completed"
        
        content.body = "\(sessionData.title) • \(duration) • \(progressText)"
        
        // Add category for actions
        content.categoryIdentifier = "TIMER_COMPLETION"
        
        // Add sound (if enabled in preferences)
        if TimerDefaults.shared.soundEnabled {
            content.sound = .default
        }
        
        // Badge (optional - could be used to track total sessions)
        content.badge = 1
        
        // User info for handling actions
        content.userInfo = [
            "sessionTitle": sessionData.title,
            "actualDuration": sessionData.actualDuration,
            "completedGoals": sessionData.completedGoals,
            "totalGoals": sessionData.totalGoals
        ]
        
        return content
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}

// MARK: - Supporting Types

struct SessionSummary {
    let title: String
    let actualDuration: Int
    let plannedDuration: Int
    let completedGoals: Int
    let totalGoals: Int
    let completionRate: Double
}