import Foundation

public class PostScraperService {
    // MARK: - Properties
    // The base URL for your Python backend API
    private let backendBaseURL = "http://localhost:8000"
    private let timeoutInterval: TimeInterval = 5.0 // 5 second timeout

    // MARK: - Initialization
    public init() {}

    // MARK: - Public Methods
    public func fetchPostsFromBackend() async throws -> (posts: [Post], filteredDebugInfo: [FilteredPostDebugInfo]) {
        print("PostScraperService: Fetching posts from backend...")

        guard let url = URL(string: "\(backendBaseURL)/posts") else {
            print("PostScraperService: Invalid backend URL.")
            throw ScraperError.invalidURL
        }
        print("PostScraperService: Constructed URL: \(url)")

        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval

        do {
            print("PostScraperService: Sending network request...")
            let (data, response) = try await URLSession.shared.data(for: request)
            print("PostScraperService: Received network response.")

            if let httpResponse = response as? HTTPURLResponse {
                print("PostScraperService: Backend HTTP Status Code: \(httpResponse.statusCode)")
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("PostScraperService: Backend returned error status code: \(httpResponse.statusCode), message: \(errorMessage)")
                    throw ScraperError.backendError(statusCode: httpResponse.statusCode, message: errorMessage)
                }
            }

            print("PostScraperService: Received data from backend, size: \(data.count) bytes")
            print("PostScraperService: Attempting to decode JSON data...")

            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let backendResponse = try decoder.decode(BackendResponse.self, from: data)
            print("PostScraperService: JSON decoding successful.")

            print("PostScraperService: Successfully decoded \(backendResponse.success_posts.count) posts and \(backendResponse.filtered_debug_info.count) filtered debug entries from backend.")
            return (posts: backendResponse.success_posts, filteredDebugInfo: backendResponse.filtered_debug_info)
        } catch {
            print("PostScraperService: Error fetching or decoding posts from backend: \(error.localizedDescription)")
            throw ScraperError.backendError(statusCode: 0, message: error.localizedDescription)
        }
    }

    // MARK: - Error Handling
    enum ScraperError: Error, LocalizedError {
        case invalidURL
        case backendError(statusCode: Int, message: String)
        case decodingError(Error)

        var errorDescription: String? {
            switch self {
            case .invalidURL:
                return "The backend URL is invalid."
            case .backendError(let statusCode, let message):
                return "Backend error (Status Code: \(statusCode)): \(message)"
            case .decodingError(let error):
                return "Error decoding data from backend: \(error.localizedDescription)"
            }
        }
    }
}

// MARK: - Post Model
extension Post: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(originalUrl) // Use URL as unique identifier
    }
    
    public static func == (lhs: Post, rhs: Post) -> Bool {
        lhs.originalUrl == rhs.originalUrl
    }
}

// MARK: - Reddit API Response Models
private struct RedditResponse: Codable {
    let data: RedditListing
}

private struct RedditListing: Codable {
    let children: [RedditPostWrapper]
}

private struct RedditPostWrapper: Codable {
    let data: RedditPost
}

private struct RedditPost: Codable {
    let title: String
    let selftext: String
    let author: String
    let createdUtc: Int
    let permalink: String
    let url: String
    let isSelf: Bool
    let score: Int
    let numComments: Int
}

// MARK: - Backend Response Model
private struct BackendResponse: Codable {
    let success_posts: [Post]
    let filtered_debug_info: [FilteredPostDebugInfo]
} 