import SwiftUI

struct Exercise: View {
    var body: some View {
        VStack(spacing: 20) {
            ExerciseButton(name: "Push-Ups", icon: "figure.arms.open")
            ExerciseButton(name: "Sit-Ups", icon: "figure.arms.open")
            ExerciseButton(name: "Planks", icon: "figure.arms.open")
            ExerciseButton(name: "Bicep Curls", icon: "figure.arms.open")
            ExerciseButton(name: "Jumping Jacks", icon: "figure.arms.open")
            Spacer()
        }
        .padding()
    }
}

struct ExerciseButton: View {
    let name: String
    let icon: String
    
    var body: some View {
        NavigationLink(destination: ARExerciseView(exerciseName: name)) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 40, height: 40)
                    .background(Color.blue)
                    .clipShape(Circle())
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(.blue)
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
        }
    }
}
