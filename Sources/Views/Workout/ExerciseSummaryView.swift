/*
  ExerciseSummaryView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view displays workout completion summary with exercise metrics,
  allowing users to review, edit, and save workout data with animations
  and haptic feedback.
*/

import SwiftUI
import AVFoundation

struct ExerciseSummaryView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    @State private var isEditing = false
    @State private var editedRepCount: Int
    @State private var editedElapsedTime: TimeInterval
    @State private var editedWeight: Double?
    @State private var caloriesBurned: Double
    @State private var showingCancelAlert = false
    @State private var opacity = 1.0
    @State private var audioPlayer: AVAudioPlayer?
    @State private var showingSaveConfirmation = false
    let exerciseName: String
    let repCount: Int
    let elapsedTime: TimeInterval
    let weight: Double?
    private var player: AVAudioPlayer?

    init(selectedTab: Binding<Int>, navPath: Binding<[String]>, exerciseName: String, repCount: Int, elapsedTime: TimeInterval, caloriesBurned: Double, weight: Double? = nil) {
        self._selectedTab = selectedTab
        self._navPath = navPath
        self.exerciseName = exerciseName
        self.repCount = repCount
        self.elapsedTime = elapsedTime
        self.caloriesBurned = caloriesBurned
        self.weight = weight
        self._editedRepCount = State(initialValue: repCount)
        self._editedElapsedTime = State(initialValue: elapsedTime)
        self._editedWeight = State(initialValue: weight)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
                Text("Summary")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.top, 30)

                VStack(spacing: 15) {
                    summaryItem(icon: "figure.walk", title: "Exercise", value: exerciseName)
                    Divider()
                        .background(Color.white)
                    if exerciseName != "Planks" {
                        summaryItem(icon: "repeat", title: "Reps", value: "\(editedRepCount)")
                        Divider()
                            .background(Color.white)
                    }
                    summaryItem(icon: "clock", title: "Time", value: timeString(from: editedElapsedTime))
                    Divider()
                        .background(Color.white)
                    summaryItem(icon: "flame.fill", title: "Calories Burned", value: String(format: "%.2f", caloriesBurned))
                    Divider()
                        .background(Color.white)
                    summaryItem(icon: "scalemass", title: "Weight", value: weightString(from: editedWeight))
                    Text("Weight can include additional weight from equipment such as a weight vest or dumbbells. Click 'Edit' to add or update the value if needed.")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.top, 5)
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 25)
                
                HStack(spacing: 30) {
                    actionButton(title: "Edit", icon: "pencil", color: Theme.footerAccentColor) {
                        isEditing = true
                    }
                    .sheet(isPresented: $isEditing) {
                        EditView(repCount: $editedRepCount,
                                elapsedTime: $editedElapsedTime,
                                weight: $editedWeight,
                                isEditing: $isEditing)
                        .presentationDetents([.height(300)])
                        .interactiveDismissDisabled()
                    }
                    
                    Spacer()

                    actionButton(title: "Delete", icon: "xmark", color: .red) {
                        showingCancelAlert = true
                    }
                    .alert("Cancel Workout", isPresented: $showingCancelAlert) {
                        Button("Cancel", role: .cancel) { }
                        Button("Yes, Delete", role: .destructive) {
                            playSound()
                            dismiss()
                        }
                    } message: {
                        Text("Are you sure you want to delete this workout? This action cannot be undone.")
                    }
                    
                    Spacer()
                    
                    actionButton(title: "Save", icon: "checkmark", color: .green) {
                        saveWorkout()
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 30)
            }
            .opacity(showingSaveConfirmation ? 0 : opacity)
            .animation(.easeInOut(duration: 0.3), value: showingSaveConfirmation)
            
            if showingSaveConfirmation {
                VStack {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.green)
                    Text("Workout Saved")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .padding(25)
                .background(Color.black.opacity(0.8))
                .cornerRadius(15)
                .transition(.scale.combined(with: .opacity))
                .zIndex(1)
            }
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }

    private func summaryItem(icon: String, title: String, value: String) -> some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(Theme.footerAccentColor)
                .frame(width: 30)
            
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            
            Spacer()
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(Theme.footerAccentColor)
        }
    }
    
    private func weightString(from weight: Double?) -> String {
        if let weight = weight {
            return "\(weight) lb"
        } else {
            return "-"
        }
    }

    private func playSound() {
        if let soundURL = Bundle.main.url(forResource: "navigation_transition-left", withExtension: "caf") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
        } else {
            print("Sound file not found")
        }
    }

    struct EditView: View {
        @Binding var repCount: Int
        @Binding var elapsedTime: TimeInterval
        @Binding var weight: Double?
        @Binding var isEditing: Bool
        @State private var temporaryRepCount: Int
        @State private var temporaryTime: TimeInterval
        @State private var temporaryWeight: Double?
        
        init(repCount: Binding<Int>, elapsedTime: Binding<TimeInterval>, weight: Binding<Double?>, isEditing: Binding<Bool>) {
            self._repCount = repCount
            self._elapsedTime = elapsedTime
            self._weight = weight
            self._isEditing = isEditing
            self._temporaryRepCount = State(initialValue: repCount.wrappedValue)
            self._temporaryTime = State(initialValue: elapsedTime.wrappedValue)
            self._temporaryWeight = State(initialValue: weight.wrappedValue)
        }
        
        var body: some View {
            NavigationView {
                Form {
                    Section(header: Text("Workout Details")) {
                        Stepper("Reps: \(temporaryRepCount)", value: $temporaryRepCount, in: 0...1000)
                            .onChange(of: temporaryRepCount) { _ in
                                triggerHapticFeedback()
                            }
                        
                        HStack {
                            Text("Time:")
                            Spacer()
                            
                            HStack {
                                Button("-1s") {
                                    if temporaryTime >= 1 {
                                        temporaryTime -= 1
                                        triggerHapticFeedback()
                                    }
                                }
                                .buttonStyle(.bordered)
                                
                                Text(timeString(from: temporaryTime))
                                    .frame(minWidth: 70)
                                
                                Button("+1s") {
                                    temporaryTime += 1
                                    triggerHapticFeedback()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        
                        HStack {
                            Text("Weight (lb):")
                            Spacer()
                            TextField("Optional", value: $temporaryWeight, format: .number)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .frame(width: 100)
                        }
                    }
                }
                .navigationTitle("Edit Workout").navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        isEditing = false
                    },
                    trailing: Button("Done") {
                        repCount = temporaryRepCount
                        elapsedTime = temporaryTime
                        weight = temporaryWeight
                        isEditing = false
                    }
                )
            }
        }
        
        private func triggerHapticFeedback() {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
        
        private func timeString(from timeInterval: TimeInterval) -> String {
            let minutes = Int(timeInterval) / 60
            let seconds = Int(timeInterval) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }

    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    private func actionButton(title: String, icon: String, color: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.headline)
                if horizontalSizeClass != .compact {
                    Text(title)
                        .font(.headline)
                }
            }
            .foregroundColor(.white)
            .padding(.vertical, 20)
            .padding(.horizontal, 30)
            .background(
                RoundedRectangle(cornerRadius: 25)
                    .fill(color)
            )
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func saveWorkout() {
        let workout = WorkoutData(date: Date(), exerciseName: exerciseName, repCount: editedRepCount, elapsedTime: editedElapsedTime, caloriesBurned: caloriesBurned, weight: editedWeight)
        var savedWorkouts = loadWorkouts()
        savedWorkouts.append(workout)
        if let encoded = try? JSONEncoder().encode(savedWorkouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
        
        if let soundURL = Bundle.main.url(forResource: "hero_simple-celebration-03", withExtension: "caf") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
                audioPlayer?.play()
            } catch {
                print("Failed to play sound: \(error.localizedDescription)")
            }
        }
        
        withAnimation {
            showingSaveConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            selectedTab = 2
            navPath.append("Activity")
        }
        
    }

    private func loadWorkouts() -> [WorkoutData] {
        if let savedData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([WorkoutData].self, from: savedData) {
            return decodedWorkouts
        }
        return []
    }
}
