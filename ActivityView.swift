import SwiftUI

struct ActivityView: View {
    @State private var workouts: [WorkoutData] = []
    @State private var selectedWorkout: WorkoutData?
    @State private var isEditing = false

    var body: some View {
        VStack {
            if workouts.isEmpty {
                Text("Start exercising to see your activity")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            } else {
                List {
                    ForEach(workouts.sorted(by: { $0.date > $1.date })) { workout in
                        VStack(alignment: .leading, spacing: 10) {
                            Text(workout.exerciseName)
                                .font(.headline)
                                .foregroundColor(Theme.footerAccentColor)
                            Text("Reps: \(workout.repCount)")
                                .foregroundColor(Color(UIColor { traitCollection in
                                    if traitCollection.userInterfaceStyle == .dark {
                                        return Theme.settingsThemeTextColorDark
                                    } else {
                                        return Theme.settingsThemeTextColorLight
                                    }
                                }))
                            Text("Duration: \(timeString(from: workout.elapsedTime))")
                                .foregroundColor(Color(UIColor { traitCollection in
                                    if traitCollection.userInterfaceStyle == .dark {
                                        return Theme.settingsThemeTextColorDark
                                    } else {
                                        return Theme.settingsThemeTextColorLight
                                    }
                                }))
                            Text("Date: \(formattedDate(workout.date))")
                                .foregroundColor(Color(UIColor { traitCollection in
                                    if traitCollection.userInterfaceStyle == .dark {
                                        return Theme.settingsThemeTextColorDark
                                    } else {
                                        return Theme.settingsThemeTextColorLight
                                    }
                                }))
                        }
                        .padding(.vertical, 10)
                        .background(Color(UIColor { traitCollection in
                            if traitCollection.userInterfaceStyle == .dark {
                                return Theme.settingsSectionBackgroundColorDark
                            } else {
                                return Theme.settingsSectionBackgroundColorLight
                            }
                        }))
                        .cornerRadius(10)
                        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        .contextMenu {
                            Button(action: {
                                selectedWorkout = workout
                                isEditing = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            Button(action: {
                                deleteWorkout(workout)
                            }) {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
        .padding(.horizontal)
        .onAppear {
            loadWorkouts()
        }
        .sheet(isPresented: $isEditing) {
            if let workout = selectedWorkout {
                SavedDataEditView(workout: workout, isEditing: $isEditing, onSave: { updatedWorkout in
                    updateWorkout(updatedWorkout)
                })
            }
        }
        .onChange(of: isEditing) { newValue in
            if !newValue {
                selectedWorkout = nil
            }
        }
    }

    private func loadWorkouts() {
        if let savedData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([WorkoutData].self, from: savedData) {
            workouts = decodedWorkouts
        }
    }

    private func updateWorkout(_ updatedWorkout: WorkoutData) {
        if let index = workouts.firstIndex(where: { $0.id == updatedWorkout.id }) {
            workouts[index] = updatedWorkout
            saveWorkouts()
        }
    }

    private func deleteWorkout(_ workout: WorkoutData) {
        workouts.removeAll { $0.id == workout.id }
        saveWorkouts()
    }

    private func saveWorkouts() {
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
    }

    private func timeString(from timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}

struct SavedDataEditView: View {
    @State private var workout: WorkoutData
    @Binding var isEditing: Bool
    var onSave: (WorkoutData) -> Void

    init(workout: WorkoutData, isEditing: Binding<Bool>, onSave: @escaping (WorkoutData) -> Void) {
        self._workout = State(initialValue: workout)
        self._isEditing = isEditing
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    Stepper("Reps: \(workout.repCount)", value: $workout.repCount, in: 0...1000)
                        .onChange(of: workout.repCount) { _ in
                            triggerHapticFeedback()
                        }
                    
                    HStack {
                        Text("Time:")
                        Spacer()
                        
                        HStack {
                            Button("-1s") {
                                if workout.elapsedTime >= 1 {
                                    workout.elapsedTime -= 1
                                    triggerHapticFeedback()
                                }
                            }
                            .buttonStyle(.bordered)
                            
                            Text(timeString(from: workout.elapsedTime))
                                .frame(minWidth: 70)
                            
                            Button("+1s") {
                                workout.elapsedTime += 1
                                triggerHapticFeedback()
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isEditing = false
                },
                trailing: Button("Done") {
                    onSave(workout)
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
