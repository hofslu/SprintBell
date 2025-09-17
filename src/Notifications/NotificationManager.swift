import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    
    private var notificationCenter: UNUserNotificationCenter?
    private var useLegacyFallback = false
    
    private init() {
        // Skip modern notifications entirely for command-line builds
        print("⚠️ Command-line app detected - using legacy notifications only")
        useLegacyFallback = true
        notificationCenter = nil
        
        setupNotificationDelegate()
        setupNotificationCategories()
    }
    
    private func setupModernNotifications() {
        do {
            notificationCenter = UNUserNotificationCenter.current()
            print("✅ Modern NotificationManager initialized")
            
            // Test if it will work without crashing
            Task {
                do {
                    _ = await notificationCenter!.notificationSettings()
                    print("✅ Modern notifications validated")
                } catch {
                    print("⚠️ Modern notifications validation failed, switching to legacy: \(error)")
                    self.notificationCenter = nil
                    self.useLegacyFallback = true
                }
            }
        } catch {
            print("⚠️ Modern notifications failed, using legacy fallback: \(error)")
            notificationCenter = nil
            useLegacyFallback = true
        }
    }
    
    // MARK: - Public Interface
    
    /// Request notification permissions on first launch
    func requestPermissions() async -> Bool {
        if useLegacyFallback {
            return await LegacyNotificationManager.shared.requestPermissions()
        }
        
        guard let notificationCenter = notificationCenter else {
            print("⚠️ Falling back to legacy notifications")
            useLegacyFallback = true
            return await LegacyNotificationManager.shared.requestPermissions()
        }
        
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            
            if granted {
                print("✅ Modern notification permissions granted")
            } else {
                print("❌ Modern notification permissions denied")
            }
            
            return granted
        } catch {
            print("⚠️ Modern notification permission request failed, using legacy: \(error)")
            useLegacyFallback = true
            return await LegacyNotificationManager.shared.requestPermissions()
        }
    }
    
    /// Send notification when timer completes
    func sendCompletionNotification(
        sessionTitle: String,
        actualDuration: Int,
        completedGoals: Int,
        totalGoals: Int
    ) {
        if useLegacyFallback {
            LegacyNotificationManager.shared.sendCompletionNotification(
                sessionTitle: sessionTitle,
                actualDuration: actualDuration,
                completedGoals: completedGoals,
                totalGoals: totalGoals
            )
            return
        }
        
        print("📱 Attempting to send modern local notification...")
        
        Task {
            do {
                let hasPermission = await areNotificationsEnabled()
                guard hasPermission else {
                    print("⚠️ Modern notifications not enabled, using legacy fallback")
                    throw NotificationError.permissionDenied
                }
                
                guard let notificationCenter = notificationCenter else {
                    throw NotificationError.centerUnavailable
                }
                
                let sessionSummary = SessionSummary(
                    title: sessionTitle,
                    actualDuration: actualDuration,
                    plannedDuration: actualDuration,
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
                    trigger: nil // Send immediately as local notification
                )
                
                try await notificationCenter.add(request)
                print("✅ Modern local notification sent for completed session: \(sessionTitle)")
                
            } catch {
                print("⚠️ Modern notification failed, using legacy fallback: \(error)")
                useLegacyFallback = true
                LegacyNotificationManager.shared.sendCompletionNotification(
                    sessionTitle: sessionTitle,
                    actualDuration: actualDuration,
                    completedGoals: completedGoals,
                    totalGoals: totalGoals
                )
            }
        }
    }
    
    /// Check if notifications are enabled
    func areNotificationsEnabled() async -> Bool {
        if useLegacyFallback {
            return await LegacyNotificationManager.shared.areNotificationsEnabled()
        }
        
        guard let notificationCenter = notificationCenter else {
            print("❌ Notification center not available for permission check")
            return false
        }
        
        do {
            let settings = await notificationCenter.notificationSettings()
            let isAuthorized = settings.authorizationStatus == .authorized
            print("📱 Modern notification permission status: \(settings.authorizationStatus.rawValue) (authorized: \(isAuthorized))")
            return isAuthorized
        } catch {
            print("❌ Error checking modern notification settings: \(error)")
            useLegacyFallback = true
            return await LegacyNotificationManager.shared.areNotificationsEnabled()
        }
    }
    
    // MARK: - Private Methods
    
    private func setupNotificationDelegate() {
        if useLegacyFallback {
            print("📱 Using legacy notifications - no delegate needed")
            return
        }
        
        guard let notificationCenter = notificationCenter else {
            print("❌ Cannot setup delegate - notification center not available")
            return
        }
        
        notificationCenter.delegate = NotificationDelegate.shared
        print("✅ Modern notification delegate setup complete")
    }
    
    private func setupNotificationCategories() {
        if useLegacyFallback {
            print("📱 Using legacy notifications - no categories needed")
            return
        }
        
        guard let notificationCenter = notificationCenter else {
            print("❌ Cannot setup categories - notification center not available")
            return
        }
        
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
        print("✅ Modern notification categories setup complete")
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

enum NotificationError: Error {
    case permissionDenied
    case centerUnavailable
}