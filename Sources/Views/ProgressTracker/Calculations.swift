import SwiftUI

func calculateStreak(workouts: [WorkoutData], calendar: Calendar, today: Date) -> Int {
    var streak = 0
    var currentDate = today
    
    while workouts.contains(where: { calendar.isDate($0.date, inSameDayAs: currentDate) }) {
        streak += 1
        currentDate = calendar.date(byAdding: .day, value: -1, to: currentDate)!
    }
    
    return streak
}

func calculateLongestStreak(workouts: [WorkoutData], calendar: Calendar) -> Int {
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

func calculateAchievements(workouts: [WorkoutData]) -> [Achievement] {
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
