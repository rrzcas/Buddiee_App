import SwiftUI

struct BrowsingHistoryView: View {
    @EnvironmentObject var historyStore: BrowsingHistoryStore
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            List {
                ForEach(historyStore.browsingHistory) { post in
                    NavigationLink {
                        PostDetailView(post: post)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(post.title)
                                .font(.headline)
                            
                            HStack {
                                Image(systemName: post.category.icon)
                                    .foregroundColor(post.category.color)
                                Text(post.category.rawValue)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Text(post.createdAt, style: .relative)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle("Browsing History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Clear All") {
                        historyStore.clearHistory()
                    }
                    .foregroundColor(.red)
                }
            }
        }
    }
}

#Preview {
    BrowsingHistoryView()
        .environmentObject(BrowsingHistoryStore())
} 