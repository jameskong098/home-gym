import Foundation

struct WorkoutData: Identifiable, Codable {
    let id: UUID
    let date: Date
    var exerciseName: String
    var repCount: Int
    var elapsedTime: TimeInterval

    init(date: Date, exerciseName: String, repCount: Int, elapsedTime: TimeInterval) {
        self.id = UUID()
        self.date = date
        self.exerciseName = exerciseName
        self.repCount = repCount
        self.elapsedTime = elapsedTime
    }
}
