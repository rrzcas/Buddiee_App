import SwiftUI
import PhotosUI

struct EditPostView: View {
    @EnvironmentObject var postStore: PostStore
    @Environment(\.dismiss) var dismiss
    
    let post: Post
    @State private var title: String
    @State private var description: String
    @State private var category: ActivityCategory
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    
    init(post: Post) {
        self.post = post
        _title = State(initialValue: post.title)
        _description = State(initialValue: post.description)
        _category = State(initialValue: post.category)
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    PhotosPicker(
                        selection: $photoPickerItems,
                        maxSelectionCount: 6,
                        matching: .images,
                        photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select up to 6 photos")
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(10)
                    }
                    .onChange(of: photoPickerItems) { newItems in
                        Task {
                            selectedImages = []
                            for item in newItems.prefix(6) {
                                if let data = try? await item.loadTransferable(type: Data.self),
                                   let uiImage = UIImage(data: data) {
                                    selectedImages.append(uiImage)
                                }
                            }
                        }
                    }
                    
                    if !selectedImages.isEmpty {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 10) {
                                ForEach(selectedImages, id: \.self) { image in
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 100, height: 100)
                                        .clipShape(RoundedRectangle(cornerRadius: 10))
                                }
                            }
                        }
                    }
                    
                    Picker("Category", selection: $category) {
                        ForEach(ActivityCategory.allCases, id: \.self) { category in
                            Text(category.rawValue.capitalized)
                                .tag(category)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                    
                    TextField("Title", text: $title)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    TextEditor(text: $description)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                        )
                    
                    Button("Save Changes") {
                        saveChanges()
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        // Convert selected images to URLs or keep existing ones
        let imageURLs = selectedImages.isEmpty ? post.imageURLs : selectedImages.map { _ in "photo.on.rectangle" }
        
        let updatedPost = Post(
            id: post.id,
            title: title,
            description: description,
            imageURLs: imageURLs,
            user: post.user,
            category: category,
            location: post.location,
            source: post.source,
            originalUrl: post.originalUrl,
            createdAt: post.createdAt,
            isPrivate: post.isPrivate,
            isPinned: post.isPinned,
            isOnline: post.isOnline,
            comments: post.comments
        )
        
        postStore.updatePost(updatedPost)
        dismiss()
    }
}

#Preview {
    EditPostView(post: Post.samplePosts[0])
        .environmentObject(PostStore())
} 