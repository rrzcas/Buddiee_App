import Foundation
import SwiftUI

// MARK: - Date Extension
extension Date {
    func timeAgoDisplay() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfMonth], from: self, to: now)
        
        if let day = components.day, day > 0 {
            return day == 1 ? "1 day ago" : "\(day) days ago"
        } else if let hour = components.hour, hour > 0 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        } else if let minute = components.minute, minute > 0 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        } else {
            return "Just now"
        }
    }
}

// MARK: - Comment Model
public struct Comment: Identifiable, Codable {
    public var id = UUID()
    public let userId: String
    public let username: String
    public let content: String
    public let createdAt: Date
    
    public init(
        id: UUID = UUID(),
        userId: String,
        username: String,
        content: String,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.userId = userId
        self.username = username
        self.content = content
        self.createdAt = createdAt
    }
}

// MARK: - Activity Category
public enum ActivityCategory: String, Codable, CaseIterable {
    case study = "study"
    case sports = "sports"
    case music = "music"
    case art = "art"
    case gaming = "gaming"
    case travel = "travel"
    case food = "food"
    case other = "other"
    
    public var icon: String {
        switch self {
        case .study: return "book.fill"
        case .sports: return "sportscourt.fill"
        case .music: return "music.note"
        case .art: return "paintbrush.fill"
        case .gaming: return "gamecontroller.fill"
        case .travel: return "airplane"
        case .food: return "fork.knife"
        case .other: return "ellipsis.circle.fill"
        }
    }
    
    public var color: Color {
        switch self {
        case .study: return .blue
        case .sports: return .green
        case .music: return .purple
        case .art: return .pink
        case .gaming: return .orange
        case .travel: return .cyan
        case .food: return .red
        case .other: return .gray
        }
    }
}

// MARK: - User Model
public struct User: Identifiable, Codable {
    public let id: String
    public var username: String
    public var profileImage: String
    public var location: String
    public var bio: String
    public var interests: [ActivityCategory]?
    
    public init(
        id: String = UUID().uuidString,
        username: String,
        profileImage: String,
        location: String,
        bio: String = "This user has no bio yet",
        interests: [ActivityCategory]? = nil
    ) {
        self.id = id
        self.username = username
        self.profileImage = profileImage
        self.location = location
        self.bio = bio.isEmpty ? "This user has no bio yet" : bio
        self.interests = interests
    }
}

// MARK: - Message Model
public struct Message: Identifiable, Codable {
    public let id: String
    public let senderId: String
    public let receiverId: String
    public let content: String
    public let timestamp: Date
    
    public init(
        id: String = UUID().uuidString,
        senderId: String,
        receiverId: String,
        content: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.senderId = senderId
        self.receiverId = receiverId
        self.content = content
        self.timestamp = timestamp
    }
}

// MARK: - Filtered Post Debug Info
public struct FilteredPostDebugInfo: Identifiable, Codable {
    public var id = UUID() // Client-side ID for SwiftUI ForEach
    public let title: String
    public let reason: String
}

// MARK: - Sample Data
extension User {
    public static let sampleUsers: [User] = [
        User(
            id: "sampleUser1",
            username: "John Doe",
            profileImage: "person.fill",
            location: "London",
            bio: "Computer Science student at UCL. Love coding and problem-solving!",
            interests: nil
        ),
        User(
            id: "sampleUser2",
            username: "Jane Smith",
            profileImage: "person.fill",
            location: "London",
            bio: "Medical student at Imperial. Passionate about healthcare and research.",
            interests: nil
        )
    ]
}

extension Post {
    static var samplePosts: [Post] = [
        Post(
            id: "samplePost1",
            title: "CS Study Buddy for Finals",
            description: "Looking for a study buddy for Computer Science finals. We can meet at the university library or a cafe. Focusing on algorithms and data structures.",
            imageURLs: ["sample_study_1", "sample_study_2"],
            user: .sampleUsers[0],
            category: .study,
            location: "London, UK",
            source: .app,
            isPrivate: false,
            isPinned: false,
            isOnline: false
        )
    ]
} 