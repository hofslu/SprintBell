import AppKit
import SwiftUI
import Combine

class StatusBarController: ObservableObject {
    // Main status item for timer display
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    
    // Auxiliary status items for center-alignment trick (using fixed width)
    private let leftSpacerItem = NSStatusBar.system.statusItem(withLength: 100)
    private let rightSpacerItem = NSStatusBar.system.statusItem(withLength: 100)
    
    private var timerManager: TimerManager
    private var themeManager: ThemeManager
    private var cancellables = Set<AnyCancellable>()
    private var popover = NSPopover()
    
    init(timerManager: TimerManager, themeManager: ThemeManager) {
        self.timerManager = timerManager
        self.themeManager = themeManager
        setupStatusItems()
        setupPopover()
        bindToTimerManager()
    }
    
    private func setupStatusItems() {
        // Setup main status item
        guard let button = statusItem.button else { return }
        
        button.title = "SprintBell"
        button.action = #selector(statusItemClicked)
        button.target = self
        
        // Make it look good
        button.font = NSFont.monospacedSystemFont(ofSize: 13, weight: .regular)
        
        // Setup spacer items for center-alignment trick
        setupSpacerItems()
    }
    
    private func setupSpacerItems() {
        // Left spacer - invisible figure spaces to push timer toward center
        leftSpacerItem.button?.title = "\u{2007}\u{2007}\u{2007}\u{2007}\u{2007}" // Figure spaces
        leftSpacerItem.button?.isEnabled = false
        
        // Right spacer - invisible figure spaces to balance the left  
        rightSpacerItem.button?.title = "\u{2007}\u{2007}\u{2007}\u{2007}\u{2007}" // Figure spaces
        rightSpacerItem.button?.isEnabled = false
    }
    
    private func setupPopover() {
        popover.contentSize = NSSize(width: 320, height: 450)
        popover.behavior = .semitransient  // Better behavior - closes when clicking elsewhere but stays when hovering
        popover.animates = false  // Disable animation to prevent jumping
        
        // Create the SwiftUI view for the popover with theme manager
        let popoverView = SprintPopoverView(timerManager: timerManager, themeManager: themeManager)
        popover.contentViewController = NSHostingController(rootView: popoverView)
    }
    
    private func bindToTimerManager() {
        // Listen to timer updates and update the status item display
        timerManager.$displayText
            .receive(on: DispatchQueue.main)
            .sink { [weak self] displayText in
                self?.updateDisplay(displayText)
            }
            .store(in: &cancellables)
    }
    
    private func updateDisplay(_ text: String) {
        DispatchQueue.main.async { [weak self] in
            self?.statusItem.button?.title = text
        }
    }
    
    @objc private func statusItemClicked() {
        guard let button = statusItem.button else { return }
        
        if popover.isShown {
            popover.performClose(nil)
        } else {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
    
    // MARK: - Public Methods
    
    /// Show the popover (for external access, e.g., from notifications)
    func showPopover() {
        guard let button = statusItem.button else { return }
        
        if !popover.isShown {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
        }
    }
}