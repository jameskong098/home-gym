/*
  App.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This is the main app entry point that manages initial setup and navigation. It sets up configuration
  for TipKit and determines whether to show the walkthrough or main content view based on user completion.
*/

import SwiftUI
import TipKit

@main
struct HomeGymApp: App {
    @AppStorage("hasCompletedWalkthrough") private var hasCompletedWalkthrough = false
    @AppStorage("automaticallyGenerateDemoData") private var automaticallyGenerateDemoData = true
    @State private var showAlert = false

    init() {
        configureTips()
        if automaticallyGenerateDemoData {
            generateDemoData()
            if hasCompletedWalkthrough {
                _showAlert = State(initialValue: true)
            }
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedWalkthrough {
                MainContentView()
                    .alert(isPresented: $showAlert) {
                        Alert(
                            title: Text("Sample Data Added"),
                            message: Text("Randomized sample data has been added to your activity history for demo purposes. If you would like to generate new data, you can go to the \"Developer Tools\" section within the settings view. You can also turn off randomized sample data generation in the same section."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
            } else {
                WalkthroughView()
            }
        }
    }

    private func configureTips() {
        do {
            if #available(iOS 17.0, *) {
                try Tips.configure()
                print("Tips configured successfully")
            } else {
                print("Tips not available on this version of iOS")
                // Fallback on earlier versions
            }
            print("Tips configured successfully")
        } catch {
            print("Error configuring tips: \(error)")
        }
    }

    private func generateDemoData() {
        let workouts = DataGenerator.generateTestData()
        if let encoded = try? JSONEncoder().encode(workouts) {
            UserDefaults.standard.set(encoded, forKey: "workouts")
        }
    }
}
