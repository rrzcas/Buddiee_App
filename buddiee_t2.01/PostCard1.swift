//
//  PostCard1.swift
//  buddiee_t2.01
//
//  Created by Helen Fung on 07/06/2025.
import SwiftUI

struct PostCard1: View {
    let post: Post
    @EnvironmentObject private var postStore: PostStore
    @State private var showingDetail = false
    @State private var showingComments = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Image(systemName: post.user.profileImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                    .foregroundColor(.gray)
                
                VStack(alignment: .leading) {
                    Text(post.user.username)
                        .font(.headline)
                    Text(post.user.location)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Spacer()
                
                Menu {
                    if post.user.id == postStore.currentUser.id {
                        Button(action: {}) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: {}) {
                            Label("Delete", systemImage: "trash")
                        }
                    } else {
                        Button(action: {}) {
                            Label("Report", systemImage: "exclamationmark.triangle")
                        }
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            // Content
            VStack(alignment: .leading, spacing: 8) {
                Text(post.title)
                    .font(.title3)
                    .fontWeight(.bold)
                
                Text(post.description)
                    .font(.body)
                    .lineLimit(3)
                
                if !post.imageURLs.isEmpty {
                    // Display first image if available
                    if let firstImage = post.imageURLs.first {
                        if let imageUrl = URL(string: firstImage) {
                            AsyncImage(url: imageUrl) { image in
                                image
                                    .resizable()
                                    .scaledToFill()
                            } placeholder: {
                                Color.gray.opacity(0.2)
                            }
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                }
            }
            
            // Footer
            HStack {
                Label(post.isOnline ? "Online" : "In Person", systemImage: post.isOnline ? "video.fill" : "person.fill")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Spacer()
                
                Label("\(post.comments.count)", systemImage: "bubble.right")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .onTapGesture {
                        showingComments = true
                    }
                
                Spacer()
                
                Text(post.createdAt.timeAgoDisplay())
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(radius: 2)
        .onTapGesture {
            showingDetail = true
        }
        .sheet(isPresented: $showingDetail) {
            NavigationView {
                PostDetailView(post: post)
            }
        }
        .sheet(isPresented: $showingComments) {
            NavigationView {
                CommentsView(post: post)
            }
        }
    }
}

// MARK: - Preview
struct PostCard1_Previews: PreviewProvider {
    static var previews: some View {
        PostCard1(post: Post.samplePosts[0])
            .environmentObject(PostStore())
            .padding()
    }
}
