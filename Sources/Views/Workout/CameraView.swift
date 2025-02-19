/*
  CameraView.swift
  Home Gym

  Created by James Deming Kong
  Part of Swift Student Challenge 2025

  This view bridges SwiftUI with UIKit camera controller for live video capture,
  enabling real-time exercise tracking and rep counting using Vision framework.
*/

import SwiftUI
import Vision
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let exerciseName: String
    var repCount: Binding<Int>
    var showTutorial: Binding<Bool>
    var showCountdown: Binding<Bool>
    var showExerciseSummary: Binding<Bool>
    var isPaused: Binding<Bool>

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController(exerciseName: exerciseName)
        viewController.repCountBinding = repCount
        viewController.showTutorialBinding = showTutorial
        viewController.showCountdown = showCountdown
        viewController.showExerciseSummary = showExerciseSummary
        viewController.isPaused = isPaused
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Handle updates to the view controller
    }
}
