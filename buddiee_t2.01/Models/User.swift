import Foundation

struct User: Identifiable, Codable {
    let id: String
    let username: String
    let profilePicture: String?
    var bio: String?
    var location: String?
    var mainHobbies: [String]?
    // Add other properties as needed
} 