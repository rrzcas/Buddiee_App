import SwiftUI

@MainActor
public class UserStore: ObservableObject {
    @Published public var currentUser: User
    @Published public var users: [User] = []
    @Published public var isAuthenticated = false
    @Published public var errorMessage: String?
    
    public init() {
        // Initialize with a default user
        self.currentUser = User(
            username: "CurrentUser",
            profileImage: "person.fill",
            location: "London",
            bio: "Student"
        )
        self.users = [currentUser]
    }
    
    public func updateUser(_ user: User) {
        currentUser = user
        if let index = users.firstIndex(where: { $0.id == user.id }) {
            users[index] = user
        }
    }
    
    public func updateProfile(username: String, location: String, bio: String) {
        var updatedUser = currentUser
        updatedUser.username = username
        updatedUser.location = location
        updatedUser.bio = bio
        updateUser(updatedUser)
    }
    
    public func updateProfileImage(_ imageName: String) {
        var updatedUser = currentUser
        updatedUser.profileImage = imageName
        updateUser(updatedUser)
    }
} 