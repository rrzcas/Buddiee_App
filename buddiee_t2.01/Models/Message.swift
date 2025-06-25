import Foundation

struct Message: Identifiable, Codable {
    let id: UUID
    let senderId: String
    let receiverId: String
    let text: String
    let imageURL: String?
    let createdAt: Date
    let isRead: Bool
} 