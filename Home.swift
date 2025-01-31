import SwiftUI

struct HomeScreen: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("🏋️‍♂️ Home Gym")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()

                Text("Your AR-powered personal trainer")
                    .font(.title2)
                    .foregroundColor(.gray)

                NavigationLink(destination: ExerciseMenu()) {
                    Text("Start Workout")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                NavigationLink(destination: ProgressTracker()) {
                    Text("View Progress")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                NavigationLink(destination: SettingsScreen()) {
                    Text("Settings")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .shadow(radius: 5)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding()
        }
    }
}
