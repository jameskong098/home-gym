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
    
    private let dailyGoal: Int = 100
    private let weeklyGoal: Int = 500
    private let monthlyGoal: Int = 2000
    private let calendar = Calendar.current
    
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
                        ProgressBar(progress: dailyProgress, title: "Daily", color: .green, currentValue: Int(dailyProgress * Double(dailyGoal)), goalValue: dailyGoal)
                        ProgressBar(progress: weeklyProgress, title: "Weekly", color: .blue, currentValue: Int(weeklyProgress * Double(weeklyGoal)), goalValue: weeklyGoal)
                        ProgressBar(progress: monthlyProgress, title: "Monthly", color: .orange, currentValue: Int(monthlyProgress * Double(monthlyGoal)), goalValue: monthlyGoal)
                        
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
    }

    private func calculateProgress() {
        let workouts = loadWorkouts()
        let calendar = Calendar.current
        let today = Date()
        
        let dailyReps = workouts.filter { calendar.isDate($0.date, inSameDayAs: today) }
                                 .reduce(0) { $0 + $1.repCount }
        
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        let weeklyReps = workouts.filter { $0.date >= startOfWeek && $0.date <= today }
                                 .reduce(0) { $0 + $1.repCount }
        
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: today))!
        let monthlyReps = workouts.filter { $0.date >= startOfMonth && $0.date <= today }
                                  .reduce(0) { $0 + $1.repCount }
        
        dailyProgress = min(Double(dailyReps) / Double(dailyGoal), 1.0)
        weeklyProgress = min(Double(weeklyReps) / Double(weeklyGoal), 1.0)
        monthlyProgress = min(Double(monthlyReps) / Double(monthlyGoal), 1.0)
        
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
            Achievement(title: "5 Days", imageName: "flame.fill", condition: { $0 >= 5 }),
            Achievement(title: "10 Days", imageName: "flame.fill", condition: { $0 >= 10 }),
            Achievement(title: "30 Days", imageName: "flame.fill", condition: { $0 >= 30 }),
            Achievement(title: "90 Days", imageName: "flame.fill", condition: { $0 >= 90 }),
            Achievement(title: "180 Days", imageName: "flame.fill", condition: { $0 >= 180 }),
            Achievement(title: "1 Year", imageName: "flame.fill", condition: { $0 >= 365 }),
            Achievement(title: "2 Years", imageName: "flame.fill", condition: { $0 >= 730 })
        ]
        
        let repAchievements = [
            Achievement(title: "100", imageName: "star.fill", condition: { $0 >= 100 }),
            Achievement(title: "500", imageName: "star.fill", condition: { $0 >= 500 }),
            Achievement(title: "1000", imageName: "star.fill", condition: { $0 >= 1000 }),
            Achievement(title: "5000", imageName: "star.fill", condition: { $0 >= 5000 }),
            Achievement(title: "10000", imageName: "star.fill", condition: { $0 >= 10000 }),
            Achievement(title: "50000", imageName: "star.fill", condition: { $0 >= 50000 }),
            Achievement(title: "100000", imageName: "star.fill", condition: { $0 >= 100000 })
        ]
        
        let totalReps = workouts.reduce(0) { $0 + $1.repCount }
        let currentStreak = calculateStreak(workouts: workouts, calendar: Calendar.current, today: Date())
        
        return (streakAchievements + repAchievements).map { achievement in
            var earned = false
            if achievement.title.contains("Days") || achievement.title.contains("Year") {
                earned = achievement.condition(currentStreak)
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

struct ProgressBar: View {
    let progress: Double
    let title: String
    let color: Color
    let currentValue: Int
    let goalValue: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.caption)
                Spacer()
                Text("\(currentValue)/\(goalValue) Reps")
                    .font(.caption)
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
                Image(systemName: label.contains("Current") ? "flame.fill" : "crown.fill")
                    .foregroundColor(.orange)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
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
