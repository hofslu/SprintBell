import Foundation

/// Handles session logging to JSONL format files
class SessionLogger {
    static let shared = SessionLogger()
    private let fileManager = FileManager.default
    private let encoder: JSONEncoder
    
    // MARK: - Configuration
    private let logDirectory: URL
    private let maxFileSize: Int = 10 * 1024 * 1024 // 10MB
    private let maxLogFiles: Int = 5
    
    private init() {
        // Setup JSON encoder with consistent formatting
        encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .sortedKeys
        
        // Setup log directory
        logDirectory = SessionLogger.createLogDirectory()
    }
    
    // MARK: - Public Interface
    
    /// Log a completed session to JSONL file
    func logSession(_ sessionData: SessionData) {
        Task {
            do {
                let jsonData = try encoder.encode(sessionData)
                guard let jsonString = String(data: jsonData, encoding: .utf8) else {
                    logger.error("Failed to convert session data to string")
                    return
                }
                
                try await writeToLogFile(jsonString)
                print("Session logged successfully: \(sessionData.sessionId)")
                
            } catch {
                print("Failed to log session: \(error.localizedDescription)")
            }
        }
    }
    
    /// Get the current log file path for debugging/inspection
    func getCurrentLogFilePath() -> URL {
        return logDirectory.appendingPathComponent(getCurrentLogFileName())
    }
    
    /// Get all existing log files
    func getLogFiles() -> [URL] {
        do {
            let files = try fileManager.contentsOfDirectory(
                at: logDirectory,
                includingPropertiesForKeys: [.creationDateKey],
                options: [.skipsHiddenFiles]
            )
            
            return files
                .filter { $0.pathExtension == "jsonl" }
                .sorted { file1, file2 in
                    let date1 = (try? file1.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    let date2 = (try? file2.resourceValues(forKeys: [.creationDateKey]))?.creationDate ?? Date.distantPast
                    return date1 > date2 // Most recent first
                }
        } catch {
            print("Failed to list log files: \(error.localizedDescription)")
            return []
        }
    }
    
    // MARK: - Private Methods
    
    private func writeToLogFile(_ jsonString: String) async throws {
        let currentLogFile = getCurrentLogFilePath()
        
        // Check if current file exists and its size
        var shouldRotate = false
        if fileManager.fileExists(atPath: currentLogFile.path) {
            let attributes = try fileManager.attributesOfItem(atPath: currentLogFile.path)
            if let fileSize = attributes[.size] as? Int, fileSize >= maxFileSize {
                shouldRotate = true
            }
        }
        
        if shouldRotate {
            try rotateLogFiles()
        }
        
        // Append to current log file
        let logLine = jsonString + "\n"
        let data = logLine.data(using: .utf8)!
        
        if fileManager.fileExists(atPath: currentLogFile.path) {
            // Append to existing file
            let fileHandle = try FileHandle(forWritingTo: currentLogFile)
            defer { fileHandle.closeFile() }
            fileHandle.seekToEndOfFile()
            fileHandle.write(data)
        } else {
            // Create new file
            try data.write(to: currentLogFile)
        }
    }
    
    private func getCurrentLogFileName() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return "sessions-\(formatter.string(from: Date())).jsonl"
    }
    
    private func rotateLogFiles() throws {
        let logFiles = getLogFiles()
        
        // Remove oldest files if we exceed the limit
        if logFiles.count >= maxLogFiles {
            let filesToDelete = logFiles.dropFirst(maxLogFiles - 1)
            for file in filesToDelete {
                try fileManager.removeItem(at: file)
                print("Rotated old log file: \(file.lastPathComponent)")
            }
        }
    }
    
    // MARK: - Static Helpers
    
    private static func createLogDirectory() -> URL {
        let appSupportDir = FileManager.default.urls(
            for: .applicationSupportDirectory,
            in: .userDomainMask
        ).first!
        
        let logDir = appSupportDir
            .appendingPathComponent("SprintBell")
            .appendingPathComponent("SessionLogs")
        
        // Create directory if it doesn't exist
        do {
            try FileManager.default.createDirectory(
                at: logDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
        } catch {
            // Fallback to temporary directory if we can't create in app support
            let tempDir = FileManager.default.temporaryDirectory
                .appendingPathComponent("SprintBell-Sessions")
            
            try? FileManager.default.createDirectory(
                at: tempDir,
                withIntermediateDirectories: true,
                attributes: nil
            )
            
            return tempDir
        }
        
        return logDir
    }
}

// MARK: - Convenience Extensions

extension SessionLogger {
    /// Log a session directly from timer and sub-goals managers
    func logSession(
        title: String,
        plannedDuration: Int,
        actualDuration: Int?,
        startTime: Date,
        endTime: Date?,
        wasCompleted: Bool,
        wasInterrupted: Bool = false,
        subGoalsSummary: (completed: [String], pending: [String])
    ) {
        let sessionData = SessionData(
            title: title,
            plannedDurationSeconds: plannedDuration,
            actualDurationSeconds: actualDuration,
            startTime: startTime,
            endTime: endTime,
            wasCompleted: wasCompleted,
            wasInterrupted: wasInterrupted,
            subGoalsSummary: subGoalsSummary,
            appVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        )
        
        logSession(sessionData)
    }
}