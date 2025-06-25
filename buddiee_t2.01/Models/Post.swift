import Foundation

public struct Post: Identifiable, Codable {
    public let id: UUID
    public let userId: String
    public let photos: [String] // URLs or local paths
    public let mainCaption: String
    public let detailedCaption: String?
    public let subject: String
    public let location: String?
    public let createdAt: Date
    public let likes: Int
    public var comments: [Comment]
} 