//
//  buddiee_t2_01App.swift
//  buddiee_t2.01
//
//  Created by Helen Fung on 07/06/2025.
//

import SwiftUI
import Supabase

let supabaseUrl = URL(string: "https://mdhxjzxgdrhrqqdpobia.supabase.co")!
let supabaseKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1kaHhqenhnZHJocnFxZHBvYmlhIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTEzNzQ2NjcsImV4cCI6MjA2Njk1MDY2N30.mPYlTt5BLUvi20KVFRhZeco0dflwpAJKsYPNWA8mKm4"
let supabase = SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: supabaseKey)

@main
struct buddiee_t2_01App: App {
    @State private var isAuthenticated = false
    @StateObject private var postStore = PostStore()
    @StateObject private var userStore = UserStore()
    @StateObject private var historyStore = BrowsingHistoryStore()

    var body: some Scene {
        WindowGroup {
            OnboardingFlow()
                .environmentObject(postStore)
                .environmentObject(userStore)
                .environmentObject(historyStore)
        }
    }
}
