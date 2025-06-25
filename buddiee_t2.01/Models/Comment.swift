import Foundation

public struct Comment: Identifiable, Codable {
    public let id: UUID
    public let postId: UUID
    public let userId: String
    public let username: String
    public let text: String
    public let createdAt: Date
} 