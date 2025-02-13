import SwiftUI

struct CompactAchievementsView: View {
    let achievements: [Achievement]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Group {
                Text("Streaks")
                    .font(.subheadline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(achievements.filter { $0.title.contains("Days") || $0.title.contains("Year") }, id: \.title) { achievement in
                            CompactAchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Group {
                Text("Reps")
                    .font(.subheadline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(achievements.filter { $0.title.contains("Reps") }, id: \.title) { achievement in
                            CompactAchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Group {
                Text("Duration")
                    .font(.subheadline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(achievements.filter { $0.title.contains("Hour") }, id: \.title) { achievement in
                            CompactAchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
            
            Group {
                Text("Calories")
                    .font(.subheadline)
                    .padding(.horizontal)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(achievements.filter { $0.title.contains("Calories") }, id: \.title) { achievement in
                            CompactAchievementBadge(achievement: achievement)
                        }
                    }
                    .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
        .background(Theme.sectionBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
}

struct CompactAchievementBadge: View {
    let achievement: Achievement
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: achievement.imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 48, height: 48)
                .foregroundColor(achievement.earned ? .yellow : .gray.opacity(0.5))
            
            Text(achievement.title)
                .font(.system(size: 13))
                .multilineTextAlignment(.center)
                .foregroundColor(achievement.earned ? .primary : .secondary)
        }
        .padding(12)
        .frame(width: 120, height: 120)
        .background(achievement.earned ? Color.yellow.opacity(0.1) : Color.clear)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(achievement.earned ? Color.yellow : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct AchievementsView: View {
    let achievements: [Achievement]

    var body: some View {
        VStack(spacing: 10) {
            Text("Achievements")
                .font(.headline)
            ForEach(achievements, id: \.title) { achievement in
                AchievementBadge(title: achievement.title, imageName: achievement.imageName, earned: achievement.earned)
            }
        }
    }
}

struct AchievementBadge: View {
    let title: String
    let imageName: String
    let earned: Bool
    
    var body: some View {
        VStack {
            Image(systemName: imageName)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
                .foregroundColor(earned ? .yellow : .gray.opacity(0.5))
            
            Text(title)
                .font(.system(size: 10))
                .multilineTextAlignment(.center)
                .foregroundColor(earned ? .primary : .secondary)
        }
        .padding(8)
        .frame(width: 80, height: 80)
        .background(earned ? Color.yellow.opacity(0.1) : Color.clear)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(earned ? Color.yellow : Color.gray.opacity(0.2), lineWidth: 1)
        )
    }
}

struct Achievement {
    let title: String
    let imageName: String
    let condition: (Int) -> Bool
    var earned: Bool = false
}
