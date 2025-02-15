import SwiftUI

struct WorkoutView: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    
    private let exercises: [(section: String, items: [(name: String, icon: String)])] = [
        ("Cardio", [
            ("Jumping Jacks", "figure.mixed.cardio"),
            ("High Knees", "figure.highintensity.intervaltraining")
        ]),
        ("Lower Body", [
            ("Basic Squats", "figure.cross.training"),
            ("Wall Squats", "figure.cross.training"),
            ("Lunges", "figure.strengthtraining.functional")
        ]),
        ("Upper Body", [
            ("Push-Ups", "figure.wrestling"),
            ("Bicep Curls - Simultaneous", "dumbbell.fill")
        ]),
        ("Core", [
            ("Pilates Sit-Ups Hybrid", "figure.core.training")
        ])
    ]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                ForEach(exercises, id: \.section) { section in
                    VStack(alignment: .leading, spacing: 16) {
                        Text(section.section)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(section.items, id: \.name) { exercise in
                                ExerciseButton(
                                    name: exercise.name,
                                    icon: exercise.icon,
                                    selectedTab: $selectedTab,
                                    navPath: $navPath
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
}

struct ExerciseButton: View {
    let name: String
    let icon: String
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    
    var body: some View {
        NavigationLink(destination: ExerciseView(selectedTab: $selectedTab, navPath: $navPath, exerciseName: name)) {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(Color(UIColor { traitCollection in
                        if traitCollection.userInterfaceStyle == .dark {
                            return Theme.exerciseListItemIconColorDark
                        } else {
                            return Theme.exerciseListItemIconColorLight
                        }
                    }))
                    .frame(width: 40, height: 40)
                    .background(Color(UIColor { traitCollection in
                        if traitCollection.userInterfaceStyle == .dark {
                            return Theme.exerciseListItemBackgroundColorDark
                        } else {
                            return Theme.exerciseListItemBackgroundColorLight
                        }
                    }))
                    .clipShape(Circle())
                
                Text(name)
                    .font(.headline)
                    .foregroundColor(Color(UIColor { traitCollection in
                        if traitCollection.userInterfaceStyle == .dark {
                            return Theme.exerciseListItemTextColorDark
                        } else {
                            return Theme.exerciseListItemTextColorLight
                        }
                    }))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
            .background(Color(UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return Theme.exerciseListBackgroundColorDark
                } else {
                    return Theme.exerciseListBackgroundColorLight
                }
            }))
            .cornerRadius(20)
        }
    }
}
