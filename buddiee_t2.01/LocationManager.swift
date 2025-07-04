import Foundation
import CoreLocation
import MapKit

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private let manager = CLLocationManager()
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var userLocation: CLLocation? = nil
    @Published var currentPlacemark: CLPlacemark? // Published for location name
    @Published var currentAddress: String = "Unknown Location"
    
    override init() {
        super.init()
        manager.delegate = self
    }
    
    func requestLocationPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        DispatchQueue.main.async {
            self.authorizationStatus = status
            if status == .authorizedWhenInUse || status == .authorizedAlways {
                self.manager.requestLocation()
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        userLocation = locations.last
        // Reverse geocode immediately for initial user location
        reverseGeocode(location: locations.last!)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }
    
    // MARK: - Geocoding
    func reverseGeocode(location: CLLocation) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            guard let placemark = placemarks?.first else {
                print("Error reverse geocoding: \(error?.localizedDescription ?? "Unknown error")")
                self.currentPlacemark = nil
                self.currentAddress = "Unknown Location"
                return
            }
            self.currentPlacemark = placemark
            self.currentAddress = self.formatAddress(placemark: placemark)
        }
    }
    
    func reverseGeocode(coordinate: CLLocationCoordinate2D) {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        reverseGeocode(location: location)
    }
    
    private func formatAddress(placemark: CLPlacemark) -> String {
        var addressComponents: [String] = []
        if let name = placemark.name, name != placemark.locality && name != placemark.thoroughfare { addressComponents.append(name) }
        if let thoroughfare = placemark.thoroughfare { addressComponents.append(thoroughfare) }
        if let locality = placemark.locality { addressComponents.append(locality) }
        if let administrativeArea = placemark.administrativeArea { addressComponents.append(administrativeArea) }
        if let country = placemark.country { addressComponents.append(country) }
        
        return addressComponents.joined(separator: ", ")
    }
} 