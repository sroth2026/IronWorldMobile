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
    @State private var workoutDays: [Date: Set<String>] = [:]


    var body: some View {
        VStack {
            Text("Workout History")
                .font(.title2)
                .bold()
                .padding(.top)

            DatePicker("Select Date", selection: $selectedDate, displayedComponents: [.date])
                .datePickerStyle(.graphical)
                .onChange(of: selectedDate, initial: true) {
                    fetchWorkouts()
                }
                .padding(.horizontal)
            
            if let types = workoutDays[Calendar.current.startOfDay(for: selectedDate)] {
                HStack {
                    if types.contains("swim") { Circle().fill(.green).frame(width: 10, height: 10) }
                    if types.contains("bike") { Circle().fill(.orange).frame(width: 10, height: 10) }
                    if types.contains("run")  { Circle().fill(.purple).frame(width: 10, height: 10) }
                    if types.contains("lifts") { Circle().fill(.blue).frame(width: 10, height: 10) }
                }
                .padding(.top, 5)
            }

            if workouts.isEmpty {
                Text("No workouts on this day.")
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List(workouts) { workout in
                    HStack {
                        Text("\(workout.type.capitalized)")
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
    }

    func fetchWorkouts() {
        guard !userID.isEmpty else { return }
        workouts = []
        let db = Firestore.firestore()
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        let newWorkouts: [WorkoutSummary] = []
        let group = DispatchGroup()

        for type in ["swim", "bike", "run", "lifts"] {
            db.collection("users").document(userID).collection(type)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
                .whereField("date", isLessThan: Timestamp(date: endOfDay))
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }

                    for doc in docs {
                        let data = doc.data()
                        var summary = ""

                        // Add to display list
                        switch type {
                        case "swim", "bike", "run":
                            let time = data["time"] as? Int ?? 0
                            let dist = data["distance"] as? Double ?? 0
                            summary = "\(time) min, \(String(format: "%.1f", dist)) mi"
                        case "lifts":
                            let muscle = data["muscleGroup"] as? String ?? "Lift"
                            summary = muscle
                        default: break
                        }

                        workouts.append(WorkoutSummary(type: type, detail: summary))
                    }

                    workouts.sort { $0.type < $1.type }
                }
        }
        
        group.notify(queue: .main) {
            self.workouts = newWorkouts.sorted { $0.type < $1.type }
        }

        // Populate calendar dots
        let dateRangeStart = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
        let now = Date()

        for type in ["swim", "bike", "run", "lifts"] {
            db.collection("users").document(userID).collection(type)
                .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: dateRangeStart))
                .whereField("date", isLessThanOrEqualTo: Timestamp(date: now))
                .getDocuments { snapshot, error in
                    guard let docs = snapshot?.documents else { return }

                    for doc in docs {
                        if let ts = doc.data()["date"] as? Timestamp {
                            let day = calendar.startOfDay(for: ts.dateValue())
                            if workoutDays[day] != nil {
                                workoutDays[day]?.insert(type)
                            } else {
                                workoutDays[day] = [type]
                            }
                        }
                    }
                }
        }
    }

}
