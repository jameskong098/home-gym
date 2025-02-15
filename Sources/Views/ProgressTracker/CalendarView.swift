import SwiftUI

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let workoutDates: Set<Date>
    private let calendar = Calendar.current
    private let daysOfWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 8) {
            monthYearHeader
            daysOfWeekHeader
            daysGrid
        }
        .padding(10)
    }
    
    private var monthYearHeader: some View {
        HStack {
            Text(selectedDate.formatted(.dateTime.month(.wide).year()))
                .font(.title3.bold())
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 12)
            
            Spacer()
            
            HStack(spacing: 10) {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                }
                Button(action: goToToday) {
                    Text("Today")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            Capsule()
                                .stroke(Color.blue, lineWidth: 1)
                        )
                }
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                }
            }
        }
        .padding(.bottom, 8)
    }
    
    private var daysOfWeekHeader: some View {
        HStack {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
            }
        }
    }
    
    private var daysGrid: some View {
        let days = daysInMonth()
        return LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
            ForEach(days, id: \.self) { date in
                if let date = date {
                    DayCell(
                        date: date,
                        isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                        hasWorkout: workoutDates.contains(calendar.startOfDay(for: date)),
                        onTap: { selectedDate = date }
                    )
                } else {
                    Color.clear
                        .frame(height: 35)
                }
            }
        }
    }
    
    private func daysInMonth() -> [Date?] {
        let interval = calendar.dateInterval(of: .month, for: selectedDate)!
        let firstWeekday = calendar.component(.weekday, from: interval.start)
        let offsetDays = firstWeekday - 1
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)!.count
        
        var days: [Date?] = Array(repeating: nil, count: offsetDays)
        
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: interval.start) {
                days.append(date)
            }
        }
        
        let remainingCells = 42 - days.count
        days += Array(repeating: nil, count: remainingCells)
        
        return days
    }
    
    private func previousMonth() {
        if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func nextMonth() {
        if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    private func goToToday() {
        selectedDate = Date()
    }
}

struct DayCell: View {
    @Environment(\.colorScheme) private var colorScheme
    let date: Date
    let isSelected: Bool
    let hasWorkout: Bool
    let onTap: () -> Void
    
    private let calendar = Calendar.current
    
    private var highlightOutlineColor: Color {
        colorScheme == .dark ? Theme.calendarHighlightOutlineDark : Theme.calendarHighlightOutlineLight
    }
    
    var body: some View {
        Button(action: onTap) {
            Text("\(calendar.component(.day, from: date))")
                .font(.system(size: 16))
                .frame(height: 35)
                .frame(maxWidth: .infinity)
                .foregroundColor(hasWorkout ? .white : .primary)
                .background(
                    ZStack {
                        if hasWorkout {
                            Circle()
                                .fill(Color.blue.opacity(0.50))
                        }
                        if isSelected {
                            Circle()
                                .stroke(highlightOutlineColor, lineWidth: 4)
                                .background(Circle().fill(Color.blue.opacity(0.1)))
                        }
                    }
                )
        }
    }
}
