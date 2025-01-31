import UIKit
import ARKit
import Vision
import AVFoundation

class ARCameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate, ARSessionDelegate {
    let exerciseName: String
    var cameraSession: AVCaptureSession?
    var previewLayer: AVCaptureVideoPreviewLayer!
    var overlayLayer: CALayer!
    
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
        setupOverlay()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
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
            
            previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
        } catch {
            print("Error setting up camera: \(error)")
        }
    }
    
    private func setupOverlay() {
        overlayLayer = CALayer()
        overlayLayer.frame = self.view.bounds
        self.view.layer.addSublayer(overlayLayer)
    }
    
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
                    let safePoints = try result.recognizedPoints(.all).mapValues { point in
                        return (location: point.location, confidence: point.confidence)
                    }
                    
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
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        let showPoints = UserDefaults.standard.bool(forKey: "showBodyTrackingPoints")
        let showLabels = UserDefaults.standard.bool(forKey: "showBodyTrackingLabels")
        let showLines = UserDefaults.standard.bool(forKey: "showBodyTrackingLines")
        
        var jointPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        
        for (key, point) in points {
            if point.confidence > 0 {
                let normalizedPoint = CGPoint(x: point.location.x, y: 1 - point.location.y)
                let screenPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
                jointPoints[key] = screenPoint
                
                if showPoints {
                    let circleLayer = CAShapeLayer()
                    let circlePath = UIBezierPath(arcCenter: screenPoint, radius: 5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                    circleLayer.path = circlePath.cgPath
                    circleLayer.fillColor = UIColor.red.cgColor
                    overlayLayer.addSublayer(circleLayer)
                }
                
                if showLabels {
                    let textLayer = CATextLayer()
                    textLayer.string = "\(bodyPartName(for: key))"
                    textLayer.fontSize = 12
                    textLayer.foregroundColor = UIColor.white.cgColor
                    textLayer.backgroundColor = UIColor.black.cgColor
                    textLayer.frame = CGRect(x: screenPoint.x + 10, y: screenPoint.y - 10, width: 100, height: 20)
                    overlayLayer.addSublayer(textLayer)
                }
            }
        }
        
        if showLines {
            let connections: [(VNHumanBodyPoseObservation.JointName, VNHumanBodyPoseObservation.JointName)] = [
                (.leftShoulder, .leftElbow),
                (.leftElbow, .leftWrist),
                (.rightShoulder, .rightElbow),
                (.rightElbow, .rightWrist),
                (.leftShoulder, .rightShoulder),
                (.leftHip, .leftKnee),
                (.leftKnee, .leftAnkle),
                (.rightHip, .rightKnee),
                (.rightKnee, .rightAnkle),
                (.leftShoulder, .leftHip),
                (.rightShoulder, .rightHip),
                (.neck, .leftShoulder),
                (.neck, .rightShoulder),
                (.nose, .neck)
            ]
            
            for connection in connections {
                if let startPoint = jointPoints[connection.0], let endPoint = jointPoints[connection.1] {
                    let lineLayer = CAShapeLayer()
                    let linePath = UIBezierPath()
                    linePath.move(to: startPoint)
                    linePath.addLine(to: endPoint)
                    lineLayer.path = linePath.cgPath
                    lineLayer.strokeColor = UIColor.green.cgColor
                    lineLayer.lineWidth = 2
                    overlayLayer.addSublayer(lineLayer)
                }
            }
        }
    }

    
    private func bodyPartName(for jointName: VNHumanBodyPoseObservation.JointName) -> String {
        switch jointName {
        case .nose:
            return "Nose"
        case .leftEye:
            return "Left Eye"
        case .rightEye:
            return "Right Eye"
        case .leftEar:
            return "Left Ear"
        case .rightEar:
            return "Right Ear"
        case .leftShoulder:
            return "Left Shoulder"
        case .rightShoulder:
            return "Right Shoulder"
        case .leftElbow:
            return "Left Elbow"
        case .rightElbow:
            return "Right Elbow"
        case .leftWrist:
            return "Left Wrist"
        case .rightWrist:
            return "Right Wrist"
        case .leftHip:
            return "Left Hip"
        case .rightHip:
            return "Right Hip"
        case .leftKnee:
            return "Left Knee"
        case .rightKnee:
            return "Right Knee"
        case .leftAnkle:
            return "Left Ankle"
        case .rightAnkle:
            return "Right Ankle"
        case .neck:
            return "Neck"
        case .root:
            return "Root"
        default:
            return "Unknown"
        }
    }
}
