import Foundation
import Combine

class PostStore: ObservableObject {
    @Published var posts: [Post] = []
    @Published var userPosts: [Post] = []
    @Published var isLoading: Bool = false
    @Published var isStatusVisible: Bool = false
    @Published var statusMessage: String = ""
    
    init() {
        // Create some sample data for previewing
        self.posts = [
            Post(id: UUID(), userId: "1", photos: ["https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=2787&auto=format&fit=crop"], mainCaption: "Gym buddy, London", detailedCaption: "Looking for a consistent gym partner to go to PureGym with 3-4 times a week. Let's motivate each other!", subject: "Gym", location: "London", createdAt: Date().addingTimeInterval(-86400 * 2), likes: 15, comments: []),
            Post(id: UUID(), userId: "2", photos: ["https://images.unsplash.com/photo-1543269865-cbf427effbad?q=80&w=2940&auto=format&fit=crop"], mainCaption: "UCL Study Group", detailedCaption: "Finals are coming up! Need a few people to review lecture notes and do past papers for ECON001. We can meet at the student center.", subject: "Study", location: "UCL, London", createdAt: Date().addingTimeInterval(-86400 * 1), likes: 8, comments: []),
            Post(id: UUID(), userId: "3", photos: ["https://images.unsplash.com/photo-1519389950473-47ba0277781c?q=80&w=2940&auto=format&fit=crop"], mainCaption: "Hackathon Teammate Wanted", detailedCaption: "I'm a frontend dev looking for a backend dev and a UI/UX designer for the upcoming HackLondon event. Let's build something amazing!", subject: "Coding", location: "Imperial College", createdAt: Date(), likes: 23, comments: []),
            Post(id: UUID(), userId: "4", photos: ["https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=2940&auto=format&fit=crop"], mainCaption: "Music Jam Session", detailedCaption: "Guitarist and vocalist looking for a drummer and a bassist to jam with. I play mostly indie and rock. Have a small studio space we can use.", subject: "Music", location: "Shoreditch", createdAt: Date().addingTimeInterval(-86400 * 5), likes: 30, comments: []),
            Post(id: UUID(), userId: "5", photos: ["https://images.unsplash.com/photo-1542038784-56e98e45935a?q=80&w=2856&auto=format&fit=crop"], mainCaption: "Photography walk", detailedCaption: "Amateur photographer looking for someone to explore and take photos with this weekend. Thinking of going to Greenwich Park.", subject: "Photography", location: "Greenwich", createdAt: Date().addingTimeInterval(-86400 * 3), likes: 12, comments: []),
            Post(id: UUID(), userId: "6", photos: ["https://images.unsplash.com/photo-1498837167922-ddd27525d352?q=80&w=2940&auto=format&fit=crop"], mainCaption: "Vegan recipe exchange", detailedCaption: "Anyone else into vegan cooking? Would love to meet up, share recipes, and maybe cook together. All levels welcome!", subject: "Food", location: "Camden", createdAt: Date().addingTimeInterval(-86400 * 4), likes: 18, comments: [])
        ]
    }
    
    func fetchPosts() {}
    func createPost(_ post: Post) {
        posts.insert(post, at: 0)
    }
    func likePost(_ post: Post) {}
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
} 