import SwiftUI

struct PostCard: View {
    let post: Post
    @State private var currentImageIndex = 0 // For image carousel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Image Carousel (if images exist)
            if !post.imageURLs.isEmpty {
                TabView(selection: $currentImageIndex) {
                    ForEach(0..<post.imageURLs.count, id: \.self) {
                        index in
                        if let url = URL(string: post.imageURLs[index]) {
                            AsyncImage(url: url) {
                                phase in
                                switch phase {
                                case .empty:
                                    ProgressView()
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                        .background(Color.gray.opacity(0.1))
                                case .success(let image):
                                    image
                                        .resizable()
                                        .scaledToFill()
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                        .clipped()
                                case .failure:
                                    Image(systemName: "photo")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(maxWidth: .infinity, maxHeight: 200)
                                        .foregroundColor(.gray)
                                default:
                                    EmptyView()
                                }
                            }
                            .tag(index)
                        } else {
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 200)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always)) // Show page indicators
                .frame(height: 200) // Fixed height for carousel
                .cornerRadius(12)
                .padding(.bottom, 5) // Add some space below images
            }

            // Title
            Text(post.title)
                .font(.headline)
                .foregroundColor(.primary)
            
            // Description
            Text(post.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineLimit(3)
            
            // Footer
            HStack {
                // Source
                Text(post.source.rawValue)
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Spacer()
                
                // Date
                Text(post.createdAt, style: .date)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
        .padding(.horizontal)
    }
}

struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        PostCard(post: Post.samplePosts[0])
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 