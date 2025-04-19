import SwiftUI
import FirebaseAuth

struct DashboardView: View {
    
    @AppStorage("uid") var userID = ""
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    HStack {
                        Spacer()
                        Image("lionliftlogo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        Spacer()
                    }
                    
                    DisplayProgressView()
                    
                    VStack(spacing: 15) {
                        NavigationLink(destination: LogWorkoutLiftView()) {
                            Text("🏋️ Log a Lift")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: LogWorkoutSwimView()) {
                            Text("🏊 Log a Swim")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.green.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: LogWorkoutBikeView()) {
                            Text("🚴 Log a Bike")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.orange.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: LogWorkoutRunView()) {
                            Text("🏃 Log a Run")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.purple.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                        
                        NavigationLink(destination: DisplayHistoryView()) {
                            Text("🗓️ View Workout Calendar")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.gray.opacity(0.7))
                                .foregroundColor(.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    Button("Log Out") {
                        try? Auth.auth().signOut()
                        userID = ""
                    }
                    .foregroundColor(.red)
                    .padding(.bottom)
                }
            }
        }
    }
}
