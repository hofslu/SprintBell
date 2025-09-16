import Foundation

class VSCodeIntegration {
    
    // MARK: - Setup Helper Methods
    
    static func getTasksTemplate() -> String {
        guard let url = Bundle.main.url(forResource: "tasks", withExtension: "json", subdirectory: "Templates"),
              let content = try? String(contentsOf: url) else {
            return generateTasksTemplate()
        }
        return content
    }
    
    static func getKeybindingsTemplate() -> String {
        guard let url = Bundle.main.url(forResource: "keybindings", withExtension: "json", subdirectory: "Templates"),
              let content = try? String(contentsOf: url) else {
            return generateKeybindingsTemplate()
        }
        return content
    }
    
    // MARK: - Template Generation (Fallback)
    
    private static func generateTasksTemplate() -> String {
        return """
{
    "version": "2.0.0",
    "tasks": [
        {
            "label": "SprintBell: Start 25min Focus",
            "type": "shell",
            "command": "open",
            "args": [
                "sprintbell://start?mins=25&title=${workspaceFolderBasename}&goals=focus"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "never",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": false
            },
            "problemMatcher": []
        },
        {
            "label": "SprintBell: Start 50min Deep Work",
            "type": "shell",
            "command": "open",
            "args": [
                "sprintbell://start?mins=50&title=${workspaceFolderBasename}&goals=implementation,testing,documentation"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "never",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": false
            },
            "problemMatcher": []
        },
        {
            "label": "SprintBell: Pause/Resume",
            "type": "shell",
            "command": "open",
            "args": [
                "sprintbell://pause"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "never",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": false
            },
            "problemMatcher": []
        },
        {
            "label": "SprintBell: Stop Sprint",
            "type": "shell",
            "command": "open",
            "args": [
                "sprintbell://stop?result=Complete"
            ],
            "group": "build",
            "presentation": {
                "echo": true,
                "reveal": "never",
                "focus": false,
                "panel": "shared",
                "showReuseMessage": false
            },
            "problemMatcher": []
        }
    ]
}
"""
    }
    
    private static func generateKeybindingsTemplate() -> String {
        return """
[
    {
        "key": "cmd+shift+s",
        "command": "workbench.action.tasks.runTask",
        "args": "SprintBell: Start 25min Focus",
        "when": "!inDebugMode"
    },
    {
        "key": "cmd+shift+d",
        "command": "workbench.action.tasks.runTask",
        "args": "SprintBell: Start 50min Deep Work",
        "when": "!inDebugMode"
    },
    {
        "key": "cmd+shift+p",
        "command": "workbench.action.tasks.runTask",
        "args": "SprintBell: Pause/Resume",
        "when": "!inDebugMode"
    },
    {
        "key": "cmd+shift+x",
        "command": "workbench.action.tasks.runTask",
        "args": "SprintBell: Stop Sprint",
        "when": "!inDebugMode"
    }
]
"""
    }
    
    // MARK: - URL Scheme Helpers
    
    static func createStartURL(minutes: Int, title: String, goals: [String]) -> String {
        var components = URLComponents()
        components.scheme = "sprintbell"
        components.host = "start"
        
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "mins", value: String(minutes)),
            URLQueryItem(name: "title", value: title)
        ]
        
        if !goals.isEmpty {
            queryItems.append(URLQueryItem(name: "goals", value: goals.joined(separator: ",")))
        }
        
        components.queryItems = queryItems
        
        return components.url?.absoluteString ?? "sprintbell://start?mins=\(minutes)&title=\(title)"
    }
    
    static func createPauseURL() -> String {
        return "sprintbell://pause"
    }
    
    static func createStopURL(result: String = "Complete") -> String {
        var components = URLComponents()
        components.scheme = "sprintbell"
        components.host = "stop"
        components.queryItems = [URLQueryItem(name: "result", value: result)]
        
        return components.url?.absoluteString ?? "sprintbell://stop?result=\(result)"
    }
    
    static func createNoteURL(text: String) -> String {
        var components = URLComponents()
        components.scheme = "sprintbell"
        components.host = "note"
        components.queryItems = [URLQueryItem(name: "text", value: text)]
        
        return components.url?.absoluteString ?? "sprintbell://note?text=\(text)"
    }
}