import Foundation

struct WorkoutData: Identifiable, Codable {
    let id: UUID
    let date: Date
    var exerciseName: String
    var repCount: Int
    var elapsedTime: TimeInterval
    var caloriesBurned: Double
    var weight: Double?

    init(date: Date, exerciseName: String, repCount: Int, elapsedTime: TimeInterval, caloriesBurned: Double, weight: Double? = nil) {
        self.id = UUID()
        self.date = date
        self.exerciseName = exerciseName
        self.repCount = repCount
        self.elapsedTime = elapsedTime
        self.caloriesBurned = caloriesBurned
        self.weight = weight
    }
}
