import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @AppStorage("uid") var userID = ""
    var body: some View {
        if userID.isEmpty {
            AuthView()
        } else {
            DashboardView()
        }
    }
}
