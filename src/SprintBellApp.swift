import SwiftUI

@main
struct SprintBellApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var themeManager = ThemeManager()
    
    var body: some Scene {
        // Empty scene - we only use menu bar, no windows
        Settings {
            EmptyView()
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var statusBarController: StatusBarController?
    var timerManager: TimerManager?
    var themeManager: ThemeManager?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and make app menu bar only
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize managers
        timerManager = TimerManager()
        themeManager = ThemeManager()
        
        // Initialize status bar controller
        if let timerManager = timerManager, let themeManager = themeManager {
            statusBarController = StatusBarController(timerManager: timerManager, themeManager: themeManager)
        }
    }
}