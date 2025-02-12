import SwiftUI

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
                editButtons
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
        VStack() {
            IconButton(icon: "pencil", color: .blue, action: onEdit)
            Spacer()
            IconButton(icon: "trash", color: .red, action: onDelete)
        }
        .opacity(editMode ? 1 : 0)
        .offset(x: editMode ? 0 : 20)
        .scaleEffect(editMode ? 1 : 0.8)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: editMode)
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
