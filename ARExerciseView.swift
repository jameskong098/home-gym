import SwiftUI
import ARKit
import Vision
import AVFoundation

struct ARExerciseView: View {
    let exerciseName: String
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var repCount: Int = 0
    @State private var showTutorial = true
    @AppStorage("enableTutorials") private var enableTutorials = true

    var body: some View {
        ZStack {
            ARCameraView(exerciseName: exerciseName, repCount: $repCount)
                .edgesIgnoringSafeArea(.all)
            
            if enableTutorials && showTutorial {
                GeometryReader { geometry in
                    VStack {
                        Spacer()
                        
                        VStack(spacing: 20) {
                            VStack(spacing: 10) {
                                Image(systemName: "ipad.and.arrow.forward")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                
                                Text("Device Setup")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                Text("Lean your device against something solid and angle it towards your workout area.")
                                    .multilineTextAlignment(.center)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.5))
                                .padding(.horizontal, 30)
                            
                            VStack(spacing: 10) {
                                Image(systemName: "figure.push")
                                    .font(.system(size: 40))
                                    .foregroundColor(.white)
                                    .padding(.bottom, 5)
                                
                                Text("Exercise Position")
                                    .font(.title2.bold())
                                    .foregroundColor(.white)
                                
                                Text(exerciseInstructions)
                                    .multilineTextAlignment(.center)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal)
                            }
                            
                            Spacer()
                                .frame(height: 20)
                            
                            Button(action: { showTutorial = false }) {
                                HStack {
                                    Text("Start Workout")
                                        .font(.title3.bold())
                                    Image(systemName: "play.fill")
                                }
                                .foregroundColor(.white)
                                .padding(.vertical, 12)
                                .padding(.horizontal, 25)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.7)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .clipShape(Capsule())
                                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            }
                            .buttonStyle(ScaleButtonStyle())
                        }
                        .padding(15)
                        .frame(maxWidth: 400)
                        .background(
                            RoundedRectangle(cornerRadius: 25)
                                .fill(Color.black.opacity(0.85))
                                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
                        )
                        .padding(15)
                        .transition(.opacity)
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height, alignment: .bottom)
                }
            } else {
                if UIDevice.current.userInterfaceIdiom == .pad {
                    VStack {
                        HStack {
                            HStack {
                                Text(exerciseName)
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(radius: 10)
                            
                            Spacer()
                            
                            HStack {
                                Text(timeString(from: elapsedTime))
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                    .padding()
                            }
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(20)
                            .shadow(radius: 10)
                        }
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            VStack {
                                Text("\(repCount)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            Spacer()
                        }
                        .padding(.bottom, 30)
                    }
                } else {
                    VStack {
                        HStack {
                            Text(exerciseName)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                            
                            Spacer()
                            
                            Text(timeString(from: elapsedTime))
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .padding()
                        }
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(20)
                        .padding(.horizontal, 25)
                        .padding(.vertical, 10)
                        .shadow(radius: 10)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            VStack {
                                Text("\(repCount)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.8))
                            .cornerRadius(15)
                            .shadow(radius: 10)
                            Spacer()
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .onChange(of: repCount) { newValue in
            if newValue > 0 {
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var exerciseInstructions: String {
        switch exerciseName {
        case "Push-Ups":
            return "Get your whole body in view and assume the push-up position facing the camera. Maintain eye contact with the screen during your reps."
        case "Sit-Ups":
            return "Lie on your back with knees bent and feet flat on the ground. Keep your upper body visible to the camera throughout the movement."
        case "Planks":
            return "Position your body in a straight line from head to heels, supporting yourself on forearms and toes. Keep your core tight and body visible to the camera."
        case "Bicep Curls":
            return "Stand facing the camera with arms at your sides. Keep your upper body steady and perform controlled curls with your full arms visible."
        case "Jumping Jacks":
            return "Stand facing the camera with feet together and arms at your sides. Ensure your full body stays in view while performing the exercise."
        default:
            return "Position yourself so your full body is visible to the camera throughout the exercise."
        }
    }
    
    private struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.95 : 1)
                .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                elapsedTime += 1
            }
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
