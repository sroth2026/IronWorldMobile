import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct LiftSet: Identifiable, Equatable {
    let id: UUID
    var weight: String
    var reps: String

    init(id: UUID = UUID(), weight: String, reps: String) {
        self.id = id
        self.weight = weight
        self.reps = reps
    }
}

struct LiftEntry: Identifiable, Equatable {
    let id: UUID
    var name: String
    var sets: [LiftSet]

    init(id: UUID = UUID(), name: String, sets: [LiftSet]) {
        self.id = id
        self.name = name
        self.sets = sets
    }
}

struct LogWorkoutLiftView: View {
    @AppStorage("uid") var userID = ""
    @Environment(\.dismiss) var dismiss

    @State private var date = Date()
    @State private var muscleGroup = ""
    @State private var notes = ""
    @State private var message = ""

    @State private var lifts: [LiftEntry] = [
        LiftEntry(name: "", sets: [LiftSet(weight: "", reps: "")])
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Log Lift Workout")
                    .font(.largeTitle.bold())
                    .padding(.top)

                // Date + Muscle Group
                DatePicker("Date", selection: $date, displayedComponents: .date)
                    .datePickerStyle(.compact)
                TextField("Muscle Group", text: $muscleGroup)
                    .textFieldStyle(.roundedBorder)

                // Each Lift Entry
                ForEach(Array(lifts.enumerated()), id: \.element.id) { index, _ in
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Lift Name", text: $lifts[index].name)
                            .font(.headline)
                            .textFieldStyle(.roundedBorder)

                        ForEach(Array(lifts[index].sets.enumerated()), id: \.element.id) { setIndex, _ in
                            HStack {
                                TextField("Weight", text: $lifts[index].sets[setIndex].weight)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)

                                TextField("Reps", text: $lifts[index].sets[setIndex].reps)
                                    .keyboardType(.numberPad)
                                    .textFieldStyle(.roundedBorder)

                                Button {
                                    lifts[index].sets.remove(at: setIndex)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }

                        Button("➕ Add Set") {
                            lifts[index].sets.append(LiftSet(weight: "", reps: ""))
                        }
                        .font(.caption)

                        Button("❌ Remove This Lift") {
                            lifts.remove(at: index)
                        }
                        .font(.caption)
                        .foregroundColor(.red)

                        Divider()
                    }
                }

                Button("➕ Add New Lift") {
                    lifts.append(LiftEntry(name: "", sets: [LiftSet(weight: "", reps: "")]))
                }
                .padding(.vertical)

                TextField("Any notes...", text: $notes)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    Spacer()
                    Button("Submit Workout") {
                        saveWorkout()
                    }
                    Spacer()
                }
                .buttonStyle(.borderedProminent)
                .padding(.top)

                if !message.isEmpty {
                    Text(message)
                        .foregroundColor(.green)
                }

                Spacer()
            }
            .padding()
        }
    }

    func saveWorkout() {
        guard let uid = Auth.auth().currentUser?.uid else {
            message = "User not logged in"
            return
        }

        let db = Firestore.firestore()

        let liftData = lifts.map { lift in
            return [
                "name": lift.name,
                "sets": lift.sets.map { set in
                    return [
                        "weight": Int(set.weight) ?? 0,
                        "reps": Int(set.reps) ?? 0
                    ]
                }
            ]
        }

        let workoutData: [String: Any] = [
            "date": Timestamp(date: date),
            "muscleGroup": muscleGroup,
            "notes": notes,
            "lifts": liftData
        ]

        db.collection("users").document(uid).collection("lifts").addDocument(data: workoutData) { err in
            if let err = err {
                message = "Error: \(err.localizedDescription)"
            } else {
                message = "Workout saved!"
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }
}
