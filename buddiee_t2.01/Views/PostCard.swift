import SwiftUI

struct PostCard: View {
    let post: Post
    let cardHeight: CGFloat
    var onUserTap: ((String) -> Void)? = nil
    var onCardTap: (() -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(alignment: .leading, spacing: 8) {
                // First image only
                if let firstPhoto = post.photos.first {
                    if firstPhoto.hasPrefix("file://"), let uiImage = ImageStorage.loadImage(from: firstPhoto) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(height: cardHeight * 0.55)
                            .clipped()
                            .cornerRadius(10)
                    } else if let url = URL(string: firstPhoto) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView().frame(height: cardHeight * 0.55)
                            case .success(let image):
                                image.resizable().scaledToFill().frame(height: cardHeight * 0.55).clipped().cornerRadius(10)
                            case .failure:
                                Image(systemName: "photo").resizable().scaledToFit().frame(height: cardHeight * 0.55).foregroundColor(.gray)
                            @unknown default:
                                EmptyView()
                            }
                        }
                    } else {
                        Image(systemName: "photo").resizable().scaledToFit().frame(height: cardHeight * 0.55).foregroundColor(.gray)
                    }
                }
                // Caption only
                Text(post.mainCaption)
                    .font(.headline)
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .padding(.top, 4)
                Spacer()
                HStack {
                    // Username (tap to open profile)
                    Button(action: { onUserTap?(post.userId) }) {
                        HStack(spacing: 4) {
                            Image(systemName: "person.crop.circle")
                            Text(post.username)
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    Spacer()
                    // Color-coded timestamp
                    Text(timeAgoString(for: post.createdAt))
                        .font(.caption)
                        .foregroundColor(colorForTimestamp(post.createdAt))
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            .onTapGesture { onCardTap?() }
        }
        .frame(height: cardHeight)
        .padding(.horizontal)
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
    // Helper for color coding
    private func colorForTimestamp(_ date: Date) -> Color {
        let interval = Date().timeIntervalSince(date)
        let days = Int(interval / 86400)
        if days < 2 {
            return Color(.systemGreen)
        } else if days < 5 {
            return Color.green.opacity(0.6)
        } else if days < 11 {
            return Color.yellow
        } else {
            return Color.gray
        }
    }
}

struct PostCard_Previews: PreviewProvider {
    static var previews: some View {
        PostCard(post: Post(
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
        ), cardHeight: 200)
            .previewLayout(.sizeThatFits)
            .padding()
    }
} 