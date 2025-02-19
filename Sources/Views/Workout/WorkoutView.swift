import SwiftUI

struct WorkoutView: View {
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    
    @AppStorage("favoriteExercises") private var favoriteExercisesData: Data = Data()
    
    private var favoriteExercises: [String] {
        get {
            if let decoded = try? JSONDecoder().decode([String].self, from: favoriteExercisesData) {
                return decoded
            }
            return []
        }
        set {
            if let encoded = try? JSONEncoder().encode(newValue) {
                favoriteExercisesData = encoded
            }
        }
    }
    
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
        ("Core", [
            ("Pilates Sit-Ups Hybrid", "figure.core.training"),
            ("Planks", "figure.wrestling")
        ]),
        ("Upper Body", [
            ("Push-Ups", "figure.wrestling"),
            ("Bicep Curls - Simultaneous", "dumbbell.fill"),
            ("Lateral Raises", "figure"),
            ("Front Raises", "figure.martial.arts")
        ]),
    ]
    
    private var favoriteItems: [(name: String, icon: String)] {
        exercises.flatMap { $0.items }
            .filter { favoriteExercises.contains($0.name) }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                if !favoriteItems.isEmpty {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Favorites")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(favoriteItems, id: \.name) { exercise in
                                ExerciseButton(
                                    name: exercise.name,
                                    icon: exercise.icon,
                                    selectedTab: $selectedTab,
                                    navPath: $navPath,
                                    isFavorite: favoriteExercises.contains(exercise.name),
                                    onFavoriteToggle: toggleFavorite
                                )
                            }
                        }
                    }
                }
                
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
                                    navPath: $navPath,
                                    isFavorite: favoriteExercises.contains(exercise.name),
                                    onFavoriteToggle: toggleFavorite
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func toggleFavorite(_ name: String) {
        if let decoded = try? JSONDecoder().decode([String].self, from: favoriteExercisesData) {
            var currentFavorites = decoded
            if currentFavorites.contains(name) {
                currentFavorites.removeAll { $0 == name }
            } else {
                currentFavorites.append(name)
            }
            if let encoded = try? JSONEncoder().encode(currentFavorites) {
                favoriteExercisesData = encoded
            }
        } else {
            if let encoded = try? JSONEncoder().encode([name]) {
                favoriteExercisesData = encoded
            }
        }
    }
}

struct ExerciseButton: View {
    let name: String
    let icon: String
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    let isFavorite: Bool
    let onFavoriteToggle: (String) -> Void
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
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
            
            Button(action: {
                onFavoriteToggle(name)
            }) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundColor(isFavorite ? .yellow : .gray)
                    .font(.system(size: 22))
                    .padding(12)
            }
        }
    }
}
