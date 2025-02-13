import SwiftUI

class WorkoutFilterModel: ObservableObject {
    @Published var exerciseName: String = ""
    @Published var minReps: String = ""
    @Published var maxReps: String = ""
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var minTime: TimeInterval?
    @Published var maxTime: TimeInterval?
    
    var isActive: Bool {
        !exerciseName.isEmpty ||
        !minReps.isEmpty ||
        !maxReps.isEmpty ||
        startDate != nil ||
        endDate != nil ||
        minTime != nil ||
        maxTime != nil
    }
}

struct WorkoutFilter {
    var exerciseName: String?
    var minReps: Int?
    var maxReps: Int?
    var startDate: Date?
    var endDate: Date?
    var minTime: TimeInterval?
    var maxTime: TimeInterval?
}
