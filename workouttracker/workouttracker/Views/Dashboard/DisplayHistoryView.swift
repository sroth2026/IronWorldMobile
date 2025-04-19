import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct WorkoutSummary: Identifiable {
    let id = UUID()
    let type: String
    let detail: String
}

struct DisplayHistoryView: View {
    @AppStorage("uid") var userID = ""
    @State private var selectedDate = Date()
    @State private var workouts: [WorkoutSummary] = []

    var body: some View {
        VStack {
            Text("Workout History")
                .font(.title2)
                .bold()
                .padding(.top)

            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate, initial: true) { _, _ in
                    fetchWorkouts()
                }
                .padding(.horizontal)

            if workouts.isEmpty {
                Text("No workouts on this day.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(workouts) { workout in
                    HStack {
                        Text("• \(workout.type.capitalized)")
                            .bold()
                        Spacer()
                        Text(workout.detail)
                            .foregroundColor(.secondary)
                    }
                }
                .listStyle(.insetGrouped)
            }

            Spacer()
        }
        .onAppear {
            fetchWorkouts()
        }
    }

    func fetchWorkouts() {
        guard !userID.isEmpty else { return }

        let db = Firestore.firestore()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        let workoutTypes = ["swim", "bike", "run", "lifts"]
        workouts = []

        for type in workoutTypes {
            db.collection("users").document(userID).collection(type)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                .whereField("date", isLessThan: Timestamp(date: endOfDay))
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }

                    for doc in docs {
                        let data = doc.data()
                        var summary = ""

                        switch type {
                        case "swim", "bike", "run":
                            let time = data["time"] as? Int ?? 0
                            let dist = data["distance"] as? Double ?? 0
                            summary = "\(time) min, \(String(format: "%.1f", dist)) mi"
                        case "lifts":
                            let muscle = data["muscleGroup"] as? String ?? "Lift"
                            summary = muscle
                        default:
                            break
                        }

                        workouts.append(WorkoutSummary(type: type, detail: summary))
                    }

                    workouts.sort { $0.type < $1.type }
                }
        }
    }
}
