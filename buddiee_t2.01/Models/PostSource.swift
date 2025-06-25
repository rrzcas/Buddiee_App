import Foundation

public enum PostSource: String, Codable, CaseIterable {
    case all = "All"
    case reddit = "Reddit"
    case redNote = "RedNote"
    case threads = "Threads"
    case app = "App"
} 