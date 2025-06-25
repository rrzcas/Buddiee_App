import SwiftUI
import MapKit
import CoreLocation

struct LocationFinderView: View {
    @EnvironmentObject var postStore: PostStore
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var internalSelectedLocation: String?
    @Binding var selectedLocation: String?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278), // London coordinates
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    init(selectedLocation: Binding<String?>? = nil) {
        self._selectedLocation = selectedLocation ?? .constant(nil)
    }
    
    var body: some View {
        NavigationView {
            VStack {
                Map {
                    ForEach(postStore.posts) { post in
                        Annotation(post.location ?? "", coordinate: getCoordinate(for: post)) {
                            Image(systemName: "mappin.circle.fill")
                                .foregroundColor(.red)
                                .font(.title)
                        }
                    }
                }
                .frame(height: 300)
                
                List {
                    ForEach(filteredPosts) { post in
                        VStack(alignment: .leading) {
                            Text(post.location ?? "")
                                .font(.headline)
                            Text(post.detailedCaption ?? "")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                }
            }
            .navigationTitle("Location Finder")
            .searchable(text: $searchText, prompt: "Search locations")
            .onChange(of: locationManager.currentAddress) { oldValue, newValue in
                selectedLocation = newValue
            }
        }
    }
    
    private var filteredPosts: [Post] {
        if searchText.isEmpty {
            return postStore.posts
        }
        return postStore.posts.filter { post in
            (post.location ?? "").localizedCaseInsensitiveContains(searchText)
        }
    }
    
    private func getCoordinate(for post: Post) -> CLLocationCoordinate2D {
        // For now, we'll use a simple mapping of locations to coordinates
        // In a real app, you would want to use proper geocoding
        switch (post.location ?? "").lowercased() {
        case "london":
            return CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        case "manchester":
            return CLLocationCoordinate2D(latitude: 53.4808, longitude: -2.2426)
        case "birmingham":
            return CLLocationCoordinate2D(latitude: 52.4862, longitude: -1.8904)
        case "leeds":
            return CLLocationCoordinate2D(latitude: 53.8008, longitude: -1.5491)
        case "glasgow":
            return CLLocationCoordinate2D(latitude: 55.8642, longitude: -4.2518)
        default:
            // Default to London if location is not recognized
            return CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278)
        }
    }
}

#Preview {
    LocationFinderView(selectedLocation: .constant(nil))
        .environmentObject(PostStore())
} 