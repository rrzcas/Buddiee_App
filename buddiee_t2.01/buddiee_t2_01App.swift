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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(postStore)
                .environmentObject(userStore)
                .environmentObject(historyStore)
        }
    }
}
