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
    @StateObject var postStore = PostStore()
    @StateObject var userStore = UserStore()
    @StateObject var messageStore = MessageStore()
    @StateObject var locationStore = LocationStore()
    @StateObject var historyStore = BrowsingHistoryStore()
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                PostsFeedView()
            }
            .tabItem {
                Image(systemName: "doc.text.fill")
                Text("Posts")
            }
            .tag(0)
            CreatePostView()
                .tabItem {
                    Image(systemName: "plus.circle.fill")
                    Text("Create")
                }
                .tag(1)
            LocationView()
                .tabItem {
                    Image(systemName: "map.fill")
                    Text("Location")
                }
                .tag(2)
            MessagesView()
                .tabItem {
                    Image(systemName: "message.fill")
                    Text("Messages")
                }
                .tag(3)
            ProfileView(user: User(id: "userId", username: "TestUser", profilePicture: nil, bio: "Test bio"))
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
                .tag(4)
        }
        .environmentObject(postStore)
        .environmentObject(userStore)
        .environmentObject(messageStore)
        .environmentObject(locationStore)
        .environmentObject(historyStore)
    }
}

// Placeholder views for each tab
struct PostsFeedView_TabPlaceholder: View {
    var body: some View {
        Text("Posts Feed")
    }
}

struct CreatePostView: View {
    var body: some View {
        Text("Create Post")
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
