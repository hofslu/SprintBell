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
    var urlSchemeHandler: URLSchemeHandler?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Hide dock icon and make app menu bar only
        NSApp.setActivationPolicy(.accessory)
        
        // Initialize managers
        timerManager = TimerManager()
        themeManager = ThemeManager()
        
        // Initialize URL scheme handler
        if let timerManager = timerManager {
            urlSchemeHandler = URLSchemeHandler(timerManager: timerManager)
        }
        
        // Initialize status bar controller
        if let timerManager = timerManager, let themeManager = themeManager {
            statusBarController = StatusBarController(timerManager: timerManager, themeManager: themeManager)
        }
    }
    
    // MARK: - URL Scheme Handling
    
    func application(_ application: NSApplication, open urls: [URL]) {
        for url in urls {
            urlSchemeHandler?.handleURL(url)
        }
    }
}