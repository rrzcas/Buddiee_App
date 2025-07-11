//
//  ContentView.swift
//  buddiee_t2.01
//
//  Created by Helen Fung on 07/06/2025.
import SwiftUI
import PhotosUI

struct SourceFilterButton: View {
    let source: PostSource
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(source.rawValue)
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

struct FilterButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

struct ContentView: View {
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("selectedHobbies") var selectedHobbiesString: String = ""
    @AppStorage("locationPref") var locationPref: Bool = true
    @StateObject var postStore = PostStore()
    @StateObject var userStore = UserStore()
    @State private var selectedTab = 0
    @State private var showPostSuccess = false
    @State private var justPostedId: UUID? = nil
    @State private var justPostedHobby: String? = nil
    @AppStorage("mainHobbies") private var mainHobbiesString: String = ""
    var mainHobbies: [String] { mainHobbiesString.split(separator: ",").map { String($0) } }
    
    var selectedHobbies: [String] {
        selectedHobbiesString.split(separator: ",").map { String($0) }
    }
    
    var body: some View {
        if !onboardingComplete {
            OnboardingFlow()
        } else {
            TabView(selection: $selectedTab) {
                // Posts Feed
                PostsFeedView(
                    justPostedId: $justPostedId,
                    showPostSuccess: $showPostSuccess,
                    selectedHobbies: mainHobbies,
                    locationPref: locationPref
                )
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("Posts")
                }
                .tag(0)
                // Create
                FirstPostCreationFlow(
                    onPostSuccess: { postId, hobby in
                        justPostedId = postId
                        showPostSuccess = true
                        justPostedHobby = hobby
                        selectedTab = 0
                    }
                )
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .tag(1)
                // Location
                LocationFinderView()
                    .tabItem {
                        Image(systemName: "map.fill")
                        Text("Location")
                    }
                    .tag(2)
                // Messages
                MessagesView()
                    .tabItem {
                        Image(systemName: "message.fill")
                        Text("Messages")
                    }
                    .tag(3)
                // Profile
                ProfileView(user: userStore.currentUser ?? User(id: "", username: "", profilePicture: nil, bio: ""))
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                        Text("Profile")
                    }
                    .tag(4)
            }
            .environmentObject(postStore)
            .environmentObject(userStore)
            .onAppear {
                NotificationCenter.default.addObserver(forName: NSNotification.Name("ShowCreateTabAfterOnboarding"), object: nil, queue: .main) { _ in
                    selectedTab = 1
                }
            }
        }
    }
}

// Create Post Button View
struct CreatePostButtonView: View {
    @Binding var showingCreateOptions: Bool
    
    var body: some View {
        VStack {
            Spacer()
            
            Button(action: {
                showingCreateOptions = true
            }) {
                VStack(spacing: 12) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.blue)
                    
                    Text("Create Post")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                }
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

// Create Post Options Overlay View
struct CreatePostOptionsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var showingPhotoPost = false
    @State private var showingTextPost = false
    @Binding var shouldNavigateToFeed: Bool
    @Binding var showingCreateOptions: Bool
    
    var body: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }
            
            VStack(spacing: 30) {
                Spacer()
                
                // Photo Post Option (Bigger button)
                Button(action: {
                    showingPhotoPost = true
                }) {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            Text("Post with Photos")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("(Recommended)")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                    .background(Color.blue)
                    .cornerRadius(20)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 40)
                
                // Text Post Option (Smaller button)
                Button(action: {
                    showingTextPost = true
                }) {
                    VStack(spacing: 12) {
                        Image(systemName: "text.quote")
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                        
                        Text("Post with Text")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 25)
                    .background(Color.gray)
                    .cornerRadius(15)
                }
                .buttonStyle(ScaleButtonStyle())
                .padding(.horizontal, 60)
                
                Spacer()
            }
        }
        .sheet(isPresented: $showingPhotoPost) {
            FirstPostCreationFlow()
        }
    }
}

// Placeholder views for each tab
struct PostsFeedView_TabPlaceholder: View {
    var body: some View {
        Text("Posts Feed")
    }
}

struct LocationView: View {
    var body: some View {
        Text("Location Map")
    }
}

struct SearchBar: View {
    @Binding var text: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("Search posts...", text: $text)
                .textFieldStyle(PlainTextFieldStyle())
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// Custom button style for hover effect
struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
    }
}

#Preview {
    ContentView()
        .environmentObject(PostStore())
}
