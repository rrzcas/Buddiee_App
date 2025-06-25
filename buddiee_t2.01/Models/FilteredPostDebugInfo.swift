import Foundation

public struct FilteredPostDebugInfo: Codable {
    public let url: String
    public let reason: String
    public let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case url
        case reason
        case timestamp
    }
}
 