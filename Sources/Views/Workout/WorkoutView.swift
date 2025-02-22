/*
  WorkoutView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view presents the exercise selection interface with categorized workouts,
  favorite exercise management, and navigation to individual exercise views
  using an adaptive grid layout with animated transitions.
*/

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
    
    private let exercises: [(section: String, items: [ExerciseItem])] = [
        ("Cardio", [
            ExerciseItem(name: "Jumping Jacks", icon: "figure.mixed.cardio"),
            ExerciseItem(name: "High Knees", icon: "figure.highintensity.intervaltraining")
        ]),
        ("Lower Body", [
            ExerciseItem(name: "Basic Squats", icon: "figure.cross.training"),
            ExerciseItem(name: "Wall Squats", icon: "figure.cross.training"),
            ExerciseItem(name: "Lunges", icon: "figure.strengthtraining.functional"),
            ExerciseItem(name: "Standing Side Leg Raises", icon: "figure.walk")
        ]),
        ("Core", [
            ExerciseItem(name: "Pilates Sit-Ups Hybrid", icon: "figure.core.training"),
            ExerciseItem(name: "Planks", icon: "figure.wrestling")
        ]),
        ("Upper Body", [
            ExerciseItem(name: "Push-Ups", icon: "figure.wrestling"),
            ExerciseItem(name: "Bicep Curls - Simultaneous", icon: "dumbbell.fill"),
            ExerciseItem(name: "Lateral Raises", icon: "figure"),
            ExerciseItem(name: "Front Raises", icon: "figure.martial.arts")
        ]),
    ]
    
    private var favoriteItems: [ExerciseItem] {
        exercises.flatMap { $0.items }
            .filter { favoriteExercises.contains($0.name) }
    }
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    @State private var favoriteItemsOpacity: Double = 1.0
    @State private var favoriteItemsScale: CGFloat = 1.0
    
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
                            ForEach(favoriteItems) { exercise in
                                ExerciseButton(
                                    name: exercise.name,
                                    icon: exercise.icon,
                                    selectedTab: $selectedTab,
                                    navPath: $navPath,
                                    isFavorite: favoriteExercises.contains(exercise.name),
                                    onFavoriteToggle: toggleFavorite
                                )
                                .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .opacity(favoriteItemsOpacity)
                        .scaleEffect(favoriteItemsScale)
                    }
                }
                
                ForEach(exercises, id: \.section) { section in
                    VStack(alignment: .leading, spacing: 16) {
                        Text(section.section)
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(section.items) { exercise in
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
            .animation(.spring(response: 0.3, dampingFraction: 0.8), value: favoriteItems)
        }
    }
    
    private func toggleFavorite(_ name: String) {
        withAnimation {
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
}

struct ExerciseButton: View {
    let name: String
    let icon: String
    @Binding var selectedTab: Int
    @Binding var navPath: [String]
    let isFavorite: Bool
    let onFavoriteToggle: (String) -> Void
    
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            NavigationLink(destination: ExerciseView(selectedTab: $selectedTab, navPath: $navPath, exerciseName: name)) {
                VStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(Color(colorScheme == .dark ? Theme.exerciseListItemIconColorDark : Theme.exerciseListItemIconColorLight))
                        .frame(width: 40, height: 40)
                        .background(Color(colorScheme == .dark ? Theme.exerciseListItemBackgroundColorDark : Theme.exerciseListItemBackgroundColorLight))
                        .clipShape(Circle())
                    
                    Text(name)
                        .font(.headline)
                        .foregroundColor(Color(colorScheme == .dark ? Theme.exerciseListItemTextColorDark : Theme.exerciseListItemTextColorLight))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 120)
                .padding()
                .background(Color(colorScheme == .dark ? Theme.exerciseListBackgroundColorDark : Theme.exerciseListBackgroundColorLight))
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

struct ExerciseItem: Equatable, Identifiable {
    let id: String
    let name: String
    let icon: String
    
    init(name: String, icon: String) {
        self.id = name
        self.name = name
        self.icon = icon
    }
}
