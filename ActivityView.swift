import SwiftUI

struct ActivityView: View {
    @State private var workouts: [WorkoutData] = []
    @State private var selectedWorkout: WorkoutData?
    @State private var isShowingEditSheet = false
    @State private var workoutToDelete: WorkoutData?
    @State private var showingDeleteAlert = false
    @Binding var editMode: Bool
    var onActivitiesChange: (Int) -> Void
    @State private var highlightedWorkoutId: UUID?
    @Namespace private var animation

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                if workouts.isEmpty {
                    emptyStateView
                } else {
                    workoutsList
                }
            }
            .padding()
        }
        .background(Color(UIColor.systemGroupedBackground))
        .onAppear {
            loadWorkouts()
            onActivitiesChange(workouts.count)
        }
        .sheet(isPresented: $isShowingEditSheet) {
            if let workout = selectedWorkout {
                SavedDataEditView(workout: workout, 
                                 isShowingEditSheet: $isShowingEditSheet, 
                                 onSave: handleWorkoutUpdate)
                .presentationDetents([.height(UIDevice.current.userInterfaceIdiom == .pad ? 400 : 300)])
                .interactiveDismissDisabled()
            }
        }
        .alert("Delete Workout", 
               isPresented: $showingDeleteAlert,
               actions: deleteAlert,
               message: deleteAlertMessage)
        .onChange(of: isShowingEditSheet) { newValue in
            if !newValue { 
                selectedWorkout = nil
                highlightedWorkoutId = nil
            }
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "figure.strengthtraining.traditional.circle")
                .font(.system(size: 60))
                .foregroundColor(.blue)
            
            Text("No Workouts Yet")
                .font(.title2.bold())
            
            Text("Start exercising to see your activity history here")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.vertical, 60)
    }
    
    private var workoutsList: some View {
        ScrollViewReader { proxy in
            LazyVStack(spacing: 16) {
                ForEach(workouts.sorted(by: { $0.date > $1.date })) { workout in
                    WorkoutCard(
                        workout: workout,
                        editMode: editMode,
                        isHighlighted: workout.id == highlightedWorkoutId,
                        onEdit: {
                            selectedWorkout = workout
                            highlightedWorkoutId = workout.id
                            
                            withAnimation {
                                proxy.scrollTo(workout.id, anchor: .center)
                            }

                            isShowingEditSheet = true
                            
                        },
                        onDelete: { 
                            workoutToDelete = workout
                            showingDeleteAlert = true 
                        }
                    )
                    .id(workout.id)
                    .transition(.opacity) 
                }
                if isShowingEditSheet && UIDevice.current.userInterfaceIdiom != .pad {
                    Color.clear
                        .frame(height: 190)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private func deleteAlert() -> some View {
        Group {
            Button("Delete", role: .destructive) {
                if let workout = workoutToDelete {
                    deleteWorkout(workout)
                    onActivitiesChange(workouts.count)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
    }
    
    private func deleteAlertMessage() -> some View {
        Text("Are you sure you want to delete this workout? This action cannot be undone.")
    }
    
    private func handleWorkoutUpdate(_ workout: WorkoutData) {
        updateWorkout(workout)
        onActivitiesChange(workouts.count)
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
        withAnimation {
            workouts.removeAll { $0.id == workout.id }
            saveWorkouts()
        }
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

struct WorkoutCard: View {
    let workout: WorkoutData
    let editMode: Bool
    let isHighlighted: Bool
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                workoutInfo
                Spacer()
                if editMode {
                    editButtons
                }
            }
            .padding()
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(UIColor.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.blue, lineWidth: isHighlighted ? 2 : 0)
                .shadow(color: isHighlighted ? .blue.opacity(0.3) : .clear, radius: 8)
        )
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            Button(action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
    
    private var workoutInfo: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(workout.exerciseName)
                .font(.title3.bold())
                .foregroundColor(.primary)
            
            workoutMetrics
        }
    }
    
    private var workoutMetrics: some View {
        VStack(alignment: .leading, spacing: 8) {
            MetricRow(
                icon: "number.circle.fill",
                label: "Reps:",
                value: "\(workout.repCount)"
            )
            MetricRow(
                icon: "clock.fill",
                label: "Duration:",
                value: timeString(from: workout.elapsedTime)
            )
            MetricRow(
                icon: "calendar.circle.fill",
                label: "Date:",
                value: formattedDate(workout.date)
            )
            if let weight = workout.weight {
                MetricRow(
                    icon: "scalemass.fill",
                    label: "Weight:",
                    value: "\(weight) lb"
                )
            }
        }
        .foregroundColor(.secondary)
    }
    
    private var editButtons: some View {
        HStack(spacing: 12) {
            IconButton(icon: "pencil", color: .blue, action: onEdit)
            IconButton(icon: "trash", color: .red, action: onDelete)
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

struct MetricRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 24)
            
            Text(label)
                .foregroundColor(.secondary)
                .font(.subheadline)
            
            Text(value)
                .foregroundColor(.primary)
                .font(.subheadline.weight(.medium))
        }
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .foregroundColor(color)
                .padding(8)
                .background(color.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

struct SavedDataEditView: View {
    @State private var workout: WorkoutData
    @Binding var isShowingEditSheet: Bool
    var onSave: (WorkoutData) -> Void

    init(workout: WorkoutData, isShowingEditSheet: Binding<Bool>, onSave: @escaping (WorkoutData) -> Void) {
        self._workout = State(initialValue: workout)
        self._isShowingEditSheet = isShowingEditSheet
        self.onSave = onSave
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Workout Details")) {
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        HStack {
                            Text("Exercise Name:")
                            Spacer()
                            Text(workout.exerciseName)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("Date:")
                            Spacer()
                            Text(formattedDate(workout.date))
                                .foregroundColor(.secondary)
                        }
                    }
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
                    
                    HStack {
                        Text("Weight (lb):")
                        Spacer()
                        TextField("Optional", value: $workout.weight, format: .number)
                            .keyboardType(.decimalPad)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 100)
                    }
                }
            }
            .navigationTitle("Edit Workout")
            .navigationBarItems(
                leading: Button("Cancel") {
                    isShowingEditSheet = false
                },
                trailing: Button("Done") {
                    onSave(workout)
                    isShowingEditSheet = false
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
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
