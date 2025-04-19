//
//  DisplayProgressView.swift
//  workouttracker
//
//  Created by Admin on 4/18/25.
//

import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct DisplayProgressView: View {
    @AppStorage("uid") var userID = ""
    @State private var swimCount = 0
    @State private var bikeCount = 0
    @State private var runCount = 0
    @State private var liftCount = 0

    var body: some View {
        VStack(spacing: 8) {
            Text("This Week's Progress")
                .font(.headline)

            HStack {
                ProgressBubble(label: "Swim", count: swimCount, color: .green)
                ProgressBubble(label: "Bike", count: bikeCount, color: .orange)
                ProgressBubble(label: "Run", count: runCount, color: .purple)
                ProgressBubble(label: "Lift", count: liftCount, color: .blue)
            }
        }
        .onAppear {
            fetchWorkoutCounts()
        }
    }

    func fetchWorkoutCounts() {
        guard !userID.isEmpty else { return }
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: Date())) ?? Date()

        for type in ["swim", "bike", "run", "lifts"] {
            db.collection("users").document(userID).collection(type)
                .whereField("date", isGreaterThan: Timestamp(date: startOfWeek))
                .getDocuments { snapshot, error in
                    guard let count = snapshot?.documents.count else { return }
                    switch type {
                    case "swim": swimCount = count
                    case "bike": bikeCount = count
                    case "run": runCount = count
                    case "lifts": liftCount = count
                    default: break
                    }
                }
        }
    }
}

struct ProgressBubble: View {
    var label: String
    var count: Int
    var color: Color

    var body: some View {
        VStack {
            Text("\(count)")
                .font(.title2)
                .bold()
                .foregroundColor(.white)
                .frame(width: 60, height: 60)
                .background(color)
                .clipShape(Circle())

            Text(label)
                .font(.caption)
        }
    }
}
