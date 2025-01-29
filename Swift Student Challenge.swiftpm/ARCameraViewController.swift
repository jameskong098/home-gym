import UIKit
import ARKit
import Vision
import AVFoundation

class ARCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    let exerciseName: String
    var cameraSession: AVCaptureSession?
    
    init(exerciseName: String) {
        self.exerciseName = exerciseName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
    }
    
    private func setupCamera() {
        
        let captureSession = AVCaptureSession()
        guard let videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) else {
            print("No front camera found")
            return
        }
        
        do {
            let videoInput = try AVCaptureDeviceInput(device: videoDevice)
            if captureSession.canAddInput(videoInput) {
                captureSession.addInput(videoInput)
            }
            
            let videoOutput = AVCaptureVideoDataOutput()
            if captureSession.canAddOutput(videoOutput) {
                captureSession.addOutput(videoOutput)
                videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "videoQueue"))
            }
            
            captureSession.startRunning()
            self.cameraSession = captureSession
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    // Mark the method as nonisolated to conform to the protocol's requirement
    nonisolated func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
            guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else { return }
            
            let request = VNDetectHumanBodyPoseRequest { [weak self] request, error in
                if let error = error {
                    print("Error detecting body pose: \(error)")
                    return
                }
                
                guard let results = request.results as? [VNHumanBodyPoseObservation] else { return }
                
                for result in results {
                    do {
                        // 1. Convert to simple value types first
                        let safePoints = try result.recognizedPoints(.all).mapValues { point in
                            return (location: point.location, confidence: point.confidence)
                        }
                        
                        // 2. Pass the simple tuple instead of VNRecognizedPoint
                        DispatchQueue.main.async { [weak self] in
                            self?.processPoseData(safePoints)
                        }
                    } catch {
                        print("Error extracting points: \(error)")
                    }
                }
            }
            
            let handler = VNImageRequestHandler(ciImage: CIImage(cvPixelBuffer: pixelBuffer), options: [:])
            try? handler.perform([request])
        }

        @MainActor
        private func processPoseData(_ points: [VNHumanBodyPoseObservation.JointName: (location: CGPoint, confidence: VNConfidence)]) {
            for (key, point) in points {
                if point.confidence > 0 {
                    print("\(key.rawValue): \(point.location) with confidence \(point.confidence)")
                }
            }
        }
    }
