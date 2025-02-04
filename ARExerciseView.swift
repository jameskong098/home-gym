import SwiftUI
import ARKit
import Vision

struct ARExerciseView: View {
    let exerciseName: String
    @State private var elapsedTime: TimeInterval = 0
    @State private var timer: Timer?
    @State private var repCount: Int = 0

    var body: some View {
        ZStack {
            ARCameraView(exerciseName: exerciseName, repCount: $repCount)
                .edgesIgnoringSafeArea(.all)
            
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
        .onAppear {
            startTimer()
        }
        .onDisappear {
            stopTimer()
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
