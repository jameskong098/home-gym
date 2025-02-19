import SwiftUI
import Vision
import AVFoundation

class CameraViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    private let exerciseName: String
    private var cameraSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var overlayLayer: CALayer!
    @AppStorage("enableTutorials") private var enableTutorials = true
    @AppStorage("enableVoice") private var enableVoice: Bool = true
    @AppStorage("useWideAngleCamera") private var useWideAngleCamera = true
    @AppStorage("showBodyTrackingPoints") private var showBodyTrackingPoints = true
    @AppStorage("showBodyTrackingLabels") private var showBodyTrackingLabels = false
    @AppStorage("showBodyTrackingLines") private var showBodyTrackingLines = true
    var repCounter: Int = 0 {
        didSet {
            repCountBinding?.wrappedValue = repCounter
        }
    }
    var repCountBinding: Binding<Int>?
    var showTutorialBinding: Binding<Bool>?
    var showCountdown: Binding<Bool>?
    var showExerciseSummary: Binding<Bool>?
    var isPaused: Binding<Bool>?
    private var lastPose: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
    private var isGoingDown: Bool = false
    private var leftFootTouchedButt = false
    private var rightFootTouchedButt = false
    private var isBusy = false
    private var lastRequestTime = Date()

    init(exerciseName: String) {
        self.exerciseName = exerciseName
        super.init(nibName: nil, bundle: nil)
        configureAudioSession()
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
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(alongsideTransition: { _ in
            self.previewLayer.frame = self.view.bounds
            
            if let connection = self.previewLayer.connection,
               connection.isVideoOrientationSupported {
                connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation)
            }
        })
    }
    
    private func configureAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set audio session category: \(error)")
        }
    }
    
    static func deviceSupportsUltraWide() -> Bool {
        return AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front) != nil
    }
    
    private func setupCamera() {
        let captureSession = AVCaptureSession()
       
        let videoDevice: AVCaptureDevice? = {
                if useWideAngleCamera && Self.deviceSupportsUltraWide() {
                    return AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .front)
                }
                return AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }()
        
        guard let videoDevice = videoDevice else {
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
            
            // Set the initial video orientation
            if let connection = previewLayer.connection,
               connection.isVideoOrientationSupported {
                connection.videoOrientation = AVCaptureVideoOrientation(deviceOrientation: UIDevice.current.orientation)
            }
            
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
        
        var currentOrientation: UIDeviceOrientation = .portrait
        
        DispatchQueue.main.sync {
            currentOrientation = UIDevice.current.orientation
        }
        
        let cgOrientation = CGImagePropertyOrientation(deviceOrientation: currentOrientation)
        
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
                    
                    // Unwrap self before dispatching (had to add this due to Swift Playgrounds concurrency check, weirdly this only happens in playgrounds and not on Xcode playgrounds)
                    guard let self = self else {
                        print("Self is nil, cannot process pose data")
                        return
                    }

                    DispatchQueue.main.async {
                        self.processPoseData(safePoints)
                    }
                    } catch {
                        print("Error extracting points: \(error)")
                    }
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: CIImage(cvPixelBuffer: pixelBuffer), orientation: cgOrientation, options: [:])
        do {
            try handler.perform([request])
        } catch {
            print("Vision request failed: \(error.localizedDescription)")
        }
    }
    
    @MainActor
    private func processPoseData(_ points: [VNHumanBodyPoseObservation.JointName: (location: CGPoint, confidence: VNConfidence)]) {
        // Hide the overlay if the tutorial is showing
        guard showTutorialBinding?.wrappedValue == false || !enableTutorials else { return }
        // Hide the overlay if the countdown is showing
        guard showCountdown?.wrappedValue == false else { return }
        // Hide the overlay if the exercise summary is showing or the session is paused
        if showExerciseSummary?.wrappedValue == true || isPaused?.wrappedValue == true {
            overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
            return
        }
        
        overlayLayer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        var jointPoints: [VNHumanBodyPoseObservation.JointName: CGPoint] = [:]
        
        for (key, point) in points {
            if point.confidence > 0 {
                var normalizedPoint = CGPoint(x: point.location.x, y: 1 - point.location.y)
                
                if UIDevice.current.orientation == .landscapeLeft {
                    normalizedPoint = CGPoint(x: 1 - point.location.x, y: point.location.y)
                }
                
                let screenPoint = previewLayer.layerPointConverted(fromCaptureDevicePoint: normalizedPoint)
                jointPoints[key] = screenPoint
                
                if showBodyTrackingPoints {
                    let circleLayer = CAShapeLayer()
                    let circlePath = UIBezierPath(arcCenter: screenPoint, radius: 5, startAngle: 0, endAngle: CGFloat.pi * 2, clockwise: true)
                    circleLayer.path = circlePath.cgPath
                    circleLayer.fillColor = UIColor.white.cgColor 
                    overlayLayer.addSublayer(circleLayer)
                }
                
                if showBodyTrackingLabels {
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
        
        if showBodyTrackingLines {
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
                    lineLayer.strokeColor = UIColor.blue.cgColor
                    lineLayer.lineWidth = 2
                    overlayLayer.addSublayer(lineLayer)
                }
            }
        }
        
        countReps(jointPoints)
    }
    
    private func countReps(_ jointPoints: [VNHumanBodyPoseObservation.JointName: CGPoint]) {
        guard showCountdown?.wrappedValue == false, showExerciseSummary?.wrappedValue == false else { return }

        switch exerciseName {
        case "Basic Squats":
            if let leftHip = jointPoints[.leftHip],
               let rightHip = jointPoints[.rightHip],
               let leftKnee = jointPoints[.leftKnee],
               let rightKnee = jointPoints[.rightKnee],
               let leftAnkle = jointPoints[.leftAnkle],
               let rightAnkle = jointPoints[.rightAnkle] {

                let leftKneeAngle = angleBetweenPoints(leftHip, leftKnee, leftAnkle)
                let rightKneeAngle = angleBetweenPoints(rightHip, rightKnee, rightAnkle)

                if leftKneeAngle <= 90 && rightKneeAngle <= 90 {
                    isGoingDown = true
                } else if isGoingDown && leftKneeAngle > 160 && rightKneeAngle > 160 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Wall Squats":
            if let leftHip = jointPoints[.leftHip],
               let rightHip = jointPoints[.rightHip],
               let leftKnee = jointPoints[.leftKnee],
               let rightKnee = jointPoints[.rightKnee],
               let leftAnkle = jointPoints[.leftAnkle],
               let rightAnkle = jointPoints[.rightAnkle] {

                let leftKneeAngle = angleBetweenPoints(leftHip, leftKnee, leftAnkle)
                let rightKneeAngle = angleBetweenPoints(rightHip, rightKnee, rightAnkle)

                if leftKneeAngle < 90 && rightKneeAngle < 90 {
                    isGoingDown = true
                } else if isGoingDown && leftKneeAngle > 160 && rightKneeAngle > 160 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "High Knees":
            if let leftKnee = jointPoints[.leftKnee],
               let rightKnee = jointPoints[.rightKnee],
               let leftHip = jointPoints[.leftHip],
               let rightHip = jointPoints[.rightHip] {
                
                let leftKneeHigherThanHip = leftKnee.y < leftHip.y
                let rightKneeHigherThanHip = rightKnee.y < rightHip.y
                
                if !isGoingDown && (leftKneeHigherThanHip || rightKneeHigherThanHip) {
                    isGoingDown = true
                } else if isGoingDown && !leftKneeHigherThanHip && !rightKneeHigherThanHip {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Push-Ups":
            if let leftElbow = jointPoints[.leftElbow], let rightElbow = jointPoints[.rightElbow], let leftShoulder = jointPoints[.leftShoulder], let rightShoulder = jointPoints[.rightShoulder], let leftWrist = jointPoints[.leftWrist], let rightWrist = jointPoints[.rightWrist] {
                let leftElbowAngle = angleBetweenPoints(leftShoulder, leftElbow, leftWrist)
                let rightElbowAngle = angleBetweenPoints(rightShoulder, rightElbow, rightWrist)
                
                if leftElbowAngle < 120 && rightElbowAngle < 120 {
                    isGoingDown = true
                } else if isGoingDown && leftElbowAngle > 160 && rightElbowAngle > 160 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Lateral Raises":
            if let leftElbow = jointPoints[.leftElbow], 
            let rightElbow = jointPoints[.rightElbow], 
            let leftShoulder = jointPoints[.leftShoulder], 
            let rightShoulder = jointPoints[.rightShoulder], 
            let leftHip = jointPoints[.leftHip], 
            let rightHip = jointPoints[.rightHip] {

                let leftArmAngle = angleBetweenPoints(leftElbow, leftShoulder, leftHip)
                let rightArmAngle = angleBetweenPoints(rightElbow, rightShoulder, rightHip)

                if leftArmAngle > 70 && rightArmAngle > 70 {
                    isGoingDown = true
                } else if isGoingDown && leftArmAngle < 30 && rightArmAngle < 30 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Front Raises":
            if let leftElbow = jointPoints[.leftElbow],
            let rightElbow = jointPoints[.rightElbow],
            let leftShoulder = jointPoints[.leftShoulder],
            let rightShoulder = jointPoints[.rightShoulder],
            let leftHip = jointPoints[.leftHip],
            let rightHip = jointPoints[.rightHip] {

                let leftArmAngle = angleBetweenPoints(leftElbow, leftShoulder, leftHip)
                let rightArmAngle = angleBetweenPoints(rightElbow, rightShoulder, rightHip)

                if leftArmAngle > 70 && rightArmAngle > 70 {
                    isGoingDown = true
                } else if isGoingDown && leftArmAngle < 30 && rightArmAngle < 30 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Pilates Sit-Ups Hybrid":
            if let leftElbow = jointPoints[.leftElbow],
               let rightElbow = jointPoints[.rightElbow],
               let leftKnee = jointPoints[.leftKnee],
               let rightKnee = jointPoints[.rightKnee],
               let leftHip = jointPoints[.leftHip],
               let rightHip = jointPoints[.rightHip],
               let leftShoulder = jointPoints[.leftShoulder],
               let rightShoulder = jointPoints[.rightShoulder] {

                let kneesHigherThanHips = leftKnee.y < leftHip.y && rightKnee.y < rightHip.y
                let shouldersBelowKnees = leftShoulder.y > leftKnee.y && rightShoulder.y > rightKnee.y

                if kneesHigherThanHips {
                    let leftElbowToKnee = distanceBetweenPoints(leftElbow, leftKnee)
                    let rightElbowToKnee = distanceBetweenPoints(rightElbow, rightKnee)
                    let elbowsCloseToKnees = leftElbowToKnee < 50 || rightElbowToKnee < 50

                    if leftShoulder.y <= leftKnee.y && rightShoulder.y <= rightKnee.y && elbowsCloseToKnees {
                        isGoingDown = true
                    }
                    else if isGoingDown && shouldersBelowKnees {
                        repCounter += 1
                        isGoingDown = false
                        if enableVoice {
                            Speech.speak("\(repCounter)")
                        }
                    }
                }
            }
        case "Lunges":
            if let leftHip = jointPoints[.leftHip],
               let rightHip = jointPoints[.rightHip],
               let leftKnee = jointPoints[.leftKnee],
               let rightKnee = jointPoints[.rightKnee],
               let leftAnkle = jointPoints[.leftAnkle],
               let rightAnkle = jointPoints[.rightAnkle] {

                let leftKneeAngle = angleBetweenPoints(leftHip, leftKnee, leftAnkle)
                let rightKneeAngle = angleBetweenPoints(rightHip, rightKnee, rightAnkle)

                if leftKneeAngle <= 90 && rightKneeAngle <= 90 {
                    isGoingDown = true
                } else if isGoingDown && leftKneeAngle > 160 && rightKneeAngle > 160 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Bicep Curls - Simultaneous":
            if let leftElbow = jointPoints[.leftElbow],
               let leftShoulder = jointPoints[.leftShoulder],
               let leftWrist = jointPoints[.leftWrist],
               let rightElbow = jointPoints[.rightElbow],
               let rightShoulder = jointPoints[.rightShoulder],
               let rightWrist = jointPoints[.rightWrist] {

                let leftElbowAngle = angleBetweenPoints(leftShoulder, leftElbow, leftWrist)
                let rightElbowAngle = angleBetweenPoints(rightShoulder, rightElbow, rightWrist)

                if leftElbowAngle < 60 && rightElbowAngle < 60 {
                    isGoingDown = true
                } else if isGoingDown && leftElbowAngle > 160 && rightElbowAngle > 160 {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Jumping Jacks":
            if let leftWrist = jointPoints[.leftWrist],
               let rightWrist = jointPoints[.rightWrist],
               let leftShoulder = jointPoints[.leftShoulder],
               let rightShoulder = jointPoints[.rightShoulder],
               let leftAnkle = jointPoints[.leftAnkle],
               let rightAnkle = jointPoints[.rightAnkle],
               let leftHip = jointPoints[.leftHip],
               let rightHip = jointPoints[.rightHip] {

                let leftArmUp = leftWrist.y < leftShoulder.y
                let rightArmUp = rightWrist.y < rightShoulder.y
                let armsUp = leftArmUp && rightArmUp

                let hipWidth = hypot(leftHip.x - rightHip.x, leftHip.y - rightHip.y)
                let ankleSpread = hypot(leftAnkle.x - rightAnkle.x, leftAnkle.y - rightAnkle.y)
                let legsOpen = ankleSpread > hipWidth * 1.3

                if armsUp && legsOpen {
                    isGoingDown = true
                } else if isGoingDown && !armsUp && !legsOpen {
                    repCounter += 1
                    isGoingDown = false
                    if enableVoice {
                        Speech.speak("\(repCounter)")
                    }
                }
            }
        case "Planks":
            if let leftShoulder = jointPoints[.leftShoulder],
            let rightShoulder = jointPoints[.rightShoulder],
            let leftHip = jointPoints[.leftHip],
            let rightHip = jointPoints[.rightHip] {
                
                let shoulderY = (leftShoulder.y + rightShoulder.y) / 2
                let hipY = (leftHip.y + rightHip.y) / 2
                
                let hipDrop = hipY - shoulderY
                
                let warningThreshold: CGFloat = 30  
                let failureThreshold: CGFloat = 50  
                
                if hipDrop > warningThreshold && hipDrop <= failureThreshold {
                    if !isGoingDown {
                        isGoingDown = true
                        if enableVoice {
                            Speech.speak("Keep your hips up")
                        }
                    }
                } else if hipDrop > failureThreshold {
                    showExerciseSummary?.wrappedValue = true
                    if enableVoice {
                        Speech.speak("Exercise ended. Your form dropped too low")
                    }
                } else {
                    isGoingDown = false
                }
            }
        default:
            break
        }
        
        lastPose = jointPoints
    }
    
    private func distanceBetweenPoints(_ p1: CGPoint, _ p2: CGPoint) -> CGFloat {
        return sqrt(pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2))
    }
    
    private func angleBetweenPoints(_ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGFloat {
        let a = pow(p2.x - p1.x, 2) + pow(p2.y - p1.y, 2)
        let b = pow(p2.x - p3.x, 2) + pow(p2.y - p3.y, 2)
        let c = pow(p3.x - p1.x, 2) + pow(p3.y - p1.y, 2)
        return acos((a + b - c) / sqrt(4 * a * b)) * 180 / .pi
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

extension AVCaptureVideoOrientation {
    init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .landscapeLeft:
            self = .landscapeRight
        case .landscapeRight:
            self = .landscapeLeft
        case .portraitUpsideDown:
            self = .portraitUpsideDown
        default:
            self = .portrait
        }
    }
}

extension CGImagePropertyOrientation {
    init(deviceOrientation: UIDeviceOrientation) {
        switch deviceOrientation {
        case .portrait:
            self = .up
        case .portraitUpsideDown:
            self = .up
        case .landscapeLeft:
            self = .down
        case .landscapeRight:
            self = .up
        default:
            self = .up
        }
    }
}
