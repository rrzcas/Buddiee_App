import Foundation

public struct Comment: Identifiable, Codable, Hashable {
    public let id: UUID
    public let postId: UUID
    public let userId: String
    public let username: String
    public let text: String
    public let createdAt: Date
    
    public init(id: UUID = UUID(), postId: UUID, userId: String, username: String, text: String, createdAt: Date = Date()) {
        self.id = id
        self.postId = postId
        self.userId = userId
        self.username = username
        self.text = text
        self.createdAt = createdAt
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Comment, rhs: Comment) -> Bool {
        lhs.id == rhs.id
    }
} 