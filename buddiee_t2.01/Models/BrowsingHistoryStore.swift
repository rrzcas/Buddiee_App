import SwiftUI

@MainActor
public class BrowsingHistoryStore: ObservableObject {
    @Published public var browsingHistory: [Post] = []
    @Published public var isHistoryEnabled = true
    
    public init() {}
    
    public func addToHistory(_ post: Post) {
        guard isHistoryEnabled else { return }
        
        // Remove if already exists to avoid duplicates
        browsingHistory.removeAll { $0.id == post.id }
        
        // Add to beginning of array
        browsingHistory.insert(post, at: 0)
        
        // Keep only last 50 items
        if browsingHistory.count > 50 {
            browsingHistory = Array(browsingHistory.prefix(50))
        }
    }
    
    public func clearHistory() {
        browsingHistory.removeAll()
    }
    
    public func removeFromHistory(_ post: Post) {
        browsingHistory.removeAll { $0.id == post.id }
    }
    
    public func toggleHistory() {
        isHistoryEnabled.toggle()
        if !isHistoryEnabled {
            clearHistory()
        }
    }
} 