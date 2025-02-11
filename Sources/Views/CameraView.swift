import SwiftUI
import ARKit
import Vision
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    let exerciseName: String
    @Binding var repCount: Int
    @Binding var showTutorial: Bool

    func makeUIViewController(context: Context) -> CameraViewController {
        let viewController = CameraViewController(exerciseName: exerciseName)
        viewController.repCountBinding = $repCount
        viewController.showTutorialBinding = $showTutorial
        return viewController
    }

    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
        // Handle updates to the view controller
    }
}
