import SwiftUI

struct ExerciseSummaryView: View {
    @Environment(\.presentationMode) var presentationMode
    let exerciseName: String
    let repCount: Int
    let elapsedTime: TimeInterval

    var body: some View {
        VStack(spacing: 20) {
            Text("Exercise Summary")
                .font(.largeTitle)
                .fontWeight(.bold)

            Text("Exercise: \(exerciseName)")
                .font(.title2)

            Text("Reps: \(repCount)")
                .font(.title2)

            Text("Time: \(timeString(from: elapsedTime))")
                .font(.title2)

            Spacer()

            VStack(spacing: 15) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Back to Workouts")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }

                NavigationLink(destination: ActivityView().navigationBarHidden(true)) {
                    Text("Go to Activity")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 30)
        }
        .padding()
        .navigationBarHidden(true)
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
