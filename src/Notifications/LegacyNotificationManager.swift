import Foundation
import AppKit

/// Fallback notification manager for command-line/menu bar apps 
/// Uses NSUserNotification (deprecated but functional) and visual alerts
class LegacyNotificationManager {
    static let shared = LegacyNotificationManager()
    
    private init() {
        print("✅ LegacyNotificationManager initialized for command-line app")
    }
    
    // MARK: - Public Interface
    
    /// Request notification permissions (for compatibility)
    func requestPermissions() async -> Bool {
        print("📱 Legacy notifications don't require explicit permissions")
        return true
    }
    
    /// Send notification when timer completes using multiple methods
    func sendCompletionNotification(
        sessionTitle: String,
        actualDuration: Int,
        completedGoals: Int,
        totalGoals: Int
    ) {
        let duration = formatDuration(actualDuration)
        let progressText = totalGoals > 0 
            ? "\(completedGoals)/\(totalGoals) goals completed"
            : "Session completed"
        
        let title = "🎯 Focus Session Complete!"
        let body = "\(sessionTitle) • \(duration) • \(progressText)"
        
        print("📱 Sending notifications via multiple channels:")
        
        // Method 1: NSUserNotification (deprecated but works)
        sendLegacyNotification(title: title, body: body)
        
        // Method 2: System alert dialog  
        DispatchQueue.main.async {
            self.showSystemAlert(title: title, message: body)
        }
        
        // Method 3: Bounce dock icon (if available)
        bounceDockIcon()
        
        // Method 4: Display in console prominently
        displayConsoleNotification(title: title, body: body)
    }
    
    /// Check if notifications are available (always true for legacy)
    func areNotificationsEnabled() async -> Bool {
        return true
    }
    
    // MARK: - Private Methods
    
    private func sendLegacyNotification(title: String, body: String) {
        let notification = NSUserNotification()
        notification.title = title
        notification.informativeText = body
        notification.soundName = NSUserNotificationDefaultSoundName
        
        // Try to deliver the notification
        let center = NSUserNotificationCenter.default
        center.deliver(notification)
        
        print("📱 Legacy NSUserNotification delivered")
    }
    
    private func showSystemAlert(title: String, message: String) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = message
        alert.alertStyle = .informational
        alert.addButton(withTitle: "OK")
        alert.addButton(withTitle: "Start New Session")
        
        let response = alert.runModal()
        
        if response == .alertSecondButtonReturn {
            // User clicked "Start New Session"
            print("📱 User requested new session from notification")
            // TODO: Integrate with app delegate to start new session
        }
        
        print("📱 System alert displayed and dismissed")
    }
    
    private func bounceDockIcon() {
        DispatchQueue.main.async {
            NSApp.requestUserAttention(.informationalRequest)
            print("📱 Dock icon bounced for attention")
        }
    }
    
    private func displayConsoleNotification(title: String, body: String) {
        let border = String(repeating: "=", count: 60)
        print("\n\(border)")
        print("🔔 TIMER COMPLETED!")
        print("\(border)")
        print("📱 \(title)")
        print("📝 \(body)")
        print("⏰ \(Date().formatted(date: .omitted, time: .shortened))")
        print("\(border)\n")
    }
    
    private func formatDuration(_ seconds: Int) -> String {
        let minutes = seconds / 60
        let remainingSeconds = seconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}