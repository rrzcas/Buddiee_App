import SwiftUI
import PhotosUI

struct AddPostView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var location = ""
    @State private var selectedImages: [UIImage] = []
    @State private var photoPickerItems: [PhotosPickerItem] = []
    @State private var photoError: String? = nil
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Photos (Required)")) {
                    PhotosPicker(
                        selection: $photoPickerItems,
                        maxSelectionCount: 6,
                        matching: .images,
                        photoLibrary: .shared()) {
                        HStack {
                            Image(systemName: "photo.on.rectangle")
                            Text("Select 1-6 photos")
                        }
                    }
                    .onChange(of: photoPickerItems) { _, newItems in
                        selectedImages = []
                        for item in newItems.prefix(6) {
                            _ = item.loadTransferable(type: Data.self) { result in
                                if case .success(let data?) = result, let img = UIImage(data: data) {
                                    DispatchQueue.main.async {
                                        selectedImages.append(img)
                                    }
                                }
                            }
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
                }
                Section(header: Text("Post Details")) {
                    TextField("Title", text: $title)
                    TextEditor(text: $description)
                        .frame(height: 100)
                    TextField("Location", text: $location)
                }
            }
            .navigationTitle("New Post")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Post") {
                    if selectedImages.count < 1 {
                        photoError = "Please select at least 1 photo."
                        return
                    }
                    // TODO: Add post creation logic with selectedImages
                    dismiss()
                }
                .disabled(title.isEmpty || description.isEmpty || selectedImages.isEmpty)
            )
        }
    }
} 
