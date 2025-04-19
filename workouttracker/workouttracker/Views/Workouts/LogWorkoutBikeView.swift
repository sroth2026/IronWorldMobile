//
//  LogWorkoutBikeView.swift
//  workouttracker
//
//  Created by Admin on 4/18/25.
//


import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LogWorkoutBikeView: View {
    @AppStorage("uid") var userID = ""
    @Environment(\.dismiss) var dismiss

    @State private var date = Date()
    @State private var time = ""
    @State private var distance = ""
    @State private var heartrate = ""
    @State private var notes = ""
    @State private var message = ""

    var body: some View {
        Form {
            Section(header: Text("Bike Info")) {
                DatePicker("Date", selection: $date, displayedComponents: .date)
                TextField("Total Time (minutes)", text: $time)
                    .keyboardType(.numberPad)
                TextField("Distance (miles)", text: $distance)
                    .keyboardType(.decimalPad)
                TextField("Heart Rate (bpm)", text: $heartrate)
                    .keyboardType(.numberPad)
            }

            Section(header: Text("Notes")) {
                TextField("Any notes...", text: $notes)
            }

            Section {
                HStack {
                    Spacer()
                    Button("Submit Bike Workout") {
                        saveWorkout()
                    }
                    .buttonStyle(.borderedProminent)
                    Spacer()
                }
            }

            if !message.isEmpty {
                Text(message)
                    .foregroundColor(.green)
            }
        }
        .navigationTitle("Log Bike")
    }

    func saveWorkout() {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "User not logged in"
            return
        }

        let db = Firestore.firestore()
        let data: [String: Any] = [
            "date": Timestamp(date: date),
            "time": Int(time) ?? 0,
            "distance": Double(distance) ?? 0,
            "heartrate": Int(heartrate) ?? 0,
            "notes": notes
        ]

        db.collection("users").document(uid).collection("bike").addDocument(data: data) { err in
            if let err = err {
                message = "Error: \(err.localizedDescription)"
            } else {
                message = "Bike workout saved!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}
