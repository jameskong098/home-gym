import SwiftUI

struct WorkoutView: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ExerciseButton(name: "Jumping Jacks", icon: "figure.mixed.cardio", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "High Knees", icon: "figure.highintensity.intervaltraining", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Basic Squats", icon: "figure.cross.training", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Wall Squats", icon: "figure.cross.training", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Lunges", icon: "figure.strengthtraining.functional", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Push-Ups", icon: "figure.wrestling", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Bicep Curls - Simultaneous", icon: "dumbbell.fill", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Pilates Sit-Ups Hybrid", icon: "figure.core.training", selectedTab: $selectedTab, navPath: $navPath)
                Spacer()
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
            HStack {
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
                
                Spacer()
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color(UIColor { traitCollection in
                if traitCollection.userInterfaceStyle == .dark {
                    return Theme.exerciseListBackgroundColorDark
                } else {
                    return Theme.exerciseListBackgroundColorLight
                }
            }))
            .cornerRadius(40)
        }
    }
}
