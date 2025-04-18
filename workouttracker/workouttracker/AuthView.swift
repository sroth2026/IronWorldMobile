//
//  AuthView.swift
//  workouttracker
//
//  Created by Admin on 4/18/25.
//


import SwiftUI

struct AuthView: View {
    @State private var showLogin = true
    var body: some View {
        VStack {
            if showLogin {
                LoginView(showLogin: $showLogin)
            } else {
                SignUpView(showLogin: $showLogin)
            }
        }
    }
}
