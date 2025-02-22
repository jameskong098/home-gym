import Foundation

struct DataGenerator {
    static func generateTestData() -> [WorkoutData] {
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

        return fixedWorkouts
    }

    private static func calculateCaloriesBurned(exerciseName: String, repCount: Int, heightFeet: Int, heightInches: Int, bodyWeight: Double, sex: String, age: Int) -> Double {
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
}