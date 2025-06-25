import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let profilePicture: String?
    let bio: String?
    // Add other properties as needed
} 