import SwiftUI
import TipKit

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
    
    let calendarTip = CalendarTip()
    let dayStatsTip = DayStatsTip()
    let goalsTip = GoalsTip()
    let achievementsTip = AchievementsTip()
    
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
                    if UIDevice.current.userInterfaceIdiom == .phone && !isLandscape {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Welcome \(name)! 💪")
                                .font(.title2)
                                .fontWeight(.bold)
                            Spacer()
                            Text(currentMotivationalMessage)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal)
                    } else {
                        HStack(spacing: 4) {
                            Text("Welcome \(name)! 💪")
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
                }
                VStack(spacing: 20) {
                    if shouldUseHorizontalLayout {
                        HStack(spacing: 16) {
                            ZStack(alignment: .topTrailing) {
                                if #available(iOS 17.0, *) {
                                    CustomCalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                                        .popoverTip(calendarTip)
                                        .onTapGesture {
                                            calendarTip.invalidate(reason: .actionPerformed)
                                        }
                                } else {
                                    CustomCalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                                        .frame(height: shouldUseHorizontalLayout ? 380 : 600)
                                }
                            }
                            Divider()
                            if #available(iOS 17.0, *) {
                                DayStatsView(selectedDate: selectedDate, workouts: loadWorkouts())
                                    .popoverTip(dayStatsTip)
                                    .onTapGesture {
                                        dayStatsTip.invalidate(reason: .actionPerformed)
                                    }
                            } else {
                                DayStatsView(selectedDate: selectedDate, workouts: loadWorkouts())
                            }
                        }
                        .background(Theme.sectionBackground)
                        .cornerRadius(12)
                        .frame(height: shouldUseHorizontalLayout ? 380 : 600)
                        .padding(.top, 8)
                    } else {
                        VStack(spacing: 10) {
                            if #available(iOS 17.0, *) {
                                CustomCalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                                    .background(Theme.sectionBackground)
                                    .cornerRadius(12)
                                    .frame(height: 380)
                                    .popoverTip(calendarTip)
                                    .onTapGesture {
                                        calendarTip.invalidate(reason: .actionPerformed)
                                    }
                            } else {
                                CustomCalendarView(selectedDate: $selectedDate, workoutDates: workoutDates)
                                    .background(Theme.sectionBackground)
                                    .cornerRadius(12)
                                    .frame(height: 380)
                            }
                            if #available(iOS 17.0, *) {
                                DayStatsView(selectedDate: selectedDate, workouts: loadWorkouts())
                                    .background(Theme.sectionBackground)
                                    .cornerRadius(12)
                                    .frame(height: 380)
                                    .popoverTip(dayStatsTip)
                                    .onTapGesture {
                                        dayStatsTip.invalidate(reason: .actionPerformed)
                                    }
                            } else {
                                DayStatsView(selectedDate: selectedDate, workouts: loadWorkouts())
                                    .background(Theme.sectionBackground)
                                    .cornerRadius(12)
                                    .frame(height: 380)
                            }
                        }
                    }
                    Text("Goals")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding(.top, 8)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    if #available(iOS 17.0, *) {
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
                        .popoverTip(goalsTip)
                        .onTapGesture {
                            goalsTip.invalidate(reason: .actionPerformed)
                        }
                    } else {
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
                }
                .padding(.horizontal)
                
                if #available(iOS 17.0, *) {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, shouldUseHorizontalLayout ? 8: 22)
                        
                        CompactAchievementsView(achievements: achievements)
                    }
                    .popoverTip(achievementsTip)
                    .onTapGesture {
                        achievementsTip.invalidate(reason: .actionPerformed)
                    }
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Achievements")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                            .padding(.top, shouldUseHorizontalLayout ? 8: 22)
                        
                        CompactAchievementsView(achievements: achievements)
                    }
                }
            }
            .padding(.vertical)
        }
        .onAppear {
            calculateProgress()
            workoutDates = Set(loadWorkouts().map { calendar.startOfDay(for: $0.date) })
            currentMotivationalMessage = motivationalMessages.randomElement() ?? "Let's crush today's workout goals 💪"
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

extension Theme {
    static var sectionBackground: Color {
        Color(UIColor { traitCollection in
            traitCollection.userInterfaceStyle == .dark
            ? Theme.settingsSectionBackgroundColorDark
            : Theme.settingsSectionBackgroundColorLight
        })
    }
}
