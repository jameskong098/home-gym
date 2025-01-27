import SwiftUI

struct ExerciseMenu: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("Choose Your Exercise")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            ExerciseButton(name: "Push-ups", icon: "figure.pushup")
            ExerciseButton(name: "Sit-ups", icon: "figure.situp")
            ExerciseButton(name: "Planks", icon: "figure.plank")
            ExerciseButton(name: "Bicep Curls", icon: "figure.arms.open")
            
            Spacer()
        }
        .padding()
    }
}

struct ExerciseButton: View {
    let name: String
    let icon: String
    
    var body: some View {
        Button(action: {
            // Navigate to exercise detail screen (to be implemented)
        }) {
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
