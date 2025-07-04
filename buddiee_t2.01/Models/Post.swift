import Foundation

public struct Post: Identifiable, Codable, Hashable {
    public let id: UUID
    public let userId: String
    public let username: String // Add username for display
    public let photos: [String] // URLs or local paths
    public let mainCaption: String
    public let detailedCaption: String?
    public let subject: String
    public let location: String?
    public let userLocation: String? // Specific meeting location
    public let createdAt: Date
    public var likes: Int
    public var comments: [Comment]
    public var isPrivate: Bool // Add privacy setting
    public var isPinned: Bool // Add pinned status
    
    public init(id: UUID = UUID(), userId: String, username: String, photos: [String], mainCaption: String, detailedCaption: String?, subject: String, location: String?, userLocation: String?, createdAt: Date = Date(), likes: Int = 0, comments: [Comment] = [], isPrivate: Bool = false, isPinned: Bool = false) {
        self.id = id
        self.userId = userId
        self.username = username
        self.photos = photos
        self.mainCaption = mainCaption
        self.detailedCaption = detailedCaption
        self.subject = subject
        self.location = location
        self.userLocation = userLocation
        self.createdAt = createdAt
        self.likes = likes
        self.comments = comments
        self.isPrivate = isPrivate
        self.isPinned = isPinned
    }
    
    // MARK: - Hashable
    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    public static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
} 