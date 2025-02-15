import SwiftUI

struct ProgressTracker: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @AppStorage("name") private var name = ""
    @State private var dailyProgress: Double = 0.0
    @State private var weeklyProgress: Double = 0.0
    @State private var monthlyProgress: Double = 0.0
    @State private var workoutStreak: Int = 0
    @State private var longestStreak: Int = 0
    @State private var achievements: [Achievement] = []
    @State private var workoutDates: Set<Date> = []
    @State private var selectedDate = Date()
    @State private var currentMotivationalMessage: String = ""
    @State private var selectedGoalType: GoalType = .reps
    
    private let dailyGoal: Int = 100
    private let weeklyGoal: Int = 500
    private let monthlyGoal: Int = 2000
    private let calendar = Calendar.current
    
    private let dailyGoals: [GoalType: Int] = [
        .reps: 100,
        .duration: 30, // 30 minutes
        .calories: 300
    ]
    
    private let weeklyGoals: [GoalType: Int] = [
        .reps: 500,
        .duration: 180, // 3 hours
        .calories: 2100
    ]
    
    private let monthlyGoals: [GoalType: Int] = [
        .reps: 2000,
        .duration: 720, // 12 hours
        .calories: 9000
    ]
    
    private var isLandscape: Bool {
        UIDevice.current.orientation.isLandscape
    }
   
    private var shouldUseHorizontalLayout: Bool {
        UIDevice.current.userInterfaceIdiom == .pad ||
        (UIDevice.current.userInterfaceIdiom == .phone && isLandscape)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: shouldUseHorizontalLayout ? 24 : 4) {
                if !name.isEmpty {
                    HStack(spacing: 4) {
                        Text("Welcome back, \(name)! 💪")
                            .font(.title2)
                            .fontWeight(.bold)
                        Spacer()
                        Text(currentMotivationalMessage)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                }
                VStack(spacing: 20) {
                    if shouldUseHorizontalLayout {
                        HStack(spacing: 16) {
                            CustomCalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                            Divider()
                            DayStatsView(selectedDate: selectedDate, workouts: loadWorkouts())
                        }
                        .background(Theme.sectionBackground)
                        .cornerRadius(12)
                        .frame(height: shouldUseHorizontalLayout ? 380 : 600)
                        .padding(.top, 8)
                    } else {
                        VStack(spacing: 10) {
                            CustomCalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                                .background(Theme.sectionBackground)
                                .cornerRadius(12)
                                .frame(height: 380)
                            DayStatsView(selectedDate: selectedDate, workouts: loadWorkouts())
                                .background(Theme.sectionBackground)
                                .cornerRadius(12)
                                .frame(height: 380)
                        }
                    }
                    Text("Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    VStack(spacing: 12) {
                        Picker("Goal Type", selection: $selectedGoalType) {
                            ForEach(GoalType.allCases, id: \.self) { goalType in
                                Text(goalType.rawValue.capitalized).tag(goalType)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal)
                        
                        HStack(spacing: shouldUseHorizontalLayout ? 24 : 4) {
                            Spacer()
                            CircularProgressBar(
                                progress: dailyProgress,
                                title: "Daily",
                                color: colorForGoalType(goalType: selectedGoalType, level: .daily),
                                currentValue: Int(dailyProgress * Double(dailyGoals[selectedGoalType] ?? 0)),
                                goalValue: dailyGoals[selectedGoalType] ?? 0,
                                goalType: selectedGoalType
                            )
                            Spacer()
                            CircularProgressBar(
                                progress: weeklyProgress,
                                title: "Weekly",
                                color: colorForGoalType(goalType: selectedGoalType, level: .weekly),
                                currentValue: Int(weeklyProgress * Double(weeklyGoals[selectedGoalType] ?? 0)),
                                goalValue: weeklyGoals[selectedGoalType] ?? 0,
                                goalType: selectedGoalType
                            )
                            Spacer()
                            CircularProgressBar(
                                progress: monthlyProgress,
                                title: "Monthly",
                                color: colorForGoalType(goalType: selectedGoalType, level: .monthly),
                                currentValue: Int(monthlyProgress * Double(monthlyGoals[selectedGoalType] ?? 0)),
                                goalValue: monthlyGoals[selectedGoalType] ?? 0,
                                goalType: selectedGoalType
                            )
                            Spacer()
                        }
                        .padding(.top, 15)
                        Spacer()
                        Divider()
                        HStack(spacing: 16) {
                            StreakView(value: workoutStreak, label: "Current Streak")
                                .frame(maxWidth: .infinity)
                            StreakView(value: longestStreak, label: "Longest Streak")
                                .frame(maxWidth: .infinity)
                        }
                        .padding()
                        .cornerRadius(12)
                        .padding(.horizontal)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Theme.sectionBackground)
                    .cornerRadius(12)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 16) {
                    Text("Achievements")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.horizontal)
                        .padding(.top, shouldUseHorizontalLayout ? 8: 22)
                    
                    CompactAchievementsView(achievements: achievements)
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            calculateProgress()
            workoutDates = Set(loadWorkouts().map { calendar.startOfDay(for: $0.date) })
            currentMotivationalMessage = motivationalMessages.randomElement() ?? "Let's crush today's workout goals 💪"
        }
        .onChange(of: selectedGoalType) { _ in
            calculateProgress()
        }
    }

    private func calculateProgress() {
        let workouts = loadWorkouts()
        let calendar = Calendar.current
        let today = Date()
        
        let dailyWorkouts = workouts.filter { calendar.isDate($0.date, inSameDayAs: today) }
        let dailyValue = dailyWorkouts.reduce(0.0) { total, workout in
            switch selectedGoalType {
            case .reps:
                return total + Double(workout.repCount)
            case .duration:
                return total + workout.elapsedTime / 60.0
            case .calories:
                return total + workout.caloriesBurned
            }
        }
        
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weeklyWorkouts = workouts.filter { $0.date >= startOfWeek && $0.date <= today }
        let weeklyValue = weeklyWorkouts.reduce(0.0) { total, workout in
            switch selectedGoalType {
            case .reps:
                return total + Double(workout.repCount)
            case .duration:
                return total + workout.elapsedTime / 60.0
            case .calories:
                return total + workout.caloriesBurned
            }
        }
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let monthlyWorkouts = workouts.filter { $0.date >= startOfMonth && $0.date <= today }
        let monthlyValue = monthlyWorkouts.reduce(0.0) { total, workout in
            switch selectedGoalType {
            case .reps:
                return total + Double(workout.repCount)
            case .duration:
                return total + workout.elapsedTime / 60.0
            case .calories:
                return total + workout.caloriesBurned
            }
        }
        
        let dailyGoal = Double(dailyGoals[selectedGoalType] ?? 0)
        let weeklyGoal = Double(weeklyGoals[selectedGoalType] ?? 0)
        let monthlyGoal = Double(monthlyGoals[selectedGoalType] ?? 0)
        
        dailyProgress = min(dailyValue / dailyGoal, 1.0)
        weeklyProgress = min(weeklyValue / weeklyGoal, 1.0)
        monthlyProgress = min(monthlyValue / monthlyGoal, 1.0)
        
        workoutStreak = calculateStreak(workouts: workouts, calendar: calendar, today: today)
        longestStreak = calculateLongestStreak(workouts: workouts, calendar: calendar)
        achievements = calculateAchievements(workouts: workouts)
    }

    private func calculateStreak(workouts: [WorkoutData], calendar: Calendar, today: Date) -> Int {
        var streak = 0
        var currentDate = today
        
        while workouts.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
            streak += 1
            currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return streak
    }

    private func calculateLongestStreak(workouts: [WorkoutData], calendar: Calendar) -> Int {
        var longestStreak = 0
        var currentStreak = 0
        var previousDate: Date?
        
        for workout in workouts.sorted(by: { $0.date < $1.date }) {
            if let previousDate = previousDate, calendar.isDate(workout.date, inSameDayAs: calendar.date(byAdding: .day, value: 1, to: previousDate)!) {
                currentStreak += 1
            } else {
                currentStreak = 1
            }
            longestStreak = max(longestStreak, currentStreak)
            previousDate = workout.date
        }
        
        return longestStreak
    }

    private func calculateAchievements(workouts: [WorkoutData]) -> [Achievement] {
        let streakAchievements = [
            Achievement(title: "5 Days", imageName: "flame.circle.fill", condition: { $0 >= 5 }),
            Achievement(title: "10 Days", imageName: "flame.circle.fill", condition: { $0 >= 10 }),
            Achievement(title: "30 Days", imageName: "flame.circle.fill", condition: { $0 >= 30 }),
            Achievement(title: "90 Days", imageName: "flame.circle.fill", condition: { $0 >= 90 }),
            Achievement(title: "180 Days", imageName: "flame.circle.fill", condition: { $0 >= 180 }),
            Achievement(title: "1 Year", imageName: "flame.circle.fill", condition: { $0 >= 365 }),
            Achievement(title: "2 Years", imageName: "flame.circle.fill", condition: { $0 >= 730 })
        ]
        
        let repAchievements = [
            Achievement(title: "100 Reps", imageName: "star.fill", condition: { $0 >= 100 }),
            Achievement(title: "500 Reps", imageName: "star.fill", condition: { $0 >= 500 }),
            Achievement(title: "1000 Reps", imageName: "star.fill", condition: { $0 >= 1000 }),
            Achievement(title: "5000 Reps", imageName: "star.fill", condition: { $0 >= 5000 }),
            Achievement(title: "10000 Reps", imageName: "star.fill", condition: { $0 >= 10000 }),
            Achievement(title: "50000 Reps", imageName: "star.fill", condition: { $0 >= 50000 }),
            Achievement(title: "100000 Reps" , imageName: "star.fill", condition: { $0 >= 100000 })
        ]
        
        let durationAchievements = [
            Achievement(title: "1 Hour", imageName: "clock.fill", condition: { $0 >= Int(3600.0) }),
            Achievement(title: "5 Hours", imageName: "clock.fill", condition: { $0 >= Int(18000.0) }),
            Achievement(title: "10 Hours", imageName: "clock.fill", condition: { $0 >= Int(36000.0) }),
            Achievement(title: "50 Hours", imageName: "clock.fill", condition: { $0 >= Int(180000.0) }),
            Achievement(title: "100 Hours", imageName: "clock.fill", condition: { $0 >= Int(360000.0) }),
            Achievement(title: "200 Hours", imageName: "clock.fill", condition: { $0 >= Int(720000.0) }),
            Achievement(title: "500 Hours", imageName: "clock.fill", condition: { $0 >= Int(1800000.0) })
        ]
        
        let calorieAchievements = [
            Achievement(title: "500 Calories", imageName: "flame.fill", condition: { $0 >= Int(500.0) }),
            Achievement(title: "1000 Calories", imageName: "flame.fill", condition: { $0 >= Int(1000.0) }),
            Achievement(title: "5000 Calories", imageName: "flame.fill", condition: { $0 >= Int(5000.0) }),
            Achievement(title: "10000 Calories", imageName: "flame.fill", condition: { $0 >= Int(10000.0) }),
            Achievement(title: "50000 Calories", imageName: "flame.fill", condition: { $0 >= Int(50000.0) }),
            Achievement(title: "100000 Calories", imageName: "flame.fill", condition: { $0 >= Int(100000.0) }),
            Achievement(title: "200000 Calories", imageName: "flame.fill", condition: { $0 >= Int(200000.0) })
        ]
        
        let totalReps = workouts.reduce(0) { $0 + $1.repCount }
        let totalDuration = workouts.reduce(0.0) { $0 + $1.elapsedTime }
        let totalCalories = workouts.reduce(0.0) { $0 + $1.caloriesBurned }
        let currentStreak = calculateStreak(workouts: workouts, calendar: Calendar.current, today: Date())
        
        return (streakAchievements + repAchievements + durationAchievements + calorieAchievements).map { achievement in
            var earned = false
            if achievement.title.contains("Days") || achievement.title.contains("Year") {
                earned = achievement.condition(currentStreak)
            } else if achievement.title.contains("Hour") {
                earned = achievement.condition(Int(totalDuration))
            } else if achievement.title.contains("Calories") {
                earned = achievement.condition(Int(totalCalories))
            } else {
                earned = achievement.condition(totalReps)
            }
            return Achievement(title: achievement.title, imageName: achievement.imageName, condition: achievement.condition, earned: earned)
        }
    }

    private func loadWorkouts() -> [WorkoutData] {
        if let savedData = UserDefaults.standard.data(forKey: "workouts"),
           let decodedWorkouts = try? JSONDecoder().decode([WorkoutData].self, from: savedData) {
            return decodedWorkouts
        }
        return []
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

enum GoalType: String, CaseIterable {
    case reps
    case duration
    case calories
}

enum GoalLevel {
    case daily
    case weekly
    case monthly
}

private func colorForGoalType(goalType: GoalType, level: GoalLevel) -> Color {
    switch goalType {
    case .reps:
        switch level {
        case .daily:
            return Color.green.opacity(0.6)
        case .weekly:
            return Color.green.opacity(0.8)
        case .monthly:
            return Color.green
        }
    case .duration:
        switch level {
        case .daily:
            return Color.blue.opacity(0.6)
        case .weekly:
            return Color.blue.opacity(0.8)
        case .monthly:
            return Color.blue
        }
    case .calories:
        switch level {
        case .daily:
            return Color.orange.opacity(0.6)
        case .weekly:
            return Color.orange.opacity(0.8)
        case .monthly:
            return Color.orange
        }
    }
}

struct ProgressBar: View {
    let progress: Double
    let title: String
    let color: Color
    let currentValue: Int
    let goalValue: Int
    let goalType: GoalType
    
    private var unitLabel: String {
        switch goalType {
        case .reps:
            return "Reps"
        case .duration:
            return "mins"
        case .calories:
            return "cal"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                Text("\(currentValue)/\(goalValue) \(unitLabel)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 14)
                        .foregroundColor(.gray.opacity(0.2))
                    
                    Capsule()
                        .frame(width: geometry.size.width * CGFloat(progress), height: 14)
                        .foregroundColor(color)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 14)
        }
        .padding(.vertical, 4)
    }
}

struct StreakView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("\(value)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.orange)
                Image(systemName: label.contains("Current") ? "flame.circle.fill" : "trophy.fill")
                    .foregroundColor(.orange)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct CircularProgressBar: View {
    let progress: Double
    let title: String
    let color: Color
    let currentValue: Int
    let goalValue: Int
    let goalType: GoalType
    
    private var unitLabel: String {
        switch goalType {
        case .reps:
            return "Reps"
        case .duration:
            return "mins"
        case .calories:
            return "cal"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .foregroundColor(color)
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                VStack {
                    Text("\(currentValue)/\(goalValue)")
                        .font(.headline)
                        .bold()
                    Text(unitLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            .padding(.bottom, 10)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

extension Theme {
    static var sectionBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? Theme.settingsSectionBackgroundColorDark
            : Theme.settingsSectionBackgroundColorLight
        })
    }
}
