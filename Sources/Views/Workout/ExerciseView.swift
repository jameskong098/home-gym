import SwiftUI
import Vision
import AVFoundation

struct ExerciseView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var repCount: Int = 0
    @State private var showTutorial = true
    @State private var isPaused = true
    @State private var showPauseMessage = false
    @AppStorage("enableTutorials") private var enableTutorials = true
    @AppStorage("enableAutomaticTimer") private var enableAutomaticTimer = true
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    let exerciseName: String

    var body: some View {
        ZStack {
            CameraView(exerciseName: exerciseName, repCount: $repCount, showTutorial: $showTutorial)
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
                                
                                Text("Place your device on a stable surface, angled toward your workout area. Ensure good lighting conditions for the most accurate tracking. Avoid wearing flowing/robe-like clothing along with densely crowded backgrounds. T-shirts and shorts/tights are ideal.")
                                    .multilineTextAlignment(.center)
                                    .font(.body)
                                    .foregroundColor(.white.opacity(0.9))
                                    .padding(.horizontal)
                                    .lineLimit(nil)
                                    .fixedSize(horizontal: false, vertical: true)
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
                        
                        VStack {
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    if !enableAutomaticTimer || repCount > 0 {
                                        isPaused.toggle()
                                        if isPaused {
                                            stopTimer()
                                        } else {
                                            startTimer()
                                        }
                                    } else {
                                        showPauseMessage = true
                                    }
                                }) {
                                    Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                                        .font(.system(size: 30))
                                        .foregroundColor(!enableAutomaticTimer || repCount > 0 ? .white : .white.opacity(0.5))
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                }
            
                                .alert("Start your exercise!", isPresented: $showPauseMessage) {
                                    Button("OK", role: .cancel) { }
                                } message: {
                                    Text("The timer will automatically start when your first rep is tracked.")
                                }
                                
                                Spacer()
                                
                                Text("\(repCount)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                                
                                Spacer()
                                
                                Button(action: {
                                   let encodedString = "\(exerciseName)|\(repCount)|\(elapsedTime)"
                                   navPath.append("ExerciseSummaryView|\(encodedString)")
                                }) {
                                    Image(systemName: "stop.circle")
                                        .font(.system(size: 30))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(Color.blue.opacity(0.8))
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 30)
                        }
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
                            Button(action: {
                                if !enableAutomaticTimer || repCount > 0 {
                                    isPaused.toggle()
                                    if isPaused {
                                        stopTimer()
                                    } else {
                                        startTimer()
                                    }
                                } else {
                                    showPauseMessage = true
                                }
                            }) {
                                Image(systemName: isPaused ? "play.circle.fill" : "pause.circle.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(!enableAutomaticTimer || repCount > 0 ? .white : .white.opacity(0.5))
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                            }
        
                            .alert("Start your exercise!", isPresented: $showPauseMessage) {
                                Button("OK", role: .cancel) { }
                            } message: {
                                Text("The timer will automatically start when your first rep is tracked.")
                            }
                            
                            Spacer()
                            
                            Text("\(repCount)")
                                .font(.system(size: 72, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding()
                                .background(Color.blue.opacity(0.8))
                                .cornerRadius(15)
                                .shadow(radius: 10)
                            
                            Spacer()
                            
                            Button(action: {
                               let encodedString = "\(exerciseName)|\(repCount)|\(elapsedTime)"
                               navPath.append("ExerciseSummaryView|\(encodedString)")
                            }) {
                                Image(systemName: "stop.circle")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onChange(of: repCount) { newValue in
            if newValue > 0 && timer == nil && enableAutomaticTimer {
                isPaused.toggle()
                startTimer()
            }
        }
        .onDisappear {
            stopTimer()
        }
    }

    private var exerciseInstructions: String {
        switch exerciseName {
        case "High Knees":
            return "Stand facing the camera with your full body visible. Alternate lifting each knee up towards your chest in a running motion. Each time both knees have been raised counts as one rep. Keep a steady pace and maintain good posture throughout the exercise."
        case "Basic Squats":
            return "Position your body so that it is parallel to the camera with feet shoulder-width apart. Keep your full body visible and perform squats by bending your knees while keeping your back straight. Lower yourself until your thighs are parallel to the ground, then return to standing position."
        case "Lunges":
            return "Position your body facing parallel to the camera. Step forward with one leg and lower your body until both knees form 90-degree angles. Return to the starting position and repeat with the other leg. Keep your full body visible to the camera."
        case "Wall Squats":
            return "Position your body so that it is parallel to the camera. Position your feet about 2 feet away from the wall, shoulder-width apart. Slide down the wall until your thighs are parallel to the ground, maintain this position, then push back up. Keep your full body visible to the camera."
        case "Push-Ups":
            return "Position your body facing the camera. Get your whole body in view and assume the push-up position. Maintain eye contact with the screen during your reps."
        case "Pilates Sit-Ups Hybrid":
            return "Position your body so that it is parallel to the camera. Lie on your back with knees bent and feet flat on the ground. This is a pilates roll up and sits up hybrid, so you should stretch your arms out straight in front as you roll up and sit up. Keep your core tight and body visible to the camera."
        case "Bicep Curls - Simultaneous":
            return "Position your body facing the camera with arms at your sides. Keep your upper body steady and perform controlled curls at the same time with your full arms visible."
        case "Jumping Jacks":
            return "Position your body facing the camera with feet together and arms at your sides. Ensure your full body stays in view while performing the exercise."
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
    
    private struct ControlButtonStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .font(.system(size: 30))
                .foregroundColor(.white)
                .padding(20)
                .background(
                    Circle()
                        .fill(Color.black.opacity(0.6))
                        .shadow(color: .black.opacity(0.3), radius: 5)
                )
                .transition(.scale)
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
