import SwiftUI
import ARKit
import Vision
import AVFoundation

struct ARCameraView: UIViewControllerRepresentable {
    let exerciseName: String
    @Binding var repCount: Int
    @Binding var showTutorial: Bool

    func makeUIViewController(context: Context) -> ARCameraViewController {
        let viewController = ARCameraViewController(exerciseName: exerciseName)
        viewController.repCountBinding = $repCount
        viewController.showTutorialBinding = $showTutorial
        return viewController
    }

    func updateUIViewController(_ uiViewController: ARCameraViewController, context: Context) {
        // Handle updates to the view controller
    }
}
