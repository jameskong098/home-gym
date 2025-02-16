import SwiftUI
import Vision
import AVFoundation

struct ExerciseView: View {
    @State private var elapsedTime: TimeInterval = 0
    @State private var caloriesBurned: Double = 0.0
    @State private var timer: Timer?
    @State private var repCount: Int = 0
    @State private var showTutorial = true
    @State private var isPaused = true
    @State private var showEndWorkoutAlert = false
    @AppStorage("enableTutorials") private var enableTutorials = true
    @AppStorage("enableCountdownTimer") private var enableCountdownTimer = true
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    let exerciseName: String
    let hudBackgroundColor = Color.black.opacity(0.4)
    @State private var countdownTime: Int = 5
    @State private var showCountdown: Bool = false
    @State private var countdownTimer: Timer?
    @State private var countdownProgress: Double = 1.0
    @State private var smoothCountdownTimer: Timer?

    var body: some View {
        ZStack {
            CameraView(exerciseName: exerciseName, repCount: $repCount, showTutorial: $showTutorial)
                .edgesIgnoringSafeArea(.all)
                .blur(radius: showCountdown ? 10 : 0)

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
                            
                            Button(action: {
                                showTutorial = false
                                if enableCountdownTimer {
                                    startCountdown()
                                } else {
                                    isPaused = false
                                    startTimer()
                                }
                            }) {
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
                if showCountdown {
                    VStack {
                        TimeCircularProgressBar(progress: countdownProgress, color: .blue, countdownTime: countdownTime)
                            .frame(width: 200, height: 200) 
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black.opacity(0.5).edgesIgnoringSafeArea(.all))
                    .transition(.opacity.combined(with: .scale))
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
                                .background(hudBackgroundColor)
                                .cornerRadius(20)
                                .shadow(radius: 10)
                                
                                Spacer()
                                
                                HStack {
                                    VStack {
                                        HStack(spacing: 5) {
                                            Image(systemName: "timer")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                                .padding(.top)
                                                .padding(.leading)
                                            Text(timeString(from: elapsedTime))
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.top)
                                                .padding(.trailing)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Text(String(format: "%.2f", caloriesBurned))
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Cals")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.bottom)
                                    }
                                    .background(hudBackgroundColor)
                                    .cornerRadius(20)
                                    .shadow(radius: 10)
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            
                            Spacer()
                            
                            VStack {
                                Spacer()
                                
                                HStack {
                                    Button(action: {
                                        isPaused.toggle()
                                        if isPaused {
                                            stopTimer()
                                        } else {
                                            startTimer()
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(!isPaused ? .orange : .green)
                                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                                .frame(width: 20, height: 20)
                                                .foregroundStyle(.white)
                                        }
                                        .frame(width: 35, height: 35)
                                        .padding()
                                        .background(hudBackgroundColor)
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                    }
                                    
                                    Spacer()
                                    
                                    Text("\(repCount)")
                                        .font(.system(size: 72, weight: .bold, design: .rounded))
                                        .foregroundColor(.white)
                                        .padding()
                                        .background(hudBackgroundColor)
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                    
                                    Spacer()
                                    
                                    Button(action: {
                                        showEndWorkoutAlert = true
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(.red)
                                            Image(systemName: "xmark")
                                                .frame(width: 10, height: 10)
                                                .foregroundStyle(.white)
                                        }
                                        .frame(width: 35, height: 35)
                                        .padding()
                                        .background(hudBackgroundColor)
                                        .cornerRadius(15)
                                        .shadow(radius: 10)
                                    }
                                    .alert("End Workout", isPresented: $showEndWorkoutAlert) {
                                        Button("Cancel", role: .cancel) { }
                                        Button("End", role: .destructive) {
                                            let encodedString = "\(exerciseName)|\(repCount)|\(elapsedTime)|\(caloriesBurned)"
                                            navPath.append("ExerciseSummaryView|\(encodedString)")
                                        }
                                    } message: {
                                        Text("Are you sure you want to end this workout?")
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
                                
                                HStack {
                                    VStack {
                                        HStack(spacing: 5) {
                                            Image(systemName: "timer")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                                .padding(.top)
                                                .padding(.leading)
                                            Text(timeString(from: elapsedTime))
                                                .font(.largeTitle)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                                .padding(.top)
                                                .padding(.trailing)
                                        }
                                        
                                        HStack(spacing: 8) {
                                            Text(String(format: "%.2f", caloriesBurned))
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                            Text("Cals")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.orange)
                                        }
                                        .padding(.bottom)
                                    }
                                }
                            }
                            .background(hudBackgroundColor)
                            .cornerRadius(20)
                            .padding(.horizontal, 25)
                            .padding(.vertical, 10)
                            .shadow(radius: 10)
                            
                            Spacer()
                            
                            HStack {
                                Button(action: {
                                    isPaused.toggle()
                                    if isPaused {
                                        stopTimer()
                                    } else {
                                        startTimer()
                                    }
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(!isPaused ? .orange : .green)
                                        Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                            .frame(width: 20, height: 20)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(width: 35, height: 35)
                                    .padding()
                                    .background(hudBackgroundColor)
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                                }
                                
                                Spacer()
                                
                                Text("\(repCount)")
                                    .font(.system(size: 72, weight: .bold, design: .rounded))
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(hudBackgroundColor)
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                                
                                Spacer()
                                
                                Button(action: {
                                    showEndWorkoutAlert = true
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(.red)
                                        Image(systemName: "xmark")
                                            .frame(width: 10, height: 10)
                                            .foregroundStyle(.white)
                                    }
                                    .frame(width: 35, height: 35)
                                    .padding()
                                    .background(hudBackgroundColor)
                                    .cornerRadius(15)
                                    .shadow(radius: 10)
                                }
                                .alert("End Workout", isPresented: $showEndWorkoutAlert) {
                                    Button("Cancel", role: .cancel) { }
                                    Button("End", role: .destructive) {
                                        let encodedString = "\(exerciseName)|\(repCount)|\(elapsedTime)|\(caloriesBurned)"
                                        navPath.append("ExerciseSummaryView|\(encodedString)")
                                    }
                                } message: {
                                    Text("Are you sure you want to end this workout?")
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 30)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if (!enableTutorials) {
                if enableCountdownTimer {
                    startCountdown()
                } else {
                    isPaused = false
                    startTimer()
                }
            }
        }
        .onDisappear {
            stopTimer()
            smoothCountdownTimer?.invalidate()
            smoothCountdownTimer = nil
            countdownTimer?.invalidate()
            countdownTimer = nil
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
                calculateCaloriesBurned()
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
    
    private func calculateCaloriesBurned() {
        let age = UserDefaults.standard.integer(forKey: "age")
        let sex = UserDefaults.standard.string(forKey: "sex")
        let heightFeet = UserDefaults.standard.integer(forKey: "heightFeet")
        let heightInches = UserDefaults.standard.integer(forKey: "heightInches")
        let bodyWeight = UserDefaults.standard.double(forKey: "bodyWeight")
        
        let height = Double(heightFeet * 12 + heightInches) * 2.54 // Convert to cm
        let weight = bodyWeight * 0.453592 // Convert to kg
        
        var bmr: Double = 0.0
        
        if sex == "Male" {
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        } else {
            bmr = 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
        
        let metValue: Double
        switch exerciseName {
        case "High Knees":
            metValue = 8.0
        case "Basic Squats":
            metValue = 5.0
        case "Lunges":
            metValue = 4.5
        case "Wall Squats":
            metValue = 4.0
        case "Push-Ups":
            metValue = 8.0
        case "Pilates Sit-Ups Hybrid":
            metValue = 3.5
        case "Bicep Curls - Simultaneous":
            metValue = 3.0
        case "Jumping Jacks":
            metValue = 8.0
        default:
            metValue = 4.0
        }
        
        let caloriesPerMinute = (bmr / 1440) * metValue / 60
        caloriesBurned = caloriesPerMinute * (elapsedTime / 60)
    }
    
    private func startCountdown() {
        showCountdown = true
        countdownTime = 5
        countdownProgress = 1.0
        
        smoothCountdownTimer = Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { _ in // 60fps
            DispatchQueue.main.async {
                countdownProgress -= 0.0033 // 5-second drain (0.0033 * 60fps * 5 seconds)
                
                if countdownProgress <= 0 {
                    countdownProgress = 0
                    smoothCountdownTimer?.invalidate()
                    smoothCountdownTimer = nil
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showCountdown = false
                    }
                    isPaused = false
                    startTimer()
                }
            }
        }
        
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            DispatchQueue.main.async {
                if countdownTime > 0 {
                    countdownTime -= 1
                }
            }
        }
    }
}

struct TimeCircularProgressBar: View {
    let progress: Double
    let color: Color
    let countdownTime: Int

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 15)
                .opacity(0.3)
                .foregroundColor(color)

            Circle()
                .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                .stroke(
                    AngularGradient(
                        gradient: Gradient(colors: [
                            color,
                            .blue,
                            .cyan,
                            .mint,
                            .teal
                        ]),
                        center: .center,
                        startAngle: .degrees(0),
                        endAngle: .degrees(360)
                    ),
                    style: StrokeStyle(lineWidth: 15, lineCap: .round, lineJoin: .round)
                )
                .rotationEffect(Angle(degrees: 270.0))
                .animation(.linear, value: progress)
            
            Text(countdownTime == 0 ? "Go!" : "\(countdownTime)")
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(.white)
        }
    }
}
