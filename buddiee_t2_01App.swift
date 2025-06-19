import SwiftUI

@main
struct buddiee_t2_01App: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, World!")
                .font(.largeTitle)
                .padding()
            
            Text("If you can see this, the app is working!")
                .foregroundColor(.blue)
        }
    }
}

#Preview {
    ContentView()
} 