//
//  ContentView.swift
//  buddiee_t2.01
//
//  Created by Helen Fung on 07/06/2025.
import SwiftUI

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
    @EnvironmentObject var postStore: PostStore
    @EnvironmentObject var userStore: UserStore
    @EnvironmentObject var browsingHistoryStore: BrowsingHistoryStore
    @State private var selectedSource: PostSource = .all
    @State private var searchText = ""
    @State private var showingPostCreation = false
    @State private var showingProfile = false
    @State private var showingMessages = false
    @State private var showingLocationFinder = false
    @State private var selectedLocation: String?
    @State private var showingPartialPosts = false
    @State private var showingAddPost = false
    @State private var showingSettings = false
    @State private var showingFilter = false
    @State private var showingPostDetail: Post?
    @State private var showingError = false
    @State private var selectedFilter: PostFilter = .all
    @State private var showPartialResults = false
    
    var filteredPosts: [Post] {
        let searchFiltered = postStore.posts.filter { post in
            searchText.isEmpty || 
            post.title.localizedCaseInsensitiveContains(searchText) ||
            post.description.localizedCaseInsensitiveContains(searchText)
        }
        
        let sourceFiltered = searchFiltered.filter { post in
            selectedSource == .all || post.source == selectedSource
        }
        
        return sourceFiltered.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                searchAndFilterSection
                postsDisplaySection
            }
            .navigationTitle("Study Buddies")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    toolbarLeadingItem
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    toolbarTrailingItems
                }
            }
            .sheet(isPresented: $showingPostCreation) {
                PostCreationView()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView(user: userStore.currentUser)
            }
            .sheet(isPresented: $showingMessages) {
                MessagesView()
            }
            .sheet(isPresented: $showingLocationFinder) {
                LocationFinderView(selectedLocation: $selectedLocation)
            }
            .sheet(isPresented: $showingAddPost) {
                AddPostView()
            }
            .sheet(isPresented: $showingFilter) {
                FilterView(selectedFilter: $selectedFilter)
            }
            .sheet(item: $showingPostDetail) { post in
                PostDetailView(post: post)
                    .environmentObject(postStore)
                    .environmentObject(userStore)
                    .environmentObject(browsingHistoryStore)
            }
            .overlay(
                StatusView()
                    .environmentObject(postStore)
            )
            .onAppear {
                Task {
                    await postStore.updatePosts()
                }
            }
        }
    }
    
    // MARK: - Private Helper Views
    private var searchAndFilterSection: some View {
        VStack(spacing: 0) {
            SearchBar(text: $searchText)
                .padding(.horizontal)
                .padding(.top, 8)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(PostSource.allCases, id: \.self) { source in
                        SourceFilterButton(
                            source: source,
                            isSelected: selectedSource == source,
                            action: { selectedSource = source }
                        )
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
        }
    }

    private var postsDisplaySection: some View {
        Group {
            if postStore.isLoading {
                ProgressView("Loading posts...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = postStore.errorMessage {
                VStack {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                    Button("Retry") {
                        Task {
                            await postStore.updatePosts()
                        }
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredPosts) { post in
                            NavigationLink {
                                PostDetailView(post: post)
                                    .environmentObject(postStore)
                                    .environmentObject(userStore)
                                    .environmentObject(browsingHistoryStore)
                            } label: {
                                PostCard1(post: post)
                                    .environmentObject(postStore)
                            }
                        }
                    }
                    .padding()
                }
            }
        }
    }

    private var toolbarLeadingItem: some View {
        Button(action: { showingProfile = true }) {
            Image(systemName: "person.circle")
        }
    }

    private var toolbarTrailingItems: some View {
        HStack {
            Button(action: { showingMessages = true }) {
                Image(systemName: "message")
            }

            Button(action: { showingPostCreation = true }) {
                Image(systemName: "plus")
            }
        }
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
