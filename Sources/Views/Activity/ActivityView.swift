/*
  ActivityView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view displays workout history and activity tracking,
  allowing users to view, edit, and manage their workout data.
*/

import SwiftUI
import AVFoundation

struct ActivityView: View {
    @State private var workouts: [WorkoutData] = []
    @State private var selectedWorkout: WorkoutData?
    @State private var isShowingEditSheet = false
    @State private var workoutToDelete: WorkoutData?
    @State private var showingDeleteAlert = false
    @Binding var editMode: Bool
    var onActivitiesChange: (Int) -> Void
    var onWorkoutsUpdate: ([WorkoutData]) -> Void
    @State private var highlightedWorkoutId: UUID?
    @Namespace private var animation
    @State private var expandedSections: Set<String> = Set()
    @State private var showingFilterSheet = false
    @ObservedObject var filterModel: WorkoutFilterModel
    var showDevTools = false

    init(editMode: Binding<Bool>, onActivitiesChange: @escaping (Int) -> Void, onWorkoutsUpdate: @escaping ([WorkoutData]) -> Void, filterModel: WorkoutFilterModel) {
        self._editMode = editMode
        self.onActivitiesChange = onActivitiesChange
        self.onWorkoutsUpdate = onWorkoutsUpdate
        self.filterModel = filterModel
        
        if let savedData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([WorkoutData].self, from: savedData) {
            self._workouts = State(initialValue: decodedWorkouts)
        }
    }

    var body: some View {
        VStack {
            if showDevTools {
                HStack {
                    Button("Generate Test Data") {
                        generateTestData()
                    }
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    
                    Button("Clear All Data") {
                        clearAllData()
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
            }

            ScrollView {
                VStack(spacing: 20) {
                    if filteredWorkouts.isEmpty {
                        emptyStateView
                    } else {
                        workoutsList
                    }
                }
                .padding()
            }
            .background(Color(UIColor.systemGroupedBackground))
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
                if (!newValue) { 
                    selectedWorkout = nil
                    highlightedWorkoutId = nil
                }
            }
            .task {
                onActivitiesChange(workouts.count)
                onWorkoutsUpdate(workouts)
                expandedSections = Set(groupWorkoutsByDate(workouts).map { $0.1 })
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
                ForEach(groupWorkoutsByDate(filteredWorkouts), id: \.1) { section in
                    VStack(spacing: 8) {
                        Button(action: {
                            withAnimation {
                                if expandedSections.contains(section.1) {
                                    expandedSections.remove(section.1)
                                } else {
                                    expandedSections.insert(section.1)
                                }
                            }
                        }) {
                            HStack(spacing: 8) {
                                Text(section.0)
                                    .font(.title3)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.primary)
                                
                                Text(section.1)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                                
                                Image(systemName: expandedSections.contains(section.1) ? "chevron.down" : "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 14, weight: .medium))
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                            .cornerRadius(10)
                        }
                        .buttonStyle(PlainButtonStyle())
                        
                        if expandedSections.contains(section.1) {
                            LazyVGrid(columns: UIDevice.current.userInterfaceIdiom == .pad ? [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ] : [
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(section.2.sorted(by: { $0.date > $1.date })) { workout in
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
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                
                if isShowingEditSheet && UIDevice.current.userInterfaceIdiom != .pad {
                    Color.clear
                        .frame(height: 190)
                        .transition(.opacity)
                }
            }
        }
    }
    
    private var filteredWorkouts: [WorkoutData] {
        workouts.filter { workout in
            var passes = true
            
            if !filterModel.exerciseName.isEmpty {
                passes = passes && workout.exerciseName == filterModel.exerciseName
            }
            
            if let minReps = Int(filterModel.minReps) {
                passes = passes && workout.repCount >= minReps
            }
            
            if let maxReps = Int(filterModel.maxReps) {
                passes = passes && workout.repCount <= maxReps
            }
            
            if let startDate = filterModel.startDate {
                passes = passes && workout.date >= startDate
            }
            
            if let endDate = filterModel.endDate {
                passes = passes && workout.date <= endDate
            }
            
            if let minTime = filterModel.minTime {
                passes = passes && workout.elapsedTime >= minTime
            }
            
            if let maxTime = filterModel.maxTime {
                passes = passes && workout.elapsedTime <= maxTime
            }
            
            return passes
        }
    }
    
    private func deleteAlert() -> some View {
        Group {
            Button("Delete", role: .destructive) {
                if let workout = workoutToDelete {
                    deleteWorkout(workout)
                    onActivitiesChange(workouts.count)
                    Audio.playSound("navigation_transition-left", extension: ".caf")
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
            onWorkoutsUpdate(workouts)
        }
    }

    private func updateWorkout(_ updatedWorkout: WorkoutData) {
        if let index = workouts.firstIndex(where: { $0.id == updatedWorkout.id }) {
            workouts[index] = updatedWorkout
            saveWorkouts()
            onWorkoutsUpdate(workouts)
            onActivitiesChange(workouts.count)
        }
    }

    private func deleteWorkout(_ workout: WorkoutData) {
        withAnimation {
            workouts.removeAll { $0.id == workout.id }
            saveWorkouts()
            onWorkoutsUpdate(workouts)
            onActivitiesChange(workouts.count)
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

    private func groupWorkoutsByDate(_ workouts: [WorkoutData]) -> [(String, String, [WorkoutData])] {
        let calendar = Calendar.current
        
        return Dictionary(grouping: workouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
        .map { (date, workouts) in
            let headerTitle: String
            if calendar.isDateInToday(date) {
                headerTitle = "Today"
            } else if calendar.isDateInYesterday(date) {
                headerTitle = "Yesterday"
            } else {
                let formatter = DateFormatter()
                formatter.dateFormat = "EEEE"
                headerTitle = formatter.string(from: date)
            }
            
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d, yyyy"
            let dateString = formatter.string(from: date)
            
            return (headerTitle, dateString, workouts)
        }
        .sorted { $0.2.first?.date ?? Date() > $1.2.first?.date ?? Date() }
    }

    private func generateTestData() {
        let exercises = ["Jumping Jacks", "High Knees", "Basic Squats", "Wall Squats", "Lunges", "Push-Ups", "Bicep Curls - Simultaneous", "Pilates Sit-Ups Hybrid"]
        let calendar = Calendar.current
        let today = Date()
        var fixedWorkouts: [WorkoutData] = []

        let heightFeet = 5
        let heightInches = 9
        let bodyWeight = 160.0
        let sex = "Male"
        let age = 30

        for dayOffset in -90...0 {
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!
            let workoutCount = [0, 1, 2, 3].randomElement()!
            
            for i in 0..<workoutCount {
                let exercise = exercises[i % exercises.count]
                let repCount = 10 + i * 5
                let elapsedTime = TimeInterval(Int.random(in: 30...300)) // Random time between 30 and 300 seconds
                let randomHour = Int.random(in: 0..<24)
                let randomMinute = Int.random(in: 0..<60)
                let randomSecond = Int.random(in: 0..<60)
                let randomDate = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: randomSecond, of: date)!
                let caloriesBurned = calculateCaloriesBurned(exerciseName: exercise, repCount: repCount, heightFeet: heightFeet, heightInches: heightInches, bodyWeight: bodyWeight, sex: sex, age: age)
                let workout = WorkoutData(date: randomDate, exerciseName: exercise, repCount: repCount, elapsedTime: elapsedTime, caloriesBurned: caloriesBurned)
                fixedWorkouts.append(workout)
            }
        }

        let currentDayWorkouts = exercises.prefix(5).map { exercise in
            let repCount = Int.random(in: 30...54)
            let elapsedTime = TimeInterval(Int.random(in: 30...300)) // Random time between 30 and 300 seconds
            let randomHour = Int.random(in: 0..<24)
            let randomMinute = Int.random(in: 0..<60)
            let randomSecond = Int.random(in: 0..<60)
            let randomDate = calendar.date(bySettingHour: randomHour, minute: randomMinute, second: randomSecond, of: today)!
            let caloriesBurned = calculateCaloriesBurned(exerciseName: exercise, repCount: repCount, heightFeet: heightFeet, heightInches: heightInches, bodyWeight: bodyWeight, sex: sex, age: age)
            return WorkoutData(date: randomDate, exerciseName: exercise, repCount: repCount, elapsedTime: elapsedTime, caloriesBurned: caloriesBurned)
        }
        fixedWorkouts.append(contentsOf: currentDayWorkouts)

        workouts = fixedWorkouts
        saveWorkouts()
        onWorkoutsUpdate(workouts)
        onActivitiesChange(workouts.count)
    }

    private func calculateCaloriesBurned(exerciseName: String, repCount: Int, heightFeet: Int, heightInches: Int, bodyWeight: Double, sex: String, age: Int) -> Double {
        let height = Double(heightFeet * 12 + heightInches) * 2.54 // Convert to cm
        let weight = bodyWeight * 0.453592 // Convert to kg
        
        var bmr: Double = 0.0
        
        if sex == "Male" {
            bmr = 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        } else {
            bmr = 47.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
        
        let caloriesPerRep: Double
        switch exerciseName {
            case "High Knees":
                caloriesPerRep = 0.30
            case "Basic Squats":
                caloriesPerRep = 0.36
            case "Lunges":
                caloriesPerRep = 0.35 
            case "Wall Squats":
                caloriesPerRep = 0.28
            case "Standing Side Leg Raises":
                caloriesPerRep = 0.18
            case "Push-Ups":
                caloriesPerRep = 0.40
            case "Pilates Sit-Ups Hybrid":
                caloriesPerRep = 0.25
            case "Bicep Curls - Simultaneous":
                caloriesPerRep = 0.12
            case "Jumping Jacks":
                caloriesPerRep = 0.25
            case "Lateral Raises":
                caloriesPerRep = 0.12
            case "Front Raises":
                caloriesPerRep = 0.12
            default:
                caloriesPerRep = 0.25
        }
        
        let bmrAdjustmentFactor = bmr / 2000 // Normalize based on average BMR
        
        let caloriesBurned = Double(repCount) * caloriesPerRep * bmrAdjustmentFactor
      
        return caloriesBurned
    }

    private func clearAllData() {
        workouts.removeAll()
        saveWorkouts()
        onWorkoutsUpdate(workouts)
        onActivitiesChange(workouts.count)
    }
}
