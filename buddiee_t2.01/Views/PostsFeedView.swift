import SwiftUI

struct PostsFeedView: View {
    @EnvironmentObject var postStore: PostStore
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(postStore.posts) { post in
                    NavigationLink(destination: PostDetailView(post: post)) {
                        PostCard1(post: post)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Buddiee")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {}) {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {}) {
                    Image(systemName: "magnifyingglass")
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        PostsFeedView()
            .environmentObject(PostStore())
    }
} 