/*
  WorkoutTrends.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view provides visual analytics and statistics for workout data,
  displaying charts and metrics that update based on selected
  time ranges and measurement types (reps, calories, duration).
*/

import SwiftUI
import Charts

struct WorkoutTrendsView: View {
    let workouts: [WorkoutData]
    @State private var selectedMetric = TrendMetric.reps
    @State private var timeRange = TimeRange.month
    
    enum TrendMetric: String, CaseIterable {
        case reps = "Reps"
        case calories = "Calories"
        case duration = "Duration"
    }
    
    enum TimeRange: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case year = "Year"
        
        var calendar: Calendar.Component {
            switch self {
            case .week: return .weekOfYear
            case .month: return .month
            case .year: return .year
            }
        }
        
        var startDate: Date {
            let calendar = Calendar.current
            let currentDate = Date()
            
            switch self {
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: currentDate) ?? currentDate
            case .month:
                return calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? currentDate
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: currentDate) ?? currentDate
            }
        }
        
        var strideBy: Calendar.Component {
            switch self {
            case .week: return .day
            case .month: return .weekOfYear
            case .year: return .month
            }
        }
    }

    struct ChartData: Identifiable {
        let id = UUID()
        let date: Date
        let value: Double
        let label: String
    }
    
    struct StatsData {
        let totalReps: Int
        let totalCalories: Double
        let totalDuration: Double
        let avgReps: Double
        let avgCalories: Double
        let avgDuration: Double
        let favoriteExercise: String
        let bestDay: (date: Date, value: Double)
    }
        
    private var filteredChartData: [ChartData] {
        let calendar = Calendar.current
        let filteredWorkouts = workouts.filter { $0.date >= timeRange.startDate }
        
        let grouped = Dictionary(grouping: filteredWorkouts) { workout in
            calendar.startOfDay(for: workout.date)
        }
        
        var chartData = grouped.map { date, workouts in
            var value: Double
            let label: String
            
            switch selectedMetric {
            case .reps:
                value = Double(workouts.reduce(0) { $0 + $1.repCount })
                label = "\(Int(value)) reps"
            case .calories:
                value = workouts.reduce(0) { $0 + $1.caloriesBurned }
                label = String(format: "%.0f cal", value)
            case .duration:
                let totalSeconds = workouts.reduce(0) { $0 + $1.elapsedTime }
                value = totalSeconds
                label = formatDuration(totalSeconds)
            }
            
            // Ensure the chart is displayed even with zero values (for when there are not enough workouts)
            if value == 0 {
                value = 0.1
            }
            
            return ChartData(date: date, value: value, label: label)
        }.sorted { $0.date < $1.date }
        
        // Add a default data point if chartData is empty
        if chartData.isEmpty {
            chartData.append(ChartData(date: Date(), value: 0.1, label: ""))
        }
        
        return chartData
    }
    
    private var statsData: StatsData {
        let workouts = filteredWorkouts
        
        let totalReps = workouts.reduce(0) { $0 + $1.repCount }
        let totalCalories = workouts.reduce(0) { $0 + $1.caloriesBurned }
        let totalDuration = workouts.reduce(0) { $0 + $1.elapsedTime }
        
        let avgReps = workouts.isEmpty ? 0 : Double(totalReps) / Double(workouts.count)
        let avgCalories = workouts.isEmpty ? 0 : totalCalories / Double(workouts.count)
        let avgDuration = workouts.isEmpty ? 0 : totalDuration / Double(workouts.count)
        
        let exerciseCounts = Dictionary(grouping: workouts, by: { $0.exerciseName })
            .mapValues { $0.count }
        let favoriteExercise = exerciseCounts.max(by: { $0.value < $1.value })?.key ?? "None"
        
        let bestDay: (date: Date, value: Double) = {
            let grouped = Dictionary(grouping: workouts) { workout in
                Calendar.current.startOfDay(for: workout.date)
            }
            
            let dailyValues = grouped.mapValues { dayWorkouts in
                switch selectedMetric {
                case .reps:
                    return Double(dayWorkouts.reduce(0) { $0 + $1.repCount })
                case .calories:
                    return dayWorkouts.reduce(0) { $0 + $1.caloriesBurned }
                case .duration:
                    return dayWorkouts.reduce(0) { $0 + $1.elapsedTime }
                }
            }
            
            return dailyValues.max(by: { $0.value < $1.value }) ?? (Date(), 0)
        }()
        
        return StatsData(
            totalReps: totalReps,
            totalCalories: totalCalories,
            totalDuration: totalDuration,
            avgReps: avgReps,
            avgCalories: avgCalories,
            avgDuration: avgDuration,
            favoriteExercise: favoriteExercise,
            bestDay: bestDay
        )
    }

    private var filteredWorkouts: [WorkoutData] {
        workouts.filter { $0.date >= timeRange.startDate }
    }
        
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Workout Trends")
                .font(.title2.bold())
            
            Picker("Metric", selection: $selectedMetric.animation()) {
                ForEach(TrendMetric.allCases, id: \.self) { metric in
                    Text(metric.rawValue).tag(metric)
                }
            }
            .pickerStyle(.segmented)
            
            Chart(filteredChartData) { item in
                LineMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .interpolationMethod(.catmullRom)
                
                AreaMark(
                    x: .value("Date", item.date),
                    y: .value("Value", item.value)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: timeRange.strideBy)) { _ in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.month().day())
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel {
                        if let doubleValue = value.as(Double.self) {
                            switch selectedMetric {
                            case .reps:
                                Text("\(Int(doubleValue))")
                            case .calories:
                                Text("\(Int(doubleValue))")
                            case .duration:
                                Text(formatDuration(doubleValue))
                            }
                        }
                    }
                }
            }
            .overlay {
                if filteredChartData.count <= 1 {
                    VStack(spacing: 4) {
                        Text("Need more workout data to show trends")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                        Text("Complete more workouts to see your progress")
                            .font(.title3)
                            .foregroundColor(.secondary.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color(UIColor.systemBackground).opacity(0.9))
                    .cornerRadius(8)
                }
            }
            .animation(.easeInOut, value: selectedMetric)
            .frame(height: 200)
            
            HStack(spacing: 12) {
                ForEach(TimeRange.allCases, id: \.self) { range in
                    Button(action: {
                        withAnimation {
                            timeRange = range
                        }
                    }) {
                        Text(range.rawValue)
                            .font(.subheadline.bold())
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                timeRange == range ?
                                    Color.blue :
                                    Color.clear
                            )
                            .foregroundColor(
                                timeRange == range ?
                                    .white :
                                    .blue
                            )
                            .cornerRadius(8)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.top, 8)
            
            statsSection
                .animation(.easeInOut, value: selectedMetric)
            
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    var statsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Summary")
                .font(.headline)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    StatCard(title: "Average", value: {
                        switch selectedMetric {
                        case .reps: return String(format: "%.0f reps", statsData.avgReps)
                        case .calories: return String(format: "%.0f cal", statsData.avgCalories)
                        case .duration: return formatDuration(statsData.avgDuration)
                        }
                    }())
                    
                    StatCard(title: "Total", value: {
                        switch selectedMetric {
                        case .reps: return "\(statsData.totalReps) reps"
                        case .calories: return String(format: "%.0f cal", statsData.totalCalories)
                        case .duration: return formatDuration(statsData.totalDuration)
                        }
                    }())
                    
                    StatCard(title: "Best Day", value: {
                        let dateFormatter = DateFormatter()
                        dateFormatter.dateFormat = "MMM d"
                        let date = dateFormatter.string(from: statsData.bestDay.date)
                        
                        switch selectedMetric {
                        case .reps: return "\(date): \(Int(statsData.bestDay.value)) reps"
                        case .calories: return "\(date): \(Int(statsData.bestDay.value)) cal"
                        case .duration: return "\(date): \(formatDuration(statsData.bestDay.value))"
                        }
                    }())
                    
                    StatCard(title: "Favorite Exercise", value: statsData.favoriteExercise)
                }
            }
        }
        .padding(.top)
    }
}

struct StatCard: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body.bold())
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(width: 150, alignment: .leading)
        .padding()
        .background(Color(UIColor.tertiarySystemBackground))
        .cornerRadius(10)
        .transition(.opacity.combined(with: .scale))
    }
}

private func formatDuration(_ seconds: Double) -> String {
    let hours = Int(seconds) / 3600
    let minutes = (Int(seconds) % 3600) / 60
    
    if hours > 0 {
        return "\(hours)h \(minutes)m"
    } else {
        return "\(minutes)m"
    }
}
