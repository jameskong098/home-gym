import SwiftUI
import ARKit
import Vision
import AVFoundation

struct ARCameraView: UIViewControllerRepresentable {
    let exerciseName: String

    func makeUIViewController(context: Context) -> ARCameraViewController {
        print("RUNNING")
        return ARCameraViewController(exerciseName: exerciseName)
    }

    func updateUIViewController(_ uiViewController: ARCameraViewController, context: Context) {
        // Handle updates to the view controller
    }
}
