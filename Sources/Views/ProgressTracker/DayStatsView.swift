/*
  DayStatsView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view displays daily workout statistics and exercise breakdowns,
  showing total reps, duration, calories, and detailed exercise metrics.
*/

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
    
    private var totalCaloriesBurned: Double {
        dayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
    }
    
    private func exerciseBreakdown() -> [(exercise: String, reps: Int, duration: TimeInterval, calories: Double)] {
        Dictionary(grouping: dayWorkouts, by: { $0.exerciseName })
            .map { (
                exercise: $0.key,
                reps: $0.value.reduce(0) { $0 + $1.repCount },
                duration: $0.value.reduce(0) { $0 + $1.elapsedTime },
                calories: $0.value.reduce(0) { $0 + $1.caloriesBurned }
            )}
            .sorted { first, second in
                if first.reps != second.reps {
                    return first.reps > second.reps
                }
                if first.duration != second.duration {
                    return first.duration > second.duration
                }
                if first.calories != second.calories {
                    return first.calories > second.calories
                }

                return first.exercise < second.exercise
            }
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
                    label: "Reps"
                )
                
                StatItem(
                    icon: "clock.fill",
                    value: formatDuration(totalTime),
                    label: "Duration"
                )
                
                StatItem(
                    icon: "flame.fill",
                    value: String(format: "%.2f", totalCaloriesBurned),
                    label: "Calories"
                )
            }
            .padding(.horizontal)
            
            Divider()
                .padding(.horizontal)
            
            Text("Exercise Breakdown")
                .font(.headline)
                .padding(.horizontal)
            
            ScrollView {
                VStack(alignment: .leading, spacing: 11) {
                    ForEach(exerciseBreakdown(), id: \.exercise) { breakdown in
                        ExerciseRow(
                            exercise: breakdown.exercise,
                            reps: breakdown.reps, 
                            duration: breakdown.duration,
                            calories: breakdown.calories
                        )
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
    let duration: TimeInterval
    let calories: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(exercise)
                    .font(.subheadline)
                Spacer()
                Text("\(reps) reps, \(formatDuration(duration)), \(String(format: "%.0f", calories)) cal")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
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
}
