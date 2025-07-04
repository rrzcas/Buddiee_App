import SwiftUI

struct PostsFeedView: View {
    @EnvironmentObject var postStore: PostStore
    @State private var showEngagementPopup = false
    @State private var showFirstPostFlow = false
    @State private var selectedFilter: String = "All"
    @State private var selectedHobby: String? = nil
    let selectedHobbies: [String]
    let locationPref: Bool
    let allHobbies = ["Study", "Light Trekking", "Photography", "Gym", "Day Outing", "Others"]
    var filteredPosts: [Post] {
        // Filtering logic stub: filter by selected hobby, sort by filter
        var posts = postStore.posts
        if let hobby = selectedHobby {
            posts = posts.filter { $0.subject == hobby }
        } else if !selectedHobbies.isEmpty {
            posts = posts.filter { selectedHobbies.contains($0.subject) }
        }
        switch selectedFilter {
        case "Newest":
            posts = posts.sorted { $0.createdAt > $1.createdAt }
        case "Most Liked":
            posts = posts.sorted { $0.likes > $1.likes }
        case "Near Me":
            // Stub: sort by location (not implemented)
            break
        case "New Users":
            // Stub: filter posts from new users (not implemented)
            break
        default:
            // Mix of most liked and recent (top 5 per interest)
            var topPosts: [Post] = []
            for hobby in selectedHobbies {
                let hobbyPosts = posts.filter { $0.subject == hobby }
                let mostLiked = hobbyPosts.sorted { $0.likes > $1.likes }.prefix(3)
                let recent = hobbyPosts.sorted { $0.createdAt > $1.createdAt }.prefix(2)
                topPosts.append(contentsOf: mostLiked)
                topPosts.append(contentsOf: recent)
            }
            // Remove duplicates based on post ID
            var uniquePosts: [Post] = []
            var seenIds: Set<UUID> = []
            for post in topPosts {
                if !seenIds.contains(post.id) {
                    uniquePosts.append(post)
                    seenIds.insert(post.id)
                }
            }
            posts = Array(uniquePosts.prefix(20))
        }
        return posts
    }
    var body: some View {
        VStack {
            // Top bar: show other hobby types
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(allHobbies, id: \.self) { hobby in
                        Button(action: { selectedHobby = hobby }) {
                            Text(hobby)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedHobby == hobby ? Color.blue : Color.gray.opacity(0.2))
                                .foregroundColor(selectedHobby == hobby ? .white : .primary)
                                .cornerRadius(16)
                        }
                    }
                    Button(action: { selectedHobby = nil }) {
                        Text("All")
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedHobby == nil ? Color.blue : Color.gray.opacity(0.2))
                            .foregroundColor(selectedHobby == nil ? .white : .primary)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal)
            }
            // Filter button
            HStack {
                Spacer()
                Menu {
                    Button("Newest", action: { selectedFilter = "Newest" })
                    Button("Most Liked", action: { selectedFilter = "Most Liked" })
                    Button("Near Me", action: { selectedFilter = "Near Me" })
                    Button("New Users", action: { selectedFilter = "New Users" })
                } label: {
                    Label("Filter", systemImage: "line.3.horizontal.decrease.circle")
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.trailing)
            }
            // Posts list
            List(filteredPosts) { post in
                PostCard(post: post)
            }
        }
        .sheet(isPresented: $showEngagementPopup) {
            EngagementPopup(showPopup: $showEngagementPopup, showFirstPostFlow: $showFirstPostFlow)
        }
        .sheet(isPresented: $showFirstPostFlow) {
            FirstPostCreationFlow()
        }
    }
}

struct FilterSheet: View {
    @Binding var selectedFilter: String?
    var selectedHobbies: [String]
    var body: some View {
        VStack(spacing: 24) {
            Text("Filter Posts")
                .font(.headline)
            ForEach(selectedHobbies, id: \.self) { hobby in
                Button(action: { selectedFilter = hobby }) {
                    Text(hobby)
                        .font(.body)
                        .foregroundColor(.primary)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
            }
            Button(action: { selectedFilter = nil }) {
                Text("All Selected Hobbies")
                    .font(.body)
                    .foregroundColor(.blue)
            }
            Divider()
            Button(action: { /* TODO: Newest First logic */ }) {
                Text("Newest First")
            }
            Button(action: { /* TODO: Most Near Me logic */ }) {
                Text("Most Near Me")
            }
            Button(action: { /* TODO: New Users Post! logic */ }) {
                Text("New Users Post!")
            }
            Spacer()
        }
        .padding()
    }
}

struct EngagementPopup: View {
    @Binding var showPopup: Bool
    @Binding var showFirstPostFlow: Bool
    var body: some View {
        VStack(spacing: 24) {
            Text("Creating a post helps you find a buddy more instantly!")
                .font(.title2)
                .multilineTextAlignment(.center)
            Text("Create your own post now?")
                .font(.body)
            HStack(spacing: 24) {
                Button(action: { showPopup = false }) {
                    Text("Later")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                }
                Button(action: {
                    showPopup = false
                    showFirstPostFlow = true
                }) {
                    Text("Create")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(40)
    }
}

#Preview {
    NavigationView {
        PostsFeedView(selectedHobbies: ["Study"], locationPref: true)
            .environmentObject(PostStore())
    }
} 