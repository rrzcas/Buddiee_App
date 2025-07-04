import Foundation
import Combine
// import buddiee_t2_01App // Removed incorrect import
// If User is in Models, use: import buddiee_t2_01App.Models

class UserStore: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []
    
    init() {
        // Set up a default current user for testing
        // currentUser = User(
        //     id: "currentUserId",
        //     username: "TestUser",
        //     profilePicture: nil,
        //     bio: "Test bio"
        // )
        currentUser = nil
    }
    
    func login(username: String, password: String) {}
    func updateProfile(_ user: User) {
        currentUser = user
    }
    func fetchUsers() {}
} 