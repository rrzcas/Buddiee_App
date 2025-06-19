import Foundation

struct Post: Identifiable, Codable, Hashable {
    let id: String
    let title: String
    let description: String  // Changed from selftext to description
    let author: String
    let createdAt: Date
    let originalUrl: String
    let score: Int
    let numComments: Int
    let source: PostSource
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case description = "selftext"  // Map to Reddit's selftext field
        case author
        case createdAt = "created_utc"
        case originalUrl = "url"
        case score
        case numComments = "num_comments"
        case source
    }
    
    // Add Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.id == rhs.id
    }
} 