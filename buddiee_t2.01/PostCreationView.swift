import SwiftUI
import PhotosUI
import Photos

struct PostCreationView: View {
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var selectedImages: [UIImage] = []
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: ActivityCategory = .study
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var isLoadingImages = false
    @State private var showSuccessAlert = false
    @State private var currentImageIndex = 0

    private func saveImageToFileSystem(image: UIImage) -> URL? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = UUID().uuidString + ".jpg"
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        guard let fileURL = documentsDirectory?.appendingPathComponent(filename) else { return nil }

        do {
            try data.write(to: fileURL)
            return fileURL
        } catch {
            print("Error saving image: \(error.localizedDescription)")
            return nil
        }
    }

    private func createPost() {
        let imageURLs = selectedImages.compactMap { saveImageToFileSystem(image: $0)?.absoluteString }
        let newPost = Post(
            id: UUID(),
            userId: userStore.currentUser?.id ?? "",
            photos: imageURLs,
            mainCaption: title,
            detailedCaption: content,
            subject: selectedCategory.rawValue,
            location: userStore.currentUser?.bio,
            createdAt: Date(),
            likes: 0,
            comments: []
        )
        postStore.createPost(newPost)
        showSuccessAlert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            dismiss()
        }
        resetFields()
    }
    
    private func resetFields() {
        title = ""
        content = ""
        selectedImages = []
        selectedCategory = .study
        photoPickerItems = []
        currentImageIndex = 0
    }

    var body: some View {
        NavigationView {
            Form {
                postDetailsSection
                photosSection
            }
            .navigationTitle("New Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Post") {
                        createPost()
                    }
                    .disabled(title.isEmpty || content.isEmpty || selectedImages.isEmpty)
                }
            }
            .alert("Success!!!", isPresented: $showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your post has been created successfully!")
            }
        }
    }
    
    private var postDetailsSection: some View {
        Section(header: Text("Post Details")) {
            TextField("Title", text: $title)
            TextEditor(text: $content)
                .frame(height: 100)
            
            Picker("Category", selection: $selectedCategory) {
                ForEach(ActivityCategory.allCases, id: \.self) { category in
                    Text(category.rawValue.capitalized).tag(category)
                }
            }
        }
    }
    
    private var photosSection: some View {
        Section(header: Text("Photos")) {
            PhotosPicker(
                selection: $photoPickerItems,
                maxSelectionCount: 6,
                matching: .images
            ) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Select up to 6 photos")
                }
            }
            .onChange(of: photoPickerItems) { newItems in
                loadSelectedImages(newItems)
            }

            if isLoadingImages {
                ProgressView("Loading photos...")
            } else if !selectedImages.isEmpty {
                imagePreviewView
            }
        }
    }
    
    private var imagePreviewView: some View {
        TabView(selection: $currentImageIndex) {
            ForEach(0..<selectedImages.count, id: \.self) { index in
                Image(uiImage: selectedImages[index])
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
                    .cornerRadius(8)
                    .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(height: 200)
        .overlay(
            Text("\(currentImageIndex + 1)/\(selectedImages.count)")
                .font(.caption)
                .foregroundColor(.white)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.6))
                .cornerRadius(5)
                .padding(5)
            , alignment: .bottomTrailing
        )
        .padding(.vertical, 5)
    }
    
    private func loadSelectedImages(_ items: [PhotosPickerItem]) {
        isLoadingImages = true
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self),
                   let uiImage = UIImage(data: data) {
                    loadedImages.append(uiImage)
                }
            }
            DispatchQueue.main.async {
                self.selectedImages = loadedImages
                self.isLoadingImages = false
                self.currentImageIndex = loadedImages.isEmpty ? 0 : 1
            }
        }
    }
}

#Preview {
    PostCreationView()
        .environmentObject(PostStore())
        .environmentObject(UserStore())
}

// Helper to dismiss keyboard
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif 