import SwiftUI

struct UserIdWrapper: Identifiable, Equatable {
    let id: String
}

struct PostsFeedView: View {
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var userStore: UserStore
    @Binding var justPostedId: UUID?
    @Binding var showPostSuccess: Bool
    @State private var showEngagementPopup = false
    @State private var showFirstPostFlow = false
    enum FeedTab: String, CaseIterable { case main = "Main"; case all = "Explore all hobbies"; case specific = "Explore specific hobbies" }
    @State private var selectedTab: FeedTab = .main
    @State private var specificHobbies: Set<String> = []
    @State private var showHobbyPopup = false
    let selectedHobbies: [String]
    let locationPref: Bool
    let allHobbies = ["Study", "Light Trekking", "Photography", "Gym", "Day Outing", "Others"]
    @State private var selectedPost: Post? = nil
    @State private var selectedUserId: UserIdWrapper? = nil
    @State private var refreshCount = 0
    
    var filteredPosts: [Post] {
        var posts = postStore.posts
        switch selectedTab {
        case .main:
            if !selectedHobbies.isEmpty {
                posts = posts.filter { selectedHobbies.contains($0.subject) }
            }
        case .all:
            posts = posts.sorted { $0.createdAt > $1.createdAt }
        case .specific:
            if !specificHobbies.isEmpty {
                posts = posts.filter { specificHobbies.contains($0.subject) }
            } else {
                posts = []
            }
        }
        // Insert just posted post at top or 2nd position
        if let justPostedId = justPostedId, let idx = posts.firstIndex(where: { $0.id == justPostedId }) {
            let justPosted = posts.remove(at: idx)
            if refreshCount == 0 {
                posts.insert(justPosted, at: 0)
            } else if refreshCount == 1 {
                posts.insert(justPosted, at: min(1, posts.count))
            }
        }
        return posts
    }
    
    // Card height: 1/4.5 of screen height minus paddings
    private var cardHeight: CGFloat {
        UIScreen.main.bounds.height / 4.5 - 16
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Buddiee logo at top (only on feed)
            HStack {
                Spacer()
                Button(action: {
                    // Refresh feed when logo tapped
                    refreshCount += 1
                }) {
                    Text("Buddiee")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .padding(.top, 12)
                }
                Spacer()
            }
            .padding(.bottom, 4)
            .background(Color(.systemBackground))
            .zIndex(2)
            if showPostSuccess {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Posting SUCCEED :)")
                            .font(.system(size: 32, weight: .bold))
                            .foregroundColor(.white)
                            .padding(.vertical, 32)
                            .padding(.horizontal, 48)
                            .background(Color.green)
                            .cornerRadius(32)
                            .shadow(radius: 8)
                        Spacer()
                    }
                    Spacer()
                }
                .background(Color.black.opacity(0.2).ignoresSafeArea())
                .transition(.scale.combined(with: .opacity))
                .zIndex(10)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation { showPostSuccess = false }
                    }
                }
            }
            // Feed filter tabs
            HStack(spacing: 8) {
                ForEach(FeedTab.allCases, id: \ .self) { tab in
                    Button(action: {
                        if tab == .specific {
                            showHobbyPopup = true
                        } else {
                            selectedTab = tab
                        }
                    }) {
                        Text(tab.rawValue)
                            .fontWeight(selectedTab == tab ? .bold : .regular)
                            .foregroundColor(selectedTab == tab ? .white : .blue)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(selectedTab == tab ? Color.blue : Color(.systemGray6))
                            .cornerRadius(18)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
            .background(Color(.systemBackground))
            .zIndex(2)
            .sheet(isPresented: $showHobbyPopup) {
                HobbyMultiSelectPopup(
                    allHobbies: allHobbies,
                    selected: $specificHobbies,
                    onDone: {
                        selectedTab = .specific
                        showHobbyPopup = false
                    },
                    onCancel: {
                        selectedTab = .main
                        showHobbyPopup = false
                    }
                )
            }
            // (No refresh button; only Buddiee logo refreshes)
            // Custom scrollable feed
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(filteredPosts) { post in
                        PostCard(
                            post: post,
                            cardHeight: cardHeight,
                            onUserTap: { userId in selectedUserId = UserIdWrapper(id: userId) },
                            onCardTap: { selectedPost = post }
                        )
                        .frame(height: cardHeight)
                    }
                }
                .padding(.vertical, 8)
            }
            .refreshable {
                refreshCount += 1
            }
        }
        .sheet(isPresented: $showEngagementPopup) {
            EngagementPopup(showPopup: $showEngagementPopup, showFirstPostFlow: $showFirstPostFlow)
        }
        .sheet(isPresented: $showFirstPostFlow) {
            FirstPostCreationFlow()
        }
        .sheet(item: $selectedPost) { post in
            PostDetailView(post: post)
                .environmentObject(postStore)
                .environmentObject(userStore)
                .environmentObject(BrowsingHistoryStore())
        }
        .sheet(item: $selectedUserId) { userIdWrapper in
            let userId = userIdWrapper.id
            // Try to find user by ID, fallback to temp user with username from post
            let username = postStore.posts.first(where: { $0.userId == userId })?.username ?? "Unknown"
            let user = userStore.getUserOrTemp(id: userId, username: username)
            ProfileView(user: user)
                .environmentObject(postStore)
                .environmentObject(userStore)
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

// Popup for multi-select hobbies
struct HobbyMultiSelectPopup: View {
    let allHobbies: [String]
    @Binding var selected: Set<String>
    var onDone: () -> Void
    var onCancel: () -> Void
    var body: some View {
        VStack(spacing: 20) {
            Text("Select hobbies to explore")
                .font(.headline)
            ForEach(allHobbies, id: \ .self) { hobby in
                Button(action: {
                    if selected.contains(hobby) {
                        selected.remove(hobby)
                    } else {
                        selected.insert(hobby)
                    }
                }) {
                    HStack {
                        Text(hobby)
                        Spacer()
                        if selected.contains(hobby) {
                            Image(systemName: "checkmark.circle.fill").foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            HStack {
                Button("Done", action: onDone)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                Button("Cancel", action: onCancel)
                    .padding()
                    .background(Color(.systemGray5))
                    .foregroundColor(.blue)
                    .cornerRadius(12)
            }
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        PostsFeedView(
            justPostedId: .constant(nil),
            showPostSuccess: .constant(false),
            selectedHobbies: ["Study"],
            locationPref: true
        )
        .environmentObject(PostStore())
        .environmentObject(UserStore())
    }
} 