import Foundation
import Combine

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userPosts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var isStatusVisible: Bool = false
    @Published var statusMessage: String = ""
    
    init() {
        createSamplePosts()
    }
    
    private func createSamplePosts() {
        // Sample users
        let users = [
            (id: "1", username: "Alex"),
            (id: "2", username: "Sarah"),
            (id: "3", username: "Mike"),
            (id: "4", username: "Emma"),
            (id: "5", username: "David"),
            (id: "6", username: "Lisa")
        ]
        // Sample photos (Unsplash links)
        let photoSets = [
            ["https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=300&fit=crop"],
            ["https://images.unsplash.com/photo-1522202176988-66273c2fd55f?w=400&h=300&fit=crop"],
            ["https://images.unsplash.com/photo-1461749280684-dccba630e2f6?w=400&h=300&fit=crop"],
            ["https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=400&h=300&fit=crop"],
            ["https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=400&h=300&fit=crop"],
            ["https://images.unsplash.com/photo-1546069901-ba9599a7e63c?w=400&h=300&fit=crop"]
        ]
        // Sample hobbies
        let hobbies = ["Study", "Light Trekking", "Photography", "Gym", "Day Outing", "Others"]
        // Generate 6 posts per hobby
        var samplePosts: [Post] = []
        for (i, hobby) in hobbies.enumerated() {
            for j in 0..<6 {
                let user = users[(i + j) % users.count]
                let photos = photoSets[(i + j) % photoSets.count]
                let postId = UUID()
                let post = Post(
                    id: postId,
                    userId: user.id,
                    username: user.username,
                    photos: photos,
                    mainCaption: "Sample \(hobby) Post #\(j+1)",
                    detailedCaption: "This is a sample description for \(hobby) post #\(j+1).",
                    subject: hobby,
                    location: "Sample Location",
                    userLocation: "Sample Meeting Point",
                    createdAt: Date().addingTimeInterval(-86400 * Double(j)),
                    likes: Int.random(in: 0...50),
                    comments: [
                        Comment(id: UUID(), postId: postId, userId: user.id, username: user.username, text: "Great post!", createdAt: Date()),
                        Comment(id: UUID(), postId: postId, userId: user.id, username: user.username, text: "Looking for a buddy too!", createdAt: Date())
                    ],
                    isPrivate: false,
                    isPinned: false
                )
                samplePosts.append(post)
            }
        }
        self.posts = samplePosts
    }
    
    // MARK: - Post Management Functions
    func fetchPosts() {}
    
    func createPost(_ post: Post) {
        posts.insert(post, at: 0)
        objectWillChange.send()
    }
    
    func likePost(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].likes += 1
        }
    }
    
    func addComment(_ comment: Comment, to post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].comments.append(comment)
        }
    }
    
    func updatePost(_ updatedPost: Post) {
        if let index = posts.firstIndex(where: { $0.id == updatedPost.id }) {
            posts[index] = updatedPost
        }
    }
    
    func deletePost(_ post: Post) {
        posts.removeAll { $0.id == post.id }
    }
    
    func pinPost(_ post: Post) {
        for i in 0..<posts.count {
            if posts[i].userId == post.userId {
                posts[i].isPinned = false
            }
        }
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isPinned = true
        }
    }
    
    func togglePostPrivacy(_ post: Post) {
        if let index = posts.firstIndex(where: { $0.id == post.id }) {
            posts[index].isPrivate.toggle()
        }
    }
    
    func getUserPosts(for userId: String) -> [Post] {
        posts.filter { $0.userId == userId }
    }
    
    func getPublicPosts() -> [Post] {
        posts.filter { !$0.isPrivate }
    }
    
    func getPinnedPost(for userId: String) -> Post? {
        posts.first { $0.userId == userId && $0.isPinned }
    }
    
    func refreshPosts() {
        objectWillChange.send()
    }
    
    func clearAllPosts() {
        posts = []
        userPosts = []
    }
    
    func resetToSamplePosts() {
        createSamplePosts()
        objectWillChange.send()
    }
} 