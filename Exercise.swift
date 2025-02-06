import SwiftUI

struct Exercise: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                ExerciseButton(name: "Push-Ups", icon: "figure.arms.open")
                ExerciseButton(name: "Sit-Ups", icon: "figure.arms.open")
                ExerciseButton(name: "Planks", icon: "figure.arms.open")
                ExerciseButton(name: "Bicep Curls", icon: "figure.arms.open")
                ExerciseButton(name: "Jumping Jacks", icon: "figure.arms.open")
                Spacer()
            }
            .padding()
        }
    }
}

struct ExerciseButton: View {
    let name: String
    let icon: String
    
    var body: some View {
        NavigationLink(destination: ARExerciseView(exerciseName: name)) {
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
