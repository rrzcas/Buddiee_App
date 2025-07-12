import SwiftUI
import PhotosUI

struct ImageCropperView: View {
    @Binding var image: UIImage?
    @Binding var isPresented: Bool
    @State private var croppedImage: UIImage? = nil
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    var body: some View {
        VStack {
            Spacer()
            if let image = image {
                GeometryReader { geo in
                    ZStack {
                        Color.black.opacity(0.7).ignoresSafeArea()
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(width: geo.size.width, height: geo.size.width)
                            .scaleEffect(scale)
                            .offset(offset)
                            .clipShape(Circle())
                            .gesture(
                                SimultaneousGesture(
                                    DragGesture().onChanged { value in
                                        offset = value.translation
                                    },
                                    MagnificationGesture().onChanged { value in
                                        scale = value
                                    }
                                )
                            )
                    }
                }
                .frame(height: 350)
            }
            Spacer()
            HStack {
                Button("Cancel") { isPresented = false }
                Spacer()
                Button("Crop & Save") {
                    if let image = image {
                        croppedImage = cropToCircle(image: image, scale: scale, offset: offset)
                        self.image = croppedImage
                        isPresented = false
                    }
                }
            }
            .padding()
        }
    }
    func cropToCircle(image: UIImage, scale: CGFloat, offset: CGSize) -> UIImage? {
        let size = min(image.size.width, image.size.height)
        let renderer = UIGraphicsImageRenderer(size: CGSize(width: size, height: size))
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: CGSize(width: size, height: size))
            ctx.cgContext.addEllipse(in: rect)
            ctx.cgContext.clip()
            image.draw(in: rect)
        }
    }
}

struct EditProfileView: View {
    let user: User
    @Environment(\.dismiss) private var dismiss
    
    @State private var username: String
    @State private var bio: String
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showCropper = false
    
    init(user: User) {
        self.user = user
        _username = State(initialValue: user.username)
        _bio = State(initialValue: user.bio ?? "")
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
                        } else if let profilePicture = user.profilePicture, profilePicture.hasPrefix("file://"), let uiImage = ImageStorage.loadImage(from: profilePicture) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                        } else if let profilePicture = user.profilePicture, let url = URL(string: profilePicture) {
                            AsyncImage(url: url) { image in
                                image.resizable()
                            } placeholder: {
                                ProgressView()
                            }
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                        } else {
                            Image(systemName: "person.circle.fill")
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
                }
                
                Section(header: Text("About")) {
                    TextEditor(text: $bio)
                        .frame(minHeight: 100)
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
            .onChange(of: photoPickerItem) {
                Task {
                    if let data = try? await photoPickerItem?.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        selectedImage = image
                        showCropper = true
                    }
                }
            }
            .sheet(isPresented: $showCropper) {
                ImageCropperView(image: $selectedImage, isPresented: $showCropper)
            }
        }
    }
    
    private func saveChanges() {
        // Convert selected image to file path
        let profilePicturePath: String?
        if let selectedImage = selectedImage {
            profilePicturePath = ImageStorage.saveImage(selectedImage, name: "usericon_\(user.id).jpg")
        } else {
            profilePicturePath = user.profilePicture
        }
        let updatedUser = User(
            id: user.id,
            username: username,
            profilePicture: profilePicturePath,
            bio: bio
        )
        print("Saving updated user: \(updatedUser)")
        
        dismiss()
    }
}

#Preview {
    EditProfileView(user: User(
        id: "userId",
        username: "TestUser",
        profilePicture: nil,
        bio: "Test bio"
    ))
} 