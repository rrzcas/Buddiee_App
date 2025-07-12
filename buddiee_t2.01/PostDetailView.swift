import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var historyStore: BrowsingHistoryStore
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var newComment: String = ""
    @State private var showingCommentAlert = false
    @State private var showMenu = false
    @State private var selectedUserId: UserIdWrapper? = nil
    @State private var showPushAlert = false
    @State private var showReportAlert = false
    @State private var comments: [Comment] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                coverImageSection
                threeDotMenuSection
                postContentSection
                Divider()
                commentsSection
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            historyStore.addToHistory(post)
            comments = post.comments
        }
        .alert("Comment Added", isPresented: $showingCommentAlert) {
            Button("OK", role: .cancel) {}
        }
        .alert("Post pushed!", isPresented: $showPushAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your post has been pushed to more people!")
        }
        .alert("Report submitted", isPresented: $showReportAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Thank you for reporting. Our team will review this post.")
        }
        .sheet(item: $selectedUserId) { userIdWrapper in
            let userId = userIdWrapper.id
            let username = post.userId == userId ? post.username : "Unknown"
            let user = userStore.getUserOrTemp(id: userId, username: username)
            ProfileView(user: user)
                .environmentObject(postStore)
                .environmentObject(userStore)
        }
    }
    
    private func addComment() {
        let trimmed = newComment.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        let comment = Comment(
            postId: post.id,
            userId: userStore.currentUser?.id ?? "currentUser",
            username: userStore.currentUser?.username ?? "You",
            text: trimmed,
            createdAt: Date()
        )
        comments.append(comment)
        newComment = ""
    }
    
    // Helper for time ago string
    private func timeAgoString(for date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        let hours = Int(interval / 3600)
        let days = Int(interval / 86400)
        if hours < 48 {
            return "Posted \(hours) hours ago"
        } else if days < 5 {
            return "Posted \(days) days ago"
        } else if days < 11 {
            return "Posted \(days) days ago"
        } else {
            return "Posted \(days) days ago"
        }
    }
    
    private var fallbackImageView: some View {
        VStack {
            Image(systemName: "photo")
                .font(.system(size: 50))
                .foregroundColor(.gray)
            Text("No Image")
                .font(.caption)
                .foregroundColor(.gray)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(Color.gray.opacity(0.1))
    }

    private var coverImageSection: some View {
        Group {
            if !post.photos.isEmpty {
                TabView {
                    ForEach(post.photos, id: \.self) { photo in
                        if photo.hasPrefix("file://"), let uiImage = ImageStorage.loadImage(from: photo) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(height: 300)
                                .clipped()
                        } else if let url = URL(string: photo) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .empty:
                                    ProgressView().frame(height: 300)
                                case .success(let image):
                                    image.resizable().scaledToFill().frame(height: 300).clipped()
                                case .failure:
                                    Image(systemName: "photo").resizable().scaledToFit().frame(height: 300).foregroundColor(.gray)
                                @unknown default:
                                    EmptyView()
                                }
                            }
                        } else {
                            Image(systemName: "photo").resizable().scaledToFit().frame(height: 300).foregroundColor(.gray)
                        }
                    }
                }
                .frame(height: 300)
                .tabViewStyle(PageTabViewStyle())
            } else {
                fallbackImageView
            }
        }
    }

    private var threeDotMenuSection: some View {
        HStack {
            Spacer()
            Menu {
                Button("Push Post") {
                    showPushAlert = true
                }
                Button("Report") {
                    showReportAlert = true
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.title2)
                    .foregroundColor(.gray)
            }
        }
    }

    private var postContentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(post.mainCaption)
                .font(.title)
                .bold()
            HStack {
                Image(systemName: "person.circle.fill")
                Button(action: { selectedUserId = UserIdWrapper(id: post.userId) }) {
                    Text(post.username)
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(post.createdAt, style: .relative)
            }
            .font(.subheadline)
            .foregroundColor(.secondary)
            Text(post.detailedCaption ?? "")
                .font(.body)
            if let location = post.location {
                Label(location, systemImage: "mappin.and.ellipse")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.bottom, 8)
    }

    private var commentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Comments")
                .font(.headline)
            if comments.isEmpty {
                Text("No comments yet.")
                    .foregroundColor(.gray)
            } else {
                ForEach(comments) { comment in
                    HStack(alignment: .top, spacing: 8) {
                        Button(action: { selectedUserId = UserIdWrapper(id: comment.userId) }) {
                            Text(comment.username)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        VStack(alignment: .leading, spacing: 2) {
                            Text(comment.text)
                                .font(.body)
                            Text(timeAgoString(for: comment.createdAt))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            HStack {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Post") {
                    addComment()
                }
                .disabled(newComment.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
        .padding(.top)
    }
}

struct CommentView: View {
    let comment: Comment
    var onUserTap: ((String) -> Void)? = nil
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Button(action: { onUserTap?(comment.userId) }) {
                    Text(comment.username)
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.blue)
                }
                Spacer()
                Text(comment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            Text(comment.text)
                .font(.body)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        PostDetailView(post: Post(
            id: UUID(),
            userId: "userId",
            username: "Sample User",
            photos: [],
            mainCaption: "Sample Post",
            detailedCaption: "Sample description",
            subject: "study",
            location: "London",
            userLocation: nil,
            createdAt: Date(),
            likes: 0,
            comments: []
        ))
            .environmentObject(BrowsingHistoryStore())
            .environmentObject(PostStore())
            .environmentObject(UserStore())
    }
} 