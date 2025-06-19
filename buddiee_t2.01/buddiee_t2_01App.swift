//
//  buddiee_t2_01App.swift
//  buddiee_t2.01
//
//  Created by Helen Fung on 07/06/2025.
//

import SwiftUI

@main
struct buddiee_t2_01App: App {
    @StateObject private var postStore = PostStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var historyStore = BrowsingHistoryStore()
    @State private var selectedTab: Int = 0 // 0 for Find Buddies, 1 for Messages, 2 for Post, 3 for Profile, 4 for Location

    var body: some Scene {
        WindowGroup {
            TabView(selection: $selectedTab) {
                ContentView()
                    .tabItem {
                        Label("Find Buddies", systemImage: "person.2.fill")
                    }
                    .tag(0)
                
                MessagesView()
                    .tabItem {
                        Label("Messages", systemImage: "message.fill")
                    }
                    .tag(1)
                
                PostCreationView()
                    .tabItem {
                        Label("Post", systemImage: "plus.circle.fill")
                    }
                    .tag(2)
                
                LocationFinderView()
                    .tabItem {
                        Label("Location", systemImage: "mappin.and.ellipse")
                    }
                    .tag(3)
                
                ProfileView(user: userStore.currentUser)
                    .tabItem {
                        Label("Profile", systemImage: "person.fill")
                    }
                    .tag(4)
            }
            .environmentObject(postStore)
            .environmentObject(userStore)
            .environmentObject(historyStore)
        }
    }
}
