import SwiftUI

struct ProgressTracker: View {
    var body: some View {
        VStack(spacing: 20) {
            ProgressBar(progress: 0.7, title: "Weekly Goal")
            ProgressBar(progress: 0.5, title: "Daily Goal")
            
            Spacer()
        }
        .padding()
    }
}

struct ProgressBar: View {
    let progress: Double
    let title: String

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)

            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .frame(height: 20)
                    .foregroundColor(.gray.opacity(0.3))
                RoundedRectangle(cornerRadius: 10)
                    .frame(width: CGFloat(progress * 300), height: 20)
                    .foregroundColor(.blue)
            }
        }
    }
}
