import SwiftUI
import ARKit
import Vision

struct ARExerciseView: View {
    let exerciseName: String
    
    var body: some View {
        ZStack {
            ARCameraView(exerciseName: exerciseName)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                Text(exerciseName)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(10)
                    .padding(.top)
                Spacer()
            }
        }
    }
}
