import Foundation
import SwiftUI

@MainActor
class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var statusMessage: String = ""
    @Published var isStatusVisible: Bool = false
    
    private let scraperService = PostScraperService()
    
    init() {
        // Initialize with empty state
    }
    
    func updatePosts() async {
        isLoading = true
        statusMessage = "Fetching posts..."
        isStatusVisible = true
        errorMessage = nil
        
        do {
            let (fetchedPosts, _) = try await scraperService.fetchPostsFromBackend()
            posts = fetchedPosts
            statusMessage = "Successfully loaded \(fetchedPosts.count) posts"
        } catch {
            errorMessage = error.localizedDescription
            statusMessage = "Failed to load posts"
        }
        
        isLoading = false
        // Hide status message after 3 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.isStatusVisible = false
        }
    }
} 