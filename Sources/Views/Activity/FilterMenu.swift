import SwiftUI

struct FilterMenu: View {
    @ObservedObject var filterModel: WorkoutFilterModel
    @Environment(\.dismiss) private var dismiss
    let workouts: [WorkoutData]
    
    @State private var repsRange: ClosedRange<Double>
    @State private var dateRange: ClosedRange<Date>
    @State private var durationRange: ClosedRange<Double>
    
    private var minReps: Double {
        Double(workouts.min { $0.repCount < $1.repCount }?.repCount ?? 0)
    }
    
    private var maxReps: Double {
        Double(workouts.max { $0.repCount < $1.repCount }?.repCount ?? 100)
    }
    
    private var minDate: Date {
        workouts.min { $0.date < $1.date }?.date ?? Calendar.current.date(byAdding: .month, value: -1, to: Date())!
    }
    
    private var maxDate: Date {
        workouts.max { $0.date < $1.date }?.date ?? Date()
    }
    
    private var minDuration: Double {
        workouts.min { $0.elapsedTime < $1.elapsedTime }?.elapsedTime ?? 0
    }
    
    private var maxDuration: Double {
        workouts.max { $0.elapsedTime < $1.elapsedTime }?.elapsedTime ?? 300
    }
    
    init(filterModel: WorkoutFilterModel, workouts: [WorkoutData]) {
        self.filterModel = filterModel
        self.workouts = workouts
        
        let minReps = Double(workouts.min { $0.repCount < $1.repCount }?.repCount ?? 0)
        let maxReps = Double(workouts.max { $0.repCount < $1.repCount }?.repCount ?? 100)
        let initialMinReps = Double(Int(filterModel.minReps) ?? Int(minReps))
        let initialMaxReps = Double(Int(filterModel.maxReps) ?? Int(maxReps))
        self._repsRange = State(initialValue: initialMinReps...initialMaxReps)
        
        let minDate = workouts.min { $0.date < $1.date }?.date ?? Calendar.current.date(byAdding: .month, value: -1, to: Date())!
        let maxDate = workouts.max { $0.date < $1.date }?.date ?? Date()
        let initialStartDate = filterModel.startDate ?? minDate
        let initialEndDate = filterModel.endDate ?? maxDate
        self._dateRange = State(initialValue: initialStartDate...initialEndDate)
        
        let minDur = workouts.min { $0.elapsedTime < $1.elapsedTime }?.elapsedTime ?? 0
        let maxDur = workouts.max { $0.elapsedTime < $1.elapsedTime }?.elapsedTime ?? 300
        let initialMinDur = filterModel.minTime ?? minDur
        let initialMaxDur = filterModel.maxTime ?? maxDur
        self._durationRange = State(initialValue: initialMinDur...initialMaxDur)
    }
    
    private let exerciseTypes = [
        "Jumping Jacks",
        "High Knees", 
        "Basic Squats",
        "Wall Squats",
        "Lunges",
        "Push-Ups",
        "Bicep Curls - Simultaneous",
        "Pilates Sit-Ups Hybrid"
    ]
    
    private func formatDuration(_ seconds: Double) -> String {
        let minutes = Int(seconds) / 60
        let remainingSeconds = Int(seconds) % 60
        return String(format: "%d:%02d", minutes, remainingSeconds)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Exercise")) {
                    Picker("Exercise Type", selection: $filterModel.exerciseName) {
                        Text("All Exercises").tag("")
                        ForEach(exerciseTypes, id: \.self) { exercise in
                            Text(exercise).tag(exercise)
                        }
                    }
                }
                
                Section(header: Text("Reps Range")) {
                    RangeSlider(range: $repsRange, bounds: minReps...maxReps)
                        .frame(height: 44)
                        .onChange(of: repsRange) { newValue in
                            filterModel.minReps = String(Int(newValue.lowerBound))
                            filterModel.maxReps = String(Int(newValue.upperBound))
                        }
                    HStack {
                        Text("\(Int(repsRange.lowerBound))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(Int(repsRange.upperBound))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Date Range")) {
                    DateRangeSlider(range: $dateRange, bounds: minDate...maxDate)
                        .frame(height: 44)
                        .onChange(of: dateRange) { newValue in
                            filterModel.startDate = newValue.lowerBound
                            filterModel.endDate = newValue.upperBound
                        }
                    HStack {
                        Text(dateRange.lowerBound, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(dateRange.upperBound, style: .date)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section(header: Text("Duration Range")) {
                    RangeSlider(range: $durationRange, bounds: minDuration...maxDuration)
                        .frame(height: 44)
                        .onChange(of: durationRange) { newValue in
                            filterModel.minTime = newValue.lowerBound
                            filterModel.maxTime = newValue.upperBound
                        }
                    HStack {
                        Text(formatDuration(durationRange.lowerBound))
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(formatDuration(durationRange.upperBound))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Section {
                    Button("Clear Filters") {
                        filterModel.exerciseName = ""
                        filterModel.minReps = ""
                        filterModel.maxReps = ""
                        filterModel.startDate = nil
                        filterModel.endDate = nil
                        filterModel.minTime = nil
                        filterModel.maxTime = nil
                        repsRange = minReps...maxReps
                        dateRange = minDate...maxDate
                        durationRange = minDuration...maxDuration
                    }
                }
            }
            .navigationTitle("Filter Workouts")
            .navigationBarItems(trailing: Button("Done") { dismiss() })
            .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : nil)
        }
        .frame(maxWidth: UIDevice.current.userInterfaceIdiom == .pad ? 400 : nil)
    }
}

struct RangeSlider: View {
    @Binding var range: ClosedRange<Double>
    let bounds: ClosedRange<Double>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: geometry.size.width - 56, height: 4)
                    .padding(.horizontal, 28)
                    .padding(.top, 7)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width(for: range, in: geometry),
                           height: 4)
                    .offset(x: xOffset(for: range.lowerBound, in: geometry))
                    .padding(.horizontal, 28)
                    .padding(.top, 7)
                
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 28, height: 28)
                        .offset(x: xOffset(for: range.lowerBound, in: geometry))
                        .gesture(DragGesture()
                            .onChanged { value in
                                updateLowerBound(value, in: geometry)
                            })
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 28, height: 28)
                        .offset(x: xOffset(for: range.upperBound, in: geometry) - 28)
                        .gesture(DragGesture()
                            .onChanged { value in
                                updateUpperBound(value, in: geometry)
                            })
                }
            }
            .padding(.horizontal, 14)
        }
    }
    
    private func width(for range: ClosedRange<Double>, in geometry: GeometryProxy) -> CGFloat {
        let ratio = (range.upperBound - range.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return (geometry.size.width - 56) * CGFloat(ratio)
    }
    
    private func xOffset(for value: Double, in geometry: GeometryProxy) -> CGFloat {
        let ratio = (value - bounds.lowerBound) / (bounds.upperBound - bounds.lowerBound)
        return (geometry.size.width - 56) * CGFloat(ratio)
    }
    
    private func updateLowerBound(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        let ratio = value.location.x / (geometry.size.width - 56)
        let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(ratio)
        let minDistance = (bounds.upperBound - bounds.lowerBound) * 0.05
        let maxAllowedValue = range.upperBound - minDistance
        range = min(max(newValue, bounds.lowerBound), maxAllowedValue)...range.upperBound
    }
    
    private func updateUpperBound(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        let ratio = value.location.x / (geometry.size.width - 56)
        let newValue = bounds.lowerBound + (bounds.upperBound - bounds.lowerBound) * Double(ratio)
        let minDistance = (bounds.upperBound - bounds.lowerBound) * 0.05
        let minAllowedValue = range.lowerBound + minDistance
        range = range.lowerBound...max(min(newValue, bounds.upperBound), minAllowedValue)
    }
}

struct DateRangeSlider: View {
    @Binding var range: ClosedRange<Date>
    let bounds: ClosedRange<Date>
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: geometry.size.width - 56, height: 4)
                    .padding(.horizontal, 28)
                
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: width(for: range, in: geometry),
                           height: 4)
                    .offset(x: xOffset(for: range.lowerBound, in: geometry))
                    .padding(.horizontal, 28) 
                
                HStack(spacing: 0) {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 28, height: 28)
                        .offset(x: xOffset(for: range.lowerBound, in: geometry))
                        .gesture(DragGesture()
                            .onChanged { value in
                                updateLowerBound(value, in: geometry)
                            })
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 28, height: 28)
                        .offset(x: xOffset(for: range.upperBound, in: geometry) - 28)
                        .gesture(DragGesture()
                            .onChanged { value in
                                updateUpperBound(value, in: geometry)
                            })
                }
            }
            .padding(.horizontal, 14)
        }
    }
    
    private func width(for range: ClosedRange<Date>, in geometry: GeometryProxy) -> CGFloat {
        let ratio = (range.upperBound.timeIntervalSince1970 - range.lowerBound.timeIntervalSince1970) / 
                   (bounds.upperBound.timeIntervalSince1970 - bounds.lowerBound.timeIntervalSince1970)
        return (geometry.size.width - 56) * CGFloat(ratio)
    }
    
    private func xOffset(for date: Date, in geometry: GeometryProxy) -> CGFloat {
        let ratio = (date.timeIntervalSince1970 - bounds.lowerBound.timeIntervalSince1970) / 
                   (bounds.upperBound.timeIntervalSince1970 - bounds.lowerBound.timeIntervalSince1970)
        return (geometry.size.width - 56) * CGFloat(ratio)
    }
    
    private func updateLowerBound(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        let ratio = value.location.x / (geometry.size.width - 56)
        let totalTimeInterval = bounds.upperBound.timeIntervalSince1970 - bounds.lowerBound.timeIntervalSince1970
        let newDate = Date(timeIntervalSince1970: bounds.lowerBound.timeIntervalSince1970 + totalTimeInterval * Double(ratio))
        
        // Minimum distance of 1 day (86400 seconds)
        let minTimeInterval: TimeInterval = 86400
        let maxAllowedDate = Date(timeIntervalSince1970: range.upperBound.timeIntervalSince1970 - minTimeInterval)
        
        range = min(max(newDate, bounds.lowerBound), maxAllowedDate)...range.upperBound
    }
    
    private func updateUpperBound(_ value: DragGesture.Value, in geometry: GeometryProxy) {
        let ratio = value.location.x / (geometry.size.width - 56)
        let totalTimeInterval = bounds.upperBound.timeIntervalSince1970 - bounds.lowerBound.timeIntervalSince1970
        let newDate = Date(timeIntervalSince1970: bounds.lowerBound.timeIntervalSince1970 + totalTimeInterval * Double(ratio))
        
        // Minimum distance of 1 day (86400 seconds)
        let minTimeInterval: TimeInterval = 86400
        let minAllowedDate = Date(timeIntervalSince1970: range.lowerBound.timeIntervalSince1970 + minTimeInterval)
        
        range = range.lowerBound...max(min(newDate, bounds.upperBound), minAllowedDate)
    }
}
