import Foundation

struct FilteredPostDebugInfo: Codable {
    let url: String
    let reason: String
    let timestamp: Date
    
    enum CodingKeys: String, CodingKey {
        case url
        case reason
 