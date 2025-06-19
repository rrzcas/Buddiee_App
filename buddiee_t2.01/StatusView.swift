import SwiftUI

struct StatusView: View {
    @EnvironmentObject var postStore: PostStore
    
    var body: some View {
        if postStore.isStatusVisible {
            VStack {
                ScrollView {
                    Text(postStore.statusMessage.isEmpty ? "Loading..." : postStore.statusMessage)
                        .font(.system(.body, design: .monospaced))
                        .padding()
                }
                .frame(maxHeight: 200)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .shadow(radius: 5)
                .padding()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.opacity(0.4))
            .edgesIgnoringSafeArea(.all)
        }
    }
}

#Preview {
    StatusView()
        .environmentObject(PostStore())
} 