//
//  DashboardView.swift
//  workouttracker
//
//  Created by Admin on 4/18/25.
//

import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    @AppStorage("uid") var userID = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Welcome to IronWorld 🏋️‍♂️")
                .font(.title)

            Button("Log Out") {
                try? Auth.auth().signOut()
                userID = ""
            }
            .foregroundColor(.red)
        }
    }
}
