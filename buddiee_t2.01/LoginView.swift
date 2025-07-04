import SwiftUI

struct LoginView: View {
    @State private var showEmailSheet = false
    var onLoginSuccess: (() -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            Text("Welcome to Buddiee!")
                .font(.largeTitle)
                .bold()
                .shadow(radius: 4)
            Spacer()
            // Sign in with Apple button
            Button(action: {
                // Apple sign-in logic here (to be implemented)
            }) {
                HStack {
                    Image(systemName: "applelogo")
                    Text("Sign in with Apple")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color(.systemGray6))
                .foregroundColor(.black)
                .cornerRadius(12)
            }
            .padding(.horizontal)
            // Sign in with email button (smaller)
            Button(action: {
                showEmailSheet = true
            }) {
                Text("Sign in with your email address")
                    .font(.footnote)
                    .foregroundColor(.accentColor)
                    .underline()
            }
            .padding(.bottom, 40)
            .sheet(isPresented: $showEmailSheet) {
                EmailSignInSheet(onLoginSuccess: onLoginSuccess)
            }
            Spacer()
            Button("Skip") {
                UserDefaults.standard.set(true, forKey: "isGuest")
                onLoginSuccess?()
            }
            .font(.footnote)
            .foregroundColor(.gray)
        }
        .padding()
    }
}

struct EmailSignInSheet: View {
    @State private var email = ""
    @State private var code = ""
    @State private var showCodeField = false
    @State private var errorMessage: String?
    var onLoginSuccess: (() -> Void)?

    private var isEmailValid: Bool {
        // Simple regex for email validation
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        let emailPred = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                if !showCodeField {
                    TextField("Enter your email", text: $email)
                        .autocapitalization(.none)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Send Verification Code") {
                        if isEmailValid {
                            showCodeField = true
                            errorMessage = nil
                        } else {
                            errorMessage = "Please type in a valid email address."
                        }
                    }
                    .disabled(email.isEmpty)
                    if let error = errorMessage {
                        Text(error)
                            .foregroundColor(.red)
                    }
                } else {
                    Text("Enter the 6-digit code sent to your email")
                    TextField("123456", text: $code)
                        .keyboardType(.numberPad)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                    Button("Verify") {
                        if code == "123456" {
                            UserDefaults.standard.set(false, forKey: "isGuest")
                            onLoginSuccess?()
                        } else {
                            errorMessage = "Invalid code. Try 123456."
                        }
                    }
                    if let error = errorMessage, showCodeField {
                        Text(error)
                            .foregroundColor(.red)
                    }
                }
                Spacer()
            }
            .padding()
            .navigationTitle("Email Sign In")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
} 