import SwiftUI
import PhotosUI

struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var postStore: PostStore
    
    @State private var username: String
    @State private var location: String
    @State private var bio: String
    @State private var interests: [ActivityCategory]
    @State private var newInterest: String = ""
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    
    init(user: User) {
        self.user = user
        _username = State(initialValue: user.username)
        _location = State(initialValue: user.location)
        _bio = State(initialValue: user.bio)
        _interests = State(initialValue: user.interests ?? [])
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Profile Photo")) {
                    HStack {
                        Spacer()
                        if let selectedImage {
                            Image(uiImage: selectedImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else {
                            Image(systemName: user.profileImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                    
                    PhotosPicker(selection: $photoPickerItem,
                               matching: .images,
                               photoLibrary: .shared()) {
                        Text("Change Photo")
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section(header: Text("Basic Information")) {
                    TextField("Username", text: $username)
                    TextField("Location", text: $location)
                }
                
                Section(header: Text("About")) {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
                }
                
                Section(header: Text("Optional Interests")) {
                    ForEach(ActivityCategory.allCases, id: \.self) { category in
                        Toggle(isOn: Binding(
                            get: { interests.contains(category) },
                            set: { isSelected in
                                if isSelected {
                                    interests.append(category)
                                } else {
                                    interests.removeAll { $0 == category }
                                }
                            }
                        )) {
                            HStack {
                                Image(systemName: category.icon)
                                    .foregroundColor(category.color)
                                Text(category.rawValue.capitalized)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Edit Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                }
            }
            .onChange(of: photoPickerItem) { newItem in
                Task {
                    if let data = try? await newItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                    }
                }
            }
        }
    }
    
    private func saveChanges() {
        let updatedUser = User(
            id: user.id,
            username: username,
            profileImage: user.profileImage,
            location: location,
            bio: bio,
            interests: interests.isEmpty ? nil : interests
        )
        
        // Update user in all posts
        for post in postStore.posts where post.user.id == user.id {
            let updatedPost = Post(
                id: post.id,
                title: post.title,
                description: post.description,
                imageURLs: post.imageURLs,
                user: updatedUser,
                category: post.category,
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
        }
        
        dismiss()
    }
}

#Preview {
    EditProfileView(user: User.sampleUsers[0])
        .environmentObject(PostStore())
} 