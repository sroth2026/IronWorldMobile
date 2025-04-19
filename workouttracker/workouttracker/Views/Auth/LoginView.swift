//
//  LoginView.swift
//  workouttracker
//
//  Created by Admin on 4/18/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Binding var showLogin: Bool
    @State private var email = ""
    @State private var password = ""
    @State private var error = ""

    @AppStorage("uid") var userID = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Log In")
                .font(.largeTitle).bold()

            TextField("Email", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)

            if !error.isEmpty {
                Text(error).foregroundColor(.red)
            }

            Button("Log In") {
                logIn()
            }
            .buttonStyle(.borderedProminent)

            Button("Don't have an account? Sign up") {
                showLogin = false
            }
        }
        .padding()
    }

    func logIn() {
        error = ""
        Auth.auth().signIn(withEmail: email, password: password) { result, err in
            if let err = err {
                error = err.localizedDescription
                return
            }
            userID = result?.user.uid ?? ""
        }
    }
}
