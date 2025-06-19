import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("privateProfile") private var privateProfile = false
    @AppStorage("fontSize") private var fontSize: Double = 1.0
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.dismiss) var dismiss
    @State private var showingBrowsingHistory = false
    @EnvironmentObject private var historyStore: BrowsingHistoryStore
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Appearance")) {
                    Toggle("Dark Mode", isOn: $isDarkMode)
                    
                    VStack {
                        Text("Font Size")
                        Slider(value: $fontSize, in: 0.8...1.2, step: 0.1) {
                            Text("Font Size")
                        }
                        Text("Preview Text")
                            .font(.system(size: 16 * fontSize))
                    }
                }
                
                Section(header: Text("Privacy")) {
                    Toggle("Private Profile", isOn: $privateProfile)
                    Toggle("Show Online Status", isOn: .constant(true))
                    Toggle("Allow Friend Requests", isOn: .constant(true))
                }
                
                Section(header: Text("Notifications")) {
                    Toggle("Push Notifications", isOn: $notificationsEnabled)
                    Toggle("Email Notifications", isOn: .constant(true))
                    Toggle("Message Notifications", isOn: .constant(true))
                }
                
                Section(header: Text("History")) {
                    Button("View Browsing History") {
                        showingBrowsingHistory = true
                    }
                }
                
                Section(header: Text("Account")) {
                    Button("Sign Out") {
                        // TODO: Implement sign out
                    }
                    .foregroundColor(.red)
                    
                    Button("Delete Account") {
                        // TODO: Implement account deletion
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingBrowsingHistory) {
                BrowsingHistoryView()
                    .environmentObject(historyStore)
            }
        }
    }
} 