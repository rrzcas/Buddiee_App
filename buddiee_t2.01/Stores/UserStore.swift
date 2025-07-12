import Foundation
import Combine
// import buddiee_t2_01App // Removed incorrect import
// If User is in Models, use: import buddiee_t2_01App.Models

class UserStore: ObservableObject {
    @Published var currentUser: User?
    @Published var users: [User] = []

    init() {
        // Add all sample users to users array for profile navigation
        let realNames = [
            "Ann Quinn", "Ben Turner", "Clara Evans", "David Smith", "Ella Johnson", "Frank Harris", "Grace Lee", "Henry Clark", "Ivy Lewis", "Jack Walker", "Kate Young", "Liam King", "Mia Scott", "Noah Green", "Olivia Hall", "Paul Wright", "Quinn Baker", "Ruby Adams", "Sam Carter", "Tina Brooks", "Vera Morris"
        ]
        let creativeNames = [
            "RRichardd", "Kmyy", "Zynx", "Blizzter", "Qwopz", "JazzyBee", "Froodle", "Xylo", "Mynx", "Vexx", "Tazzle", "Pixloo", "Wizzle", "Drifty", "Snazz", "Bloopa", "Yozzi", "Krooz", "Fizzik", "Jynx", "Zappy"
        ]
        let allUsers: [User] = (0..<42).map { i in
            let name = i < 21 ? realNames[i % realNames.count] : creativeNames[(i-21) % creativeNames.count]
            return User(id: "u\(i+1)", username: name, profilePicture: nil, bio: "", location: nil, mainHobbies: nil)
        }
        self.users = allUsers
        currentUser = nil
    }

    // Get user by ID, or create a temporary user if not found
    func getUserOrTemp(id: String, username: String) -> User {
        if let user = users.first(where: { $0.id == id }) {
            return user
        } else {
            return User(id: id, username: username, profilePicture: nil, bio: "", location: nil, mainHobbies: nil)
        }
    }

    func login(username: String, password: String) {}

    func updateProfile(_ user: User) {
        currentUser = user
        // Persist main hobbies if present
        if let mainHobbies = user.mainHobbies {
            UserDefaults.standard.set(mainHobbies.joined(separator: ","), forKey: "mainHobbies")
        }
    }

    func fetchUsers() {}
} 