import SwiftUI

struct DayStatsView: View {
    let selectedDate: Date
    let workouts: [WorkoutData]
    private let calendar = Calendar.current
    
    private var dayWorkouts: [WorkoutData] {
        workouts.filter { calendar.isDate($0.date, inSameDayAs: selectedDate) }
    }
    
    private var totalReps: Int {
        dayWorkouts.reduce(0) { $0 + $1.repCount }
    }
    
    private var totalTime: TimeInterval {
        dayWorkouts.reduce(0) { $0 + $1.elapsedTime }
    }
    
    private func exerciseBreakdown() -> [(exercise: String, reps: Int)] {
        Dictionary(grouping: dayWorkouts, by: { $0.exerciseName })
            .map { (exercise: $0.key, reps: $0.value.reduce(0) { $0 + $1.repCount }) }
            .sorted { $0.reps > $1.reps }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        let seconds = Int(duration) % 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m \(seconds)s"
        } else if minutes > 0 {
            return "\(minutes)m \(seconds)s"
        } else {
            return "\(seconds)s"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Daily Overview")
                .font(.title3)
                .fontWeight(.bold)
                .padding(.horizontal)
            
            HStack(spacing: 20) {
                StatItem(
                    icon: "figure.strengthtraining.traditional",
                    value: "\(totalReps)",
                    label: "Total Reps"
                )
                
                StatItem(
                    icon: "clock.fill",
                    value: formatDuration(totalTime),
                    label: "Duration"
                )
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            Text("Exercise Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(exerciseBreakdown(), id: \.exercise) { breakdown in
                        ExerciseRow(exercise: breakdown.exercise, reps: breakdown.reps)
                    }
                    if exerciseBreakdown().isEmpty {
                        VStack(spacing: 8) {
                            Spacer()
                                .frame(height: 50)
                            Image(systemName: "moon.zzz.fill")
                                .font(.largeTitle)
                                .foregroundColor(.gray)
                            Text("No workouts recorded")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Spacer()
                                .frame(height: 50)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding(.vertical)
    }
}

struct StatItem: View {
    let icon: String
    let value: String
    let label: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(.blue)
                Text(value)
                    .font(.headline)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

struct ExerciseRow: View {
    let exercise: String
    let reps: Int
    
    var body: some View {
        HStack {
            Text(exercise)
                .font(.subheadline)
            Spacer()
            Text("\(reps) reps")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 4)
    }
}
