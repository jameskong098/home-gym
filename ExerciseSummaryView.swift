import SwiftUI

struct ExerciseSummaryView: View {
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

            Button(action: {
                // Navigate back to the main view
            }) {
                Text("Done")
                    .font(.title2)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
