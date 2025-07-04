import SwiftUI
import PhotosUI
import Photos

enum PostCreationStep {
    case photos, details, profile, verify, review
}

struct FirstPostCreationFlow: View {
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var userStore: UserStore
    @Environment(\.dismiss) private var dismiss
    @State private var step: PostCreationStep = .photos
    // Step 1: Photos
    @State private var postSelectedImages: [UIImage] = []
    @State private var postPhotoPickerItems: [PhotosPickerItem] = []
    @State private var photoError: String? = nil
    // Step 2: Details
    @State private var title: String = ""
    @State private var content: String = ""
    @State private var selectedCategory: String = "Study"
    @State private var detailsError: String? = nil
    // Step 3: Profile
    @State private var selectedIcon: String = "person.circle"
    @State private var username: String = ""
    @State private var uuid: String = UUID().uuidString
    @State private var uuidError: String? = nil
    // Step 4: Verification
    @State private var verificationMethod: String? = nil
    @State private var email: String = ""
    @State private var code: String = ""
    @State private var verificationError: String? = nil
    @State private var isLoading = false
    // Step 5: Review & Post
    @State private var postError: String? = nil
    @State private var postSuccess = false
    // Helper
    let hobbyOptions = ["Study", "Light Trekking", "Photography", "Gym", "Day Outing", "Others"]
    let iconOptions = ["person.circle", "person.circle.fill", "person.crop.circle", "person.crop.circle.fill", "person.2.circle", "person.2.circle.fill"]
    @State private var showPhotoPicker: Bool = false
    @State private var isLoadingImages: Bool = false
    // Step 3: Profile (User Icon)
    @State private var userIconPickerItem: PhotosPickerItem? = nil
    @State private var userIconImage: UIImage? = nil
    @State private var uiUpdateTrigger: Bool = false
    var body: some View {
        NavigationView {
            VStack {
                switch step {
                case .photos:
                    photoStep
                case .details:
                    detailsStep
                case .profile:
                    profileStep
                case .verify:
                    verifyStep
                case .review:
                    reviewStep
                }
                Spacer()
                HStack {
                    if step != .photos {
                        Button("Back") { withAnimation { previousStep() } }
                            .padding()
                    }
                    Spacer()
                    Button(action: {
                        print("[BUTTON] Continue tapped, step: \(step), isStepComplete: \(isStepComplete)")
                        withAnimation { nextStep() }
                    }) {
                        Text(step == .review ? "Post to find your buddy now!" : "Continue")
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(isStepComplete ? Color.blue : Color.gray)
                            .cornerRadius(12)
                    }
                    .disabled(!isStepComplete || isLoading)
                }
                .padding()
            }
            .navigationTitle("Create First Post")
            .alert(isPresented: $postSuccess) {
                Alert(title: Text("Success!"), message: Text("Your account and post have been created."), dismissButton: .default(Text("OK"), action: { dismiss() }))
            }
        }
    }
    // MARK: - Step Views
    private var photoStep: some View {
        PhotoStepView(
            postSelectedImages: $postSelectedImages,
            postPhotoPickerItems: $postPhotoPickerItems,
            isLoadingImages: $isLoadingImages,
            uiUpdateTrigger: $uiUpdateTrigger,
            photoError: $photoError,
            showPhotoPicker: $showPhotoPicker
        )
    }
    private var detailsStep: some View {
        VStack(spacing: 20) {
            HStack {
                Text("Caption")
                if title.isEmpty && detailsError != nil {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            TextField("Enter caption", text: $title)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Text("Description")
                if content.isEmpty && detailsError != nil {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            TextEditor(text: $content)
                .frame(height: 80)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.2)))
            HStack {
                Text("Hobby Type")
                if selectedCategory.isEmpty && detailsError != nil {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            Picker("Hobby Type", selection: $selectedCategory) {
                ForEach(hobbyOptions, id: \.self) { hobby in
                    Text(hobby)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Divider().background(Color.gray)
            Text("") // Spacer for visual separation
        }.padding()
    }
    private var profileStep: some View {
        VStack(spacing: 20) {
            Divider().background(Color.gray)
            Text("Posting as...")
                .font(.subheadline)
                .foregroundColor(.gray)
            PhotosPicker(selection: $userIconPickerItem, matching: .images, photoLibrary: .shared()) {
                HStack {
                    Image(systemName: "person.crop.circle")
                    Text("Choose User Icon")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .onChange(of: userIconPickerItem) { _, newItem in
                if let item = newItem {
                    Task {
                        if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                            userIconImage = img
                        }
                    }
                }
            }
            if let icon = userIconImage {
                Image(uiImage: icon)
                    .resizable()
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
            }
            HStack {
                Text("Username")
                if username.isEmpty && uuidError != nil {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            TextField("Enter username", text: $username)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            HStack {
                Text("User ID (UUID)")
                if uuid.isEmpty && uuidError != nil {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            HStack {
                TextField("Enter user id", text: $uuid)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Randomize") {
                    uuid = UUID().uuidString
                }
            }
            Text("\(uuid)")
                .font(.caption)
                .foregroundColor(.gray)
            if let error = uuidError {
                Text(error).foregroundColor(.red).font(.caption)
            }
        }.padding()
    }
    private var verifyStep: some View {
        VStack(spacing: 20) {
            Divider().background(Color.gray)
            Text("Personal info for creating your account, ensuring user authenticity")
                .font(.subheadline)
                .foregroundColor(.gray)
            Picker("Verification Method", selection: $verificationMethod) {
                Text("Apple ID").tag("apple" as String?)
                Text("Email").tag("email" as String?)
            }
            .pickerStyle(SegmentedPickerStyle())
            if verificationMethod == "email" {
                HStack {
                    Text("Email")
                    if email.isEmpty && verificationError != nil {
                        Text("required").foregroundColor(.red).font(.caption)
                    }
                }
                TextField("Email", text: $email)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    Text("Verification Code")
                    if code.isEmpty && verificationError != nil {
                        Text("required").foregroundColor(.red).font(.caption)
                    }
                }
                TextField("Verification Code", text: $code)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button("Send Code") { /* UI only for now */ }
            } else if verificationMethod == "apple" {
                Button("Sign in with Apple") { /* UI only for now */ }
            }
            if let error = verificationError {
                Text(error).foregroundColor(.red).font(.caption)
            }
        }.padding()
    }
    private var reviewStep: some View {
        VStack(spacing: 20) {
            Text("Review & Post")
                .font(.title2)
                .fontWeight(.semibold)
            if let error = postError {
                Text(error).foregroundColor(.red).font(.caption)
            }
            if isLoading {
                ProgressView("Posting...")
            }
        }.padding()
    }
    // MARK: - Step Logic
    private var isStepComplete: Bool {
        switch step {
        case .photos:
            return postSelectedImages.count >= 1 && postSelectedImages.count <= 6 && !isLoadingImages
        case .details:
            return !title.isEmpty && !content.isEmpty && !selectedCategory.isEmpty
        case .profile:
            return !username.isEmpty && !uuid.isEmpty
        case .verify:
            return verificationMethod != nil && (verificationMethod == "apple" || (verificationMethod == "email" && !email.isEmpty && !code.isEmpty))
        case .review:
            return true
        }
    }
    private func nextStep() {
        print("Current step: \(step)")
        switch step {
        case .photos:
            print("postSelectedImages count: \(postSelectedImages.count)")
            if postSelectedImages.count < 1 {
                photoError = "Please select at least 1 photo."
                return
            }
            photoError = nil
            step = .details
            print("Advancing to .details step")
        case .details:
            print("title: \(title), content: \(content), selectedCategory: \(selectedCategory)")
            if title.isEmpty || content.isEmpty {
                detailsError = "All fields are required."
                return
            }
            detailsError = nil
            step = .profile
            print("Advancing to .profile step")
        case .profile:
            print("username: \(username), uuid: \(uuid)")
            if username.isEmpty || uuid.isEmpty {
                uuidError = "Username and User ID are required."
                return
            }
            if userStore.users.contains(where: { $0.id == uuid }) {
                uuidError = "User_id duplicated, please choose another user id"
                return
            }
            uuidError = nil
            step = .verify
            print("Advancing to .verify step")
        case .verify:
            print("verificationMethod: \(String(describing: verificationMethod)), email: \(email), code: \(code)")
            if verificationMethod == nil || (verificationMethod == "email" && (email.isEmpty || code.isEmpty)) {
                verificationError = "Please complete verification."
                return
            }
            verificationError = nil
            step = .review
            print("Advancing to .review step")
        case .review:
            print("Creating account and post...")
            createAccountAndPost()
        }
        print("New step: \(step)")
    }
    private func previousStep() {
        switch step {
        case .photos: break
        case .details: step = .photos
        case .profile: step = .details
        case .verify: step = .profile
        case .review: step = .verify
        }
    }
    private func loadSelectedImages(_ items: [PhotosPickerItem], completion: @escaping ([UIImage]) -> Void) {
        print("loadSelectedImages called with \(items.count) items")
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                    loadedImages.append(img)
                    print("Appended image, loadedImages count: \(loadedImages.count)")
                }
            }
            DispatchQueue.main.async {
                print("selectedImages after async load: \(loadedImages.count)")
                isLoadingImages = false
                uiUpdateTrigger.toggle()
                print("isLoadingImages set to false, uiUpdateTrigger toggled")
                completion(loadedImages)
            }
        }
    }
    private func createAccountAndPost() {
        isLoading = true
        // Simulate atomic creation
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            let user = User(id: uuid, username: username, profilePicture: selectedIcon, bio: "")
            userStore.currentUser = user
            userStore.users.append(user)
            let newPost = Post(
                id: UUID(),
                userId: uuid,
                username: username,
                photos: postSelectedImages.map { _ in "local-image" }, // Placeholder for now
                mainCaption: title,
                detailedCaption: content,
                subject: selectedCategory,
                location: "",
                userLocation: "",
                createdAt: Date(),
                likes: 0,
                comments: [],
                isPrivate: false,
                isPinned: false
            )
            postStore.createPost(newPost)
            isLoading = false
            postSuccess = true
        }
    }
}

struct PhotoStepView: View {
    @Binding var postSelectedImages: [UIImage]
    @Binding var postPhotoPickerItems: [PhotosPickerItem]
    @Binding var isLoadingImages: Bool
    @Binding var uiUpdateTrigger: Bool
    @Binding var photoError: String?
    @Binding var showPhotoPicker: Bool
    var body: some View {
        VStack(spacing: 20) {
            Text("Select 1-6 related photos")
                .font(.headline)
            Button(action: {
                let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
                if status == .authorized || status == .limited {
                    showPhotoPicker = true
                } else if status == .notDetermined {
                    PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                        DispatchQueue.main.async {
                            if newStatus == .authorized || newStatus == .limited {
                                showPhotoPicker = true
                            }
                        }
                    }
                }
            }) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Pick Photos")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .disabled(false)
            .photosPicker(isPresented: $showPhotoPicker, selection: $postPhotoPickerItems, maxSelectionCount: 6, matching: .images)
            .onChange(of: postPhotoPickerItems) { _, newItems in
                isLoadingImages = true
                loadSelectedImages(newItems) { images in
                    postSelectedImages = images
                    isLoadingImages = false
                    uiUpdateTrigger.toggle()
                }
            }
            if isLoadingImages {
                ProgressView("Loading photos...")
            }
            if postSelectedImages.isEmpty && photoError != nil {
                HStack(spacing: 4) {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            if let error = photoError {
                Text(error).foregroundColor(.red).font(.caption)
            }
            if !postSelectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(postSelectedImages, id: \ .self) { img in
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }
        .padding()
    }
    private func loadSelectedImages(_ items: [PhotosPickerItem], completion: @escaping ([UIImage]) -> Void) {
        print("loadSelectedImages called with \(items.count) items [PhotoStepView]")
        Task {
            var loadedImages: [UIImage] = []
            for item in items {
                if let data = try? await item.loadTransferable(type: Data.self), let img = UIImage(data: data) {
                    loadedImages.append(img)
                    print("Appended image, loadedImages count: \(loadedImages.count) [PhotoStepView]")
                }
            }
            DispatchQueue.main.async {
                print("selectedImages after async load: \(loadedImages.count) [PhotoStepView]")
                completion(loadedImages)
            }
        }
    }
}

#Preview {
    FirstPostCreationFlow()
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