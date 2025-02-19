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

    init() {
        configureTips()
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedWalkthrough {
                MainContentView()
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
}
