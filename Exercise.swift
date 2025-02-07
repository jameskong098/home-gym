import SwiftUI

struct Exercise: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ExerciseButton(name: "Push-Ups", icon: "figure.arms.open", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Sit-Ups", icon: "figure.arms.open", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Planks", icon: "figure.arms.open", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Bicep Curls", icon: "figure.arms.open", selectedTab: $selectedTab, navPath: $navPath)
                ExerciseButton(name: "Jumping Jacks", icon: "figure.arms.open", selectedTab: $selectedTab, navPath: $navPath)
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
        NavigationLink(destination: ARExerciseView(selectedTab: $selectedTab, navPath: $navPath, exerciseName: name)) {
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
