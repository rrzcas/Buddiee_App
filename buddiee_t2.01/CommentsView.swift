import SwiftUI

struct CommentsView: View {
    @EnvironmentObject var store: PostStore
    let post: Post
    @State private var newComment: String = ""
    @State private var showingCommentAlert = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Comments header
            Text("Comments")
                .font(.headline)
                .padding(.horizontal)
            
            // Comment input
            HStack {
                TextField("Add a comment...", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding(.horizontal)
                
                Button(action: addComment) {
                    Image(systemName: "paperplane.fill")
                        .foregroundColor(.blue)
                }
                .padding(.trailing)
            }
            
            // Comments list
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 12) {
                    ForEach(post.comments) { comment in
                        CommentRowView(comment: comment)
                    }
                }
                .padding(.horizontal)
            }
        }
        .alert("Comment Added", isPresented: $showingCommentAlert) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private func addComment() {
        guard !newComment.isEmpty else { return }
        
        let comment = Comment(
            id: UUID(),
            userId: store.currentUser.id,
            username: store.currentUser.username,
            content: newComment,
            createdAt: Date()
        )
        
        store.addComment(comment, to: post.id)
        newComment = ""
        showingCommentAlert = true
    }
}

struct CommentRowView: View {
    let comment: Comment
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(comment.username)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Text(comment.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(comment.content)
                .font(.body)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    CommentsView(post: Post(
        title: "Sample Post",
        description: "Sample description",
        imageURLs: ["sample_image_url"],
        user: User.sampleUsers[0],
        category: .study,
        location: "London",
        source: .reddit,
        originalUrl: "",
        createdAt: Date(),
        isOnline: false
    ))
    .environmentObject(PostStore())
} 