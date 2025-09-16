import Foundation
import Combine

class URLSchemeHandler: ObservableObject {
    private weak var timerManager: TimerManager?
    
    init(timerManager: TimerManager) {
        self.timerManager = timerManager
    }
    
    // MARK: - URL Handling
    
    func handleURL(_ url: URL) {
        guard url.scheme == "sprintbell" else { 
            print("Invalid URL scheme: \(url.scheme ?? "nil")")
            return 
        }
        
        guard let host = url.host else {
            print("Invalid URL - no host specified: \(url)")
            return
        }
        
        print("Handling URL: \(url)")
        
        switch host {
        case "start":
            handleStartCommand(url)
        case "pause":
            handlePauseCommand()
        case "stop":
            handleStopCommand(url)
        case "note":
            handleNoteCommand(url)
        default:
            print("Unknown command: \(host)")
        }
    }
    
    // MARK: - Command Handlers
    
    private func handleStartCommand(_ url: URL) {
        guard let timerManager = timerManager else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        // Parse parameters
        let minutes = queryItems.first(where: { $0.name == "mins" })?.value.flatMap(Int.init) ?? 25
        let title = queryItems.first(where: { $0.name == "title" })?.value?.removingPercentEncoding ?? "Focus Session"
        let goalsString = queryItems.first(where: { $0.name == "goals" })?.value?.removingPercentEncoding ?? ""
        
        // Parse goals (comma-separated)
        let goals = goalsString.isEmpty ? [] : goalsString.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
        
        let durationSeconds = minutes * 60
        
        print("Starting sprint: \(title) for \(minutes) minutes")
        if !goals.isEmpty {
            print("Goals: \(goals.joined(separator: ", "))")
        }
        
        // Reset and start timer
        timerManager.resetTimer(duration: durationSeconds, title: title)
        timerManager.startTimer()
    }
    
    private func handlePauseCommand() {
        guard let timerManager = timerManager else { return }
        
        if timerManager.isRunning {
            timerManager.stopTimer() // This acts as pause since it preserves state
            print("Sprint paused")
        } else {
            timerManager.startTimer() // Resume
            print("Sprint resumed")
        }
    }
    
    private func handleStopCommand(_ url: URL) {
        guard let timerManager = timerManager else { return }
        
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        let result = queryItems.first(where: { $0.name == "result" })?.value?.removingPercentEncoding ?? "Stopped"
        
        print("Stopping sprint with result: \(result)")
        
        // Stop and reset timer
        timerManager.stopTimer()
        timerManager.resetTimer(duration: 0, title: "SprintBell")
    }
    
    private func handleNoteCommand(_ url: URL) {
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let queryItems = components?.queryItems ?? []
        
        let noteText = queryItems.first(where: { $0.name == "text" })?.value?.removingPercentEncoding ?? ""
        
        if !noteText.isEmpty {
            print("Adding note: \(noteText)")
            // TODO: In future sprints, we'll integrate this with session persistence
            // For now, just log the note
        } else {
            print("Note command received but no text provided")
        }
    }
}