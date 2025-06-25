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
        VStack(alignment: .leading, spacing: 0) {
            // Cover Image
            if let firstImage = post.photos.first, let imageUrl = URL(string: firstImage) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 250)
                            .clipped()
                    case .failure(_):
                        Image(systemName: "photo")
                            .frame(height: 250)
                    default:
                        ProgressView()
                            .frame(height: 250)
                    }
                }
            } else {
                Color.gray.opacity(0.1)
                    .frame(height: 250)
            }
            
            // Content below image
            VStack(alignment: .leading, spacing: 12) {
                // Header: User Info
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 35, height: 35)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text("User") // Placeholder, you can fetch user info later
                            .font(.headline)
                        Text(post.location ?? "Unknown location")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {}) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.primary)
                    }
                }
                
                // Main Caption (Title)
                Text(post.mainCaption)
                    .font(.title3)
                    .fontWeight(.bold)
                
                // Detailed Caption (Description)
                Text(post.detailedCaption ?? "")
                    .font(.body)
                    .lineLimit(2)
                    .foregroundColor(.secondary)

            }.padding()
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
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
        PostCard1(post: Post(
            id: UUID(),
            userId: "userId",
            photos: ["https://images.unsplash.com/photo-1517841905240-472988babdf9?q=80&w=2787&auto=format&fit=crop"],
            mainCaption: "Sample Post",
            detailedCaption: "This is a sample description that shows how the text will look. It can be a bit long but it will be truncated.",
            subject: "study",
            location: "London",
            createdAt: Date(),
            likes: 10,
            comments: []
        ))
        .environmentObject(PostStore())
        .padding()
    }
}
