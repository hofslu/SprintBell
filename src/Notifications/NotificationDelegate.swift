import Foundation
import UserNotifications
import AppKit

class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    /// Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is active (menu bar app)
        completionHandler([.banner, .sound, .badge])
        print("📱 Notification will be presented while app is active")
    }
    
    /// Handle user interaction with notification
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        defer { completionHandler() }
        
        let actionIdentifier = response.actionIdentifier
        let userInfo = response.notification.request.content.userInfo
        
        print("📱 User tapped notification action: \(actionIdentifier)")
        
        switch actionIdentifier {
        case "START_NEW_SESSION":
            handleStartNewSession(userInfo: userInfo)
            
        case "VIEW_STATS":
            handleViewStats(userInfo: userInfo)
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification body - just bring app to focus
            handleDefaultAction(userInfo: userInfo)
            
        case UNNotificationDismissActionIdentifier:
            // User dismissed the notification
            print("📱 User dismissed notification")
            
        default:
            print("⚠️ Unknown notification action: \(actionIdentifier)")
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleStartNewSession(userInfo: [AnyHashable: Any]) {
        print("🔄 Starting new session from notification")
        
        // Get the previous session info if available
        let previousTitle = userInfo["sessionTitle"] as? String ?? "Focus Session"
        
        // Use the same duration as before, or default
        let persistence = TimerDefaults.shared
        let duration = persistence.defaultDuration
        
        // Access TimerManager through the app delegate
        DispatchQueue.main.async {
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate,
               let timerManager = appDelegate.timerManager {
                
                // Start a new session with similar settings
                timerManager.startNewSession(
                    duration: duration,
                    title: previousTitle,
                    clearSubGoals: true
                )
                
                print("✅ New session started from notification: \(previousTitle)")
            } else {
                print("❌ Could not access TimerManager from notification")
            }
        }
    }
    
    private func handleViewStats(userInfo: [AnyHashable: Any]) {
        print("📊 Viewing stats from notification")
        
        // For now, just bring the app to focus and show the popover
        // In a future version, this could open a dedicated stats view
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            
            // Try to show the status bar popover
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate,
               let statusBarController = appDelegate.statusBarController {
                statusBarController.showPopover()
            }
        }
    }
    
    private func handleDefaultAction(userInfo: [AnyHashable: Any]) {
        print("📱 User tapped notification - bringing app to focus")
        
        // Just activate the app when user taps the notification body
        DispatchQueue.main.async {
            NSApplication.shared.activate(ignoringOtherApps: true)
            
            // Optionally show the popover as well
            if let appDelegate = NSApplication.shared.delegate as? AppDelegate,
               let statusBarController = appDelegate.statusBarController {
                statusBarController.showPopover()
            }
        }
    }
}