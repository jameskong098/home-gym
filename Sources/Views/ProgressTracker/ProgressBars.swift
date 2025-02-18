import SwiftUI

struct ProgressBar: View {
    let progress: Double
    let title: String
    let color: Color
    let currentValue: Int
    let goalValue: Int
    let goalType: GoalType
    
    private var unitLabel: String {
        switch goalType {
        case .reps:
            return "Reps"
        case .duration:
            return "mins"
        case .calories:
            return "cal"
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Spacer()
                Text("\(currentValue)/\(goalValue) \(unitLabel)")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.secondary)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .frame(height: 14)
                        .foregroundColor(.gray.opacity(0.2))
                    
                    Capsule()
                        .frame(width: geometry.size.width * CGFloat(progress), height: 14)
                        .foregroundColor(color)
                        .animation(.easeInOut, value: progress)
                }
            }
            .frame(height: 14)
        }
        .padding(.vertical, 4)
    }
}

struct CircularProgressBar: View {
    let progress: Double
    let title: String
    let color: Color
    let currentValue: Int
    let goalValue: Int
    let goalType: GoalType
    
    private var gradient: AngularGradient {
        switch goalType {
        case .reps:
            return AngularGradient(
                gradient: Gradient(colors: [.green, .mint, .teal]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        case .duration:
            return AngularGradient(
                gradient: Gradient(colors: [.blue, .cyan, .indigo]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        case .calories:
            return AngularGradient(
                gradient: Gradient(colors: [.orange, .red, .pink]),
                center: .center,
                startAngle: .degrees(0),
                endAngle: .degrees(360)
            )
        }
    }
    
    private var unitLabel: String {
        switch goalType {
        case .reps:
            return "Reps"
        case .duration:
            return "mins"
        case .calories:
            return "cal"
        }
    }
    
    var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke(lineWidth: 10)
                    .opacity(0.3)
                    .foregroundColor(color)
                
                Circle()
                    .trim(from: 0.0, to: CGFloat(min(progress, 1.0)))
                    .stroke(gradient, style: StrokeStyle(lineWidth: 10, lineCap: .round, lineJoin: .round))
                    .rotationEffect(Angle(degrees: 270.0))
                    .animation(.linear, value: progress)
                
                VStack {
                    Text("\(currentValue)/\(goalValue)")
                        .font(.headline)
                        .bold()
                    Text(unitLabel)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .frame(width: 100, height: 100)
            .padding(.bottom, 10)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}
