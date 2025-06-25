import Foundation
import Combine

class BrowsingHistoryStore: ObservableObject {
    @Published var viewedPosts: [Post] = []
    
    func addToHistory(_ post: Post) {
        if !viewedPosts.contains(where: { $0.id == post.id }) {
            viewedPosts.insert(post, at: 0)
        }
    }
    
    func clearHistory() {
        viewedPosts.removeAll()
    }
} 