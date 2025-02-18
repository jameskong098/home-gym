import SwiftUI

struct StreakView: View {
    let value: Int
    let label: String
    
    var body: some View {
        VStack {
            HStack(spacing: 4) {
                Text("\(value)")
                    .font(.title)
                    .bold()
                    .foregroundColor(.orange)
                Image(systemName: label.contains("Current") ? "flame.circle.fill" : "trophy.fill")
                    .foregroundColor(.orange)
            }
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
