//
//  SignUpView.swift
//  workouttracker
//
//  Created by Admin on 4/18/25.
//

import SwiftUI
import FirebaseAuth

struct SignUpView: View {
    @Binding var showLogin: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var error = ""
    
    @AppStorage("uid") var userID = ""
    var body: some View {
        VStack(spacing: 20) {
            Text("Sign Up")
                .font(.largeTitle).bold()
            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            SecureField("Confirm Password", text: $confirmPassword)
                .textFieldStyle(.roundedBorder)
            
            if !error.isEmpty {
                Text(error).foregroundColor(.red)
            }
            
            Button("Sign Up") {
                signUp()
            }
            .buttonStyle(.borderedProminent)

            Button("Already have an account? Log in") {
                showLogin = true
            }
        }
        .padding()
        
    }
    
    
    func signUp() {
        error = ""
        guard password == confirmPassword else {
            error = "Passwords do not match."
            return
        }
        guard password.count >= 6 else {
            error = "Password too weak (min 6 characters)."
            return
        }

        Auth.auth().createUser(withEmail: email, password: password) { result, err in
            if let err = err {
                error = err.localizedDescription
                return
            }
            userID = result?.user.uid ?? ""
        }
    }
}
