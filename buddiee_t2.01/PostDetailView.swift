import SwiftUI

struct PostDetailView: View {
    let post: Post
    @EnvironmentObject var historyStore: BrowsingHistoryStore
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) var dismiss
    @State private var newComment: String = ""
    @State private var showingCommentAlert = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Cover Image
                if !post.imageURLs.isEmpty {
                    if let firstImage = post.imageURLs.first {
                        AsyncImage(url: URL(string: firstImage)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                        } placeholder: {
                            Image(systemName: post.category.icon)
                                .resizable()
                                .scaledToFit()
                                .frame(height: 200)
                                .foregroundColor(post.category.color)
                        }
                    }
                } else {
                    Image(systemName: post.category.icon)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 200)
                        .foregroundColor(post.category.color)
                }
                
                VStack(alignment: .leading, spacing: 12) {
                    // Title and Category
                    HStack {
                        Text(post.title)
                            .font(.title2)
                            .bold()
                        
                        Spacer()
                        
                        Label(post.category.rawValue, systemImage: post.category.icon)
                            .foregroundColor(post.category.color)
                    }
                    
                    // User Info
                    NavigationLink(destination: ProfileView(user: post.user)) {
                        HStack {
                            Image(systemName: post.user.profileImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            
                            VStack(alignment: .leading) {
                                Text(post.user.username)
                                    .font(.headline)
                                Text(post.location)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    
                    // Description
                    Text(post.description)
                        .font(.body)
                    
                    // Online/In-person status
                    HStack {
                        Image(systemName: post.isOnline ? "video.fill" : "person.fill")
                        Text(post.isOnline ? "Online" : "In Person")
                    }
                    .foregroundColor(.secondary)
                    
                    // Date
                    Text("Posted \(post.createdAt, style: .relative)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Divider()
                    
                    // Comments Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Comments")
                            .font(.headline)
                        
                        // Comment Input
                        HStack {
                            TextField("Add a comment...", text: $newComment)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                            
                            Button(action: addComment) {
                                Image(systemName: "paperplane.fill")
                                    .foregroundColor(.blue)
                            }
                            .disabled(newComment.isEmpty)
                        }
                        
                        // Comments List
                        ForEach(post.comments) { comment in
                            CommentView(comment: comment)
                        }
                    }
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            historyStore.addToHistory(post)
        }
        .alert("Comment Added", isPresented: $showingCommentAlert) {
            Button("OK", role: .cancel) {}
        }
    }
    
    private func addComment() {
        guard !newComment.isEmpty else { return }
        
        let comment = Comment(
            userId: userStore.currentUser.id,
            username: userStore.currentUser.username,
            content: newComment
        )
        
        postStore.addComment(comment, to: post.id)
        newComment = ""
        showingCommentAlert = true
    }
}

struct CommentView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(comment.username)
                    .font(.subheadline)
                    .bold()
                
                Spacer()
                
                Text(comment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Text(comment.content)
                .font(.body)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    NavigationView {
        PostDetailView(post: Post.samplePosts[0])
            .environmentObject(BrowsingHistoryStore())
            .environmentObject(PostStore())
            .environmentObject(UserStore())
    }
} 