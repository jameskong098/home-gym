import SwiftUI

struct ExerciseSummaryView: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    @State private var isEditing = false
    @State private var editedRepCount: Int
    @State private var editedElapsedTime: TimeInterval
    @State private var editedWeight: Double?
    @State private var caloriesBurned: Double
    let exerciseName: String
    let repCount: Int
    let elapsedTime: TimeInterval
    let weight: Double?

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
            Color(UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return Theme.mainContentBackgroundColorDark
                } else {
                    return Theme.mainContentBackgroundColorLight
                }
            })
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 25) {
                Text("Exercise Summary")
                    .font(.system(size: 34, weight: .bold))
                    .foregroundColor(Color(UIColor { traitCollection in
                        if traitCollection.userInterfaceStyle == .dark {
                            return Theme.settingsThemeTextColorDark
                        } else {
                            return Theme.settingsThemeTextColorLight
                        }
                    }))
                    .padding(.top, 30)

                VStack(spacing: 15) {
                    summaryItem(icon: "figure.walk", title: "Exercise", value: exerciseName)
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    summaryItem(icon: "repeat", title: "Reps", value: "\(editedRepCount)")
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    summaryItem(icon: "clock", title: "Time", value: timeString(from: editedElapsedTime))
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    summaryItem(icon: "flame.fill", title: "Calories Burned", value: String(format: "%.2f", caloriesBurned))
                    Divider()
                        .background(Color.gray.opacity(0.3))
                    summaryItem(icon: "scalemass", title: "Weight", value: weightString(from: editedWeight))
                    Text("Weight can include additional weight from equipment such as a weight vest or dumbbells. Click 'Edit' to add or update the value if needed.")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 5)
                }
                .padding(.vertical, 20)
                .padding(.horizontal, 25)
                .background(Color(UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return Theme.settingsSectionBackgroundColorDark
                    } else {
                        return Theme.settingsSectionBackgroundColorLight
                    }
                }))
                .cornerRadius(20)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                .padding(.horizontal)

                Spacer()

                HStack(spacing: 30) {
                    actionButton(title: "Edit Workout", icon: "pencil", color: Theme.footerAccentColor) {
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

                    actionButton(title: "Don't Save", icon: "xmark", color: .red) {
                        navPath.removeAll()
                    }
                    
                    Spacer()
                    
                    actionButton(title: "Save Workout", icon: "checkmark", color: .green) {
                        saveWorkout()
                        selectedTab = 2
                        navPath.append("Activity")
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 40)
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
                .foregroundColor(Color(UIColor { traitCollection in
                    if traitCollection.userInterfaceStyle == .dark {
                        return Theme.settingsThemeTextColorDark
                    } else {
                        return Theme.settingsThemeTextColorLight
                    }
                }))
            
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
            return "N/A"
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
                .navigationTitle("Edit Workout")
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
    }

    private func loadWorkouts() -> [WorkoutData] {
        if let savedData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([WorkoutData].self, from: savedData) {
            return decodedWorkouts
        }
        return []
    }
}
