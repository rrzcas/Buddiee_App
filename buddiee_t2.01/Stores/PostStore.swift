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
        // 21 real English names, 21 creative names (authentic and creative)
        let realNames = [
            "Ann Quinn", "Ben Turner", "Clara Evans", "David Smith", "Ella Johnson", "Frank Harris", "Grace Lee", "Henry Clark", "Ivy Lewis", "Jack Walker", "Kate Young", "Liam King", "Mia Scott", "Noah Green", "Olivia Hall", "Paul Wright", "Quinn Baker", "Ruby Adams", "Sam Carter", "Tina Brooks", "Vera Morris"
        ]
        let creativeNames = [
            "RRichardd", "Kmyy", "Zynx", "Blizzter", "Qwopz", "JazzyBee", "Froodle", "Xylo", "Mynx", "Vexx", "Tazzle", "Pixloo", "Wizzle", "Drifty", "Snazz", "Bloopa", "Yozzi", "Krooz", "Fizzik", "Jynx", "Zappy"
        ]
        let users: [(id: String, username: String)] = (0..<42).map { i in
            if i < 21 {
                return (id: "u\(i+1)", username: realNames[i % realNames.count])
            } else {
                return (id: "u\(i+1)", username: creativeNames[(i-21) % creativeNames.count])
            }
        }
        // Authentic captions and comments for each hobby
        let hobbyCaptions: [String: [String]] = [
            "Study": [
                "Looking for a study buddy for finals at the library!",
                "Anyone up for a group revision session?",
                "Let's tackle calculus together this weekend.",
                "Study and coffee at UCL Main Library?",
                "Need motivation for essay writing, join me!",
                "Quiet study session at British Library."
            ],
            "Light Trekking": [
                "Evening walk in Hyde Park, join if you love nature!",
                "Exploring Regent's Park trails, who’s in?",
                "Casual trek and chat this Saturday.",
                "Looking for a walking buddy for Shoreditch route.",
                "Let’s discover new paths in Greenwich Park!",
                "Morning trek at Hampstead Heath."
            ],
            "Photography": [
                "Golden hour shoot at St. Paul's Cathedral.",
                "Looking for a photo walk partner in Soho.",
                "Street photography in Camden Market!",
                "Museum photo day at Tate Modern.",
                "Night shots at London Bridge, anyone?",
                "Portrait session at Covent Garden."
            ],
            "Gym": [
                "Leg day at the gym, need a spotter!",
                "Early morning HIIT session, join me!",
                "Looking for a gym accountability partner.",
                "Strength training at King’s Cross gym.",
                "Cardio and core workout, let’s go!",
                "Trying a new routine, need a buddy."
            ],
            "Day Outing": [
                "Picnic at Battersea Park this Sunday.",
                "Exploring Borough Market for foodies!",
                "Day trip to Science Museum, anyone?",
                "Art and coffee at Victoria & Albert Museum.",
                "Let’s check out Notting Hill together.",
                "Casual outing at Southbank Centre."
            ],
            "Others": [
                "Board games night in Fitzrovia.",
                "Looking for a chess partner in Angel.",
                "Open mic night at Whitechapel!",
                "Book swap at Marylebone station.",
                "Trying new food spots in Vauxhall.",
                "Random adventure, DM if interested!"
            ]
        ]
        let hobbyComments: [String: [String]] = [
            "Study": ["I’m in!", "What subject?", "Let’s ace this!"],
            "Light Trekking": ["Love this park!", "Count me in.", "What time?"],
            "Photography": ["Great spot!", "I have a new lens to try.", "Let’s collab!"],
            "Gym": ["I’ll join!", "What’s your routine?", "Motivation needed!"],
            "Day Outing": ["Sounds fun!", "I love that place.", "Let’s go!"],
            "Others": ["I’m curious!", "Sounds cool.", "I’ll DM you."]
        ]
        let hobbies = ["Study", "Light Trekking", "Photography", "Gym", "Day Outing", "Others"]
        let locations = [
            "British Library", "Senate House Library", "KCL Library", "UCL Main Library", "Regent's Park", "Hyde Park", "Camden Market", "Shoreditch", "Greenwich Park", "10 Westminster Rd, London", "Victoria & Albert Museum", "Tate Modern", "Battersea Park", "London Bridge", "St. Paul's Cathedral", "Soho", "Covent Garden", "King's Cross", "Hampstead Heath", "Notting Hill", "Borough Market", "Leicester Square", "Piccadilly Circus", "Southbank Centre", "Science Museum", "Natural History Museum", "Vauxhall", "Angel", "Holborn", "Russell Square", "Paddington", "Marylebone", "Euston", "Fitzrovia", "Whitechapel", "Bethnal Green", "Hackney"
        ]
        // Hobby-specific, unique, realistic photo sets (no duplicates in a post)
        let hobbyPhotos: [String: [String]] = [
            "Study": [
                "https://images.unsplash.com/photo-1513258496099-48168024aec0?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1464983953574-0892a716854b?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1503676382389-4809596d5290?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1510936111840-6cef99faf2a9?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1515378791036-0648a3ef77b2?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1516979187457-637abb4f9353?w=400&h=300&fit=crop"
            ],
            "Light Trekking": [
                "https://images.unsplash.com/photo-1500534314209-a25ddb2bd429?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1465101178521-c1a9136a3b43?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1502082553048-f009c37129b9?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1465101178521-c1a9136a3b43?w=400&h=300&fit=crop"
            ],
            "Photography": [
                "https://images.unsplash.com/photo-1465101178521-c1a9136a3b43?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519985176271-adb1088fa94c?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?w=400&h=300&fit=crop"
            ],
            "Gym": [
                "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519864600265-abb23847ef2c?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1509228468518-180dd4864904?w=400&h=300&fit=crop"
            ],
            "Day Outing": [
                "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519985176271-adb1088fa94c?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=400&h=300&fit=crop"
            ],
            "Others": [
                "https://images.unsplash.com/photo-1518717758536-85ae29035b6d?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1517816743773-6e0fd518b4a6?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519985176271-adb1088fa94c?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1519125323398-675f0ddb6308?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1465101046530-73398c7f28ca?w=400&h=300&fit=crop",
                "https://images.unsplash.com/photo-1506744038136-46273834b3fb?w=400&h=300&fit=crop"
            ]
        ]
        var posts: [Post] = []
        var userIdx = 0
        var locIdx = 0
        // 6 hobbies × 6 posts each = 36
        for (hobbyIdx, hobby) in hobbies.enumerated() {
            let photosForHobby = hobbyPhotos[hobby] ?? []
            let captions = hobbyCaptions[hobby] ?? []
            let commentsList = hobbyComments[hobby] ?? []
            for i in 0..<6 {
                let user = users[userIdx % users.count]
                let location = locations[(locIdx + i) % locations.count]
                // Each post gets a unique photo for its hobby
                let photo = [photosForHobby[i % photosForHobby.count]]
                let mainCaption = captions[i % captions.count]
                let detailedCaption = "Join me for \(hobby.lowercased()) at \(location)!"
                let comments: [Comment] = (0..<Int.random(in: 1...2)).map { j in
                    let commenter = users[(userIdx + j + 1) % users.count]
                    return Comment(
                        postId: UUID(),
                        userId: commenter.id,
                        username: commenter.username,
                        text: commentsList[j % commentsList.count],
                        createdAt: Date().addingTimeInterval(-Double(j * 600))
                    )
                }
                let post = Post(
                    id: UUID(),
                    userId: user.id,
                    username: user.username,
                    photos: photo,
                    mainCaption: mainCaption,
                    detailedCaption: detailedCaption,
                    subject: hobby,
                    location: location,
                    userLocation: location,
                    createdAt: Date().addingTimeInterval(-3600 * Double(i + hobbyIdx * 6)),
                    likes: Int.random(in: 0...50),
                    comments: comments,
                    isPrivate: false,
                    isPinned: false
                )
                posts.append(post)
                userIdx += 1
                locIdx += 1
            }
        }
        // 6 special posts at specific London locations
        let specialLocations = [
            "British Library",
            "Senate House Library",
            "KCL Library",
            "10 Westminster Rd, London",
            "Victoria & Albert Museum",
            "Tate Modern"
        ]
        let specialPosts: [Post] = (0..<6).map { i in
            let user = users[(36 + i) % users.count]
            let hobby = hobbies[i % hobbies.count]
            let location = specialLocations[i]
            let photo = [hobbyPhotos[hobby]?[i % 6] ?? ""]
            return Post(
                id: UUID(),
                userId: user.id,
                username: user.username,
                photos: photo,
                mainCaption: "Special: \(hobby) at \(location)",
                detailedCaption: "Looking for a buddy for \(hobby.lowercased()) at \(location)!",
                subject: hobby,
                location: location,
                userLocation: location,
                createdAt: Date().addingTimeInterval(-10000 - Double(i * 1000)),
                likes: Int.random(in: 0...20),
                comments: [],
                isPrivate: false,
                isPinned: false
            )
        }
        self.posts = posts + specialPosts
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