import Foundation

struct SubGoal: Identifiable, Codable {
    let id = UUID()
    var text: String
    var isCompleted: Bool = false
    var createdAt: Date = Date()
    
    init(text: String) {
        self.text = text
    }
    
    // Custom CodingKeys to handle the id properly
    enum CodingKeys: String, CodingKey {
        case text, isCompleted, createdAt
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        text = try container.decode(String.self, forKey: .text)
        isCompleted = try container.decode(Bool.self, forKey: .isCompleted)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(text, forKey: .text)
        try container.encode(isCompleted, forKey: .isCompleted)
        try container.encode(createdAt, forKey: .createdAt)
    }
}