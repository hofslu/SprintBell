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
        
        // Handle first launch
        let persistence = TimerDefaults.shared
        if persistence.isFirstLaunch {
            print("🆕 Welcome to SprintBell! First launch detected.")
            persistence.isFirstLaunch = false
            
            // Set current app version
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                persistence.appVersion = version
            }
        }
        
        print("🚀 SprintBell launched successfully")
    }
    
    func applicationWillTerminate(_ notification: Notification) {
        // Force save all state before app terminates
        timerManager?.forceSave()
        print("💾 App state saved before termination")
    }
    
    func applicationDidResignActive(_ notification: Notification) {
        // Save state when app loses focus
        timerManager?.forceSave()
    }
}