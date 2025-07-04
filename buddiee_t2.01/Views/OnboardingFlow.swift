import SwiftUI
import CoreLocation

enum OnboardingStep {
    case welcome
    case interests
    case location
    case confirmLocation
    case manualLocation
}

class OnboardingViewModel: ObservableObject {
    @Published var step: OnboardingStep = .welcome
    @Published var selectedInterests: Set<String> = []
    @Published var locationPreference: Bool? = nil
    @Published var confirmedLocation: String? = nil
}

struct OnboardingFlow: View {
    @StateObject var vm = OnboardingViewModel()
    @AppStorage("onboardingComplete") var onboardingComplete: Bool = false
    @AppStorage("selectedHobbies") var selectedHobbiesString: String = ""
    @AppStorage("locationPref") var locationPref: Bool = true
    @StateObject var locationManager = LocationManager()
    @Namespace var animation
    var body: some View {
        if onboardingComplete {
            ContentView()
        } else {
            ZStack {
                switch vm.step {
                case .welcome:
                    WelcomeScreen {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { vm.step = .interests }
                    }
                    .matchedGeometryEffect(id: "step", in: animation)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                case .interests:
                    InterestSelectionScreen(selected: $vm.selectedInterests) {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { vm.step = .location }
                    }
                    .matchedGeometryEffect(id: "step", in: animation)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                case .location:
                    LocationPreferenceScreen(locationPref: $vm.locationPreference) {
                        if vm.locationPreference == true {
                            locationManager.requestLocationPermission()
                        } else {
                            withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { vm.step = .manualLocation }
                        }
                    }
                    .matchedGeometryEffect(id: "step", in: animation)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                case .confirmLocation:
                    ConfirmLocationScreen(location: locationManager.currentAddress ?? "Unknown") {
                        selectedHobbiesString = vm.selectedInterests.joined(separator: ",")
                        locationPref = true
                        onboardingComplete = true
                    } onBack: {
                        withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) { vm.step = .location }
                    }
                    .matchedGeometryEffect(id: "step", in: animation)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                case .manualLocation:
                    VStack(spacing: 24) {
                        Text("Select your location manually (feature coming soon)")
                        Button("Continue") {
                            selectedHobbiesString = vm.selectedInterests.joined(separator: ",")
                            locationPref = false
                            onboardingComplete = true
                        }
                    }
                    .matchedGeometryEffect(id: "step", in: animation)
                    .transition(.asymmetric(insertion: .scale.combined(with: .opacity), removal: .opacity))
                }
            }
            .onChange(of: locationManager.authorizationStatus) { _, newStatus in
                if newStatus == .authorizedWhenInUse || newStatus == .authorizedAlways {
                    withAnimation(.spring(response: 0.7, dampingFraction: 0.8)) {
                        vm.step = .confirmLocation
                    }
                }
            }
            .animation(.easeInOut, value: vm.step)
        }
    }
}

struct WelcomeScreen: View {
    var onTap: () -> Void
    @State private var animate = false
    var body: some View {
        ZStack {
            Color.blue.ignoresSafeArea()
            VStack(spacing: 40) {
                Spacer()
                Text("Welcome to Buddiee!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 40)
                    .animation(.easeOut(duration: 1), value: animate)
                Text("This app is designed for you to get a buddy in YOUR field of Interest :)")
                    .font(.title2)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .opacity(animate ? 1 : 0)
                    .offset(y: animate ? 0 : 40)
                    .animation(.easeOut(duration: 1.2), value: animate)
                Spacer()
                Text("(tap)")
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.bottom, 40)
                    .opacity(animate ? 1 : 0)
                    .animation(.easeIn(duration: 1.5), value: animate)
            }
        }
        .onAppear { animate = true }
        .onTapGesture { onTap() }
    }
}

let interestOptions = [
    "Study", "Light Trekking", "Photography", "Gym", "Day Outing", "Others"
]

struct InterestSelectionScreen: View {
    @Binding var selected: Set<String>
    var onContinue: () -> Void
    @State private var animate = false
    var body: some View {
        VStack(spacing: 24) {
            Text("I'm currently interested to find a buddy in...")
                .font(.title2)
                .fontWeight(.semibold)
                .opacity(animate ? 1 : 0)
                .animation(.easeIn(duration: 0.7), value: animate)
            VStack(spacing: 16) {
                ForEach(interestOptions, id: \.self) { interest in
                    Button(action: {
                        if selected.contains(interest) {
                            selected.remove(interest)
                        } else {
                            selected.insert(interest)
                        }
                    }) {
                        HStack {
                            Text(interest)
                                .font(.headline)
                                .foregroundColor(selected.contains(interest) ? .white : .blue)
                            Spacer()
                            if selected.contains(interest) {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.white)
                            }
                        }
                        .padding()
                        .background(selected.contains(interest) ? Color.blue : Color.white)
                        .cornerRadius(12)
                        .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .scaleEffect(animate ? 1 : 0.95)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: animate)
                }
            }
            .padding(.horizontal)
            Spacer()
            Button(action: {
                if !selected.isEmpty { onContinue() }
            }) {
                Text("Continue")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selected.isEmpty ? Color.gray : Color.blue)
                    .cornerRadius(12)
            }
            .disabled(selected.isEmpty)
            .padding(.horizontal)
            .opacity(animate ? 1 : 0)
            .animation(.easeIn(duration: 1), value: animate)
        }
        .padding(.top, 60)
        .onAppear { animate = true }
    }
}

struct LocationPreferenceScreen: View {
    @Binding var locationPref: Bool?
    var onContinue: () -> Void
    @State private var animate = false
    var body: some View {
        VStack(spacing: 32) {
            Text("Do you want your buddy to be around you?")
                .font(.title2)
                .fontWeight(.semibold)
                .opacity(animate ? 1 : 0)
                .animation(.easeIn(duration: 0.7), value: animate)
            HStack(spacing: 32) {
                Button(action: {
                    locationPref = true
                    onContinue()
                }) {
                    Text("Yes")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 120, height: 50)
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                Button(action: {
                    locationPref = false
                    onContinue()
                }) {
                    Text("No")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(width: 120, height: 50)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
            }
            .opacity(animate ? 1 : 0)
            .animation(.easeIn(duration: 1), value: animate)
            Spacer()
        }
        .padding(.top, 120)
        .onAppear { animate = true }
    }
}

struct ConfirmLocationScreen: View {
    let location: String
    var onConfirm: () -> Void
    var onBack: () -> Void
    var body: some View {
        VStack(spacing: 32) {
            Text("Is this your current location?")
                .font(.title2)
                .fontWeight(.semibold)
            Text(location)
                .font(.title3)
                .foregroundColor(.blue)
                .multilineTextAlignment(.center)
                .padding()
            HStack(spacing: 24) {
                Button(action: onBack) {
                    Text("No, go back")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding()
                        .background(Color.gray.opacity(0.15))
                        .cornerRadius(12)
                }
                Button(action: onConfirm) {
                    Text("Yes, that's correct")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(40)
    }
} 