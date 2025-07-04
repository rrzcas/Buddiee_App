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
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
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
                    Button(action: { withAnimation { nextStep() } }) {
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
        VStack(spacing: 20) {
            Text("Select 1-6 related photos")
                .font(.headline)
            PhotosPicker(
                selection: $photoPickerItems,
                maxSelectionCount: 6,
                matching: .images,
                photoLibrary: .shared()) {
                HStack {
                    Image(systemName: "photo.on.rectangle")
                    Text("Pick Photos")
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
            }
            .onChange(of: photoPickerItems) { _, newItems in
                loadSelectedImages(newItems)
            }
            if selectedImages.isEmpty && photoError != nil {
                HStack(spacing: 4) {
                    Text("required").foregroundColor(.red).font(.caption)
                }
            }
            if let error = photoError {
                Text(error).foregroundColor(.red).font(.caption)
            }
            if !selectedImages.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(selectedImages, id: \.self) { img in
                            Image(uiImage: img)
                                .resizable()
                                .frame(width: 80, height: 80)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                }
            }
        }.padding()
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
            if let error = detailsError {
                Text(error).foregroundColor(.red).font(.caption)
            }
        }.padding()
    }
    private var profileStep: some View {
        VStack(spacing: 20) {
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
            TextField("Enter user id", text: $uuid)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            if let error = uuidError {
                Text(error).foregroundColor(.red).font(.caption)
            }
        }.padding()
    }
    private var verifyStep: some View {
        VStack(spacing: 20) {
            Text("Personal info for creating your account, ensuring user authenticity")
                .font(.headline)
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
            return selectedImages.count >= 1 && selectedImages.count <= 6
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
        switch step {
        case .photos:
            if selectedImages.count < 1 {
                photoError = "Please select at least 1 photo."
                return
            }
            photoError = nil
            step = .details
        case .details:
            if title.isEmpty || content.isEmpty {
                detailsError = "All fields are required."
                return
            }
            detailsError = nil
            step = .profile
        case .profile:
            if username.isEmpty || uuid.isEmpty {
                uuidError = "Username and User ID are required."
                return
            }
            // Simulate duplicate check
            if userStore.users.contains(where: { $0.id == uuid }) {
                uuidError = "User_id duplicated, please choose another user id"
                return
            }
            uuidError = nil
            step = .verify
        case .verify:
            if verificationMethod == nil || (verificationMethod == "email" && (email.isEmpty || code.isEmpty)) {
                verificationError = "Please complete verification."
                return
            }
            verificationError = nil
            step = .review
        case .review:
            createAccountAndPost()
        }
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
    private func loadSelectedImages(_ items: [PhotosPickerItem]) {
        selectedImages = []
        for item in items {
            _ = item.loadTransferable(type: Data.self) { result in
                if case .success(let data?) = result, let img = UIImage(data: data) {
                    DispatchQueue.main.async {
                        selectedImages.append(img)
                    }
                }
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
                photos: selectedImages.map { _ in "local-image" }, // Placeholder for now
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