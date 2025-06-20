//
//  ARTViewController.swift
//  wedraw
//
//  Created by Ali An Nuur on 10/06/25.
//

import UIKit
import ARKit
import SceneKit

class ARTracingViewController: UIViewController {

    var arView: ARSCNView!

    var tracingImage: UIImage!

    var referenceImagePhysicalWidth: CGFloat = 0.1

    private let tracingPlaneWidth: CGFloat = 0.20
    
    private var originalPlaneSize: CGSize?

    private var statusViewController: StatusViewController!
    private var blurView: UIVisualEffectView!

    var anchorImage: UIImage!
    private var referenceImage: ARReferenceImage?
    
    private var hasRelocatedToWorld = false

    private var tracingNode: SCNNode?
    private var imageAnchorNode: SCNNode?
    private var worldAnchorNode: SCNNode?

    private var relativeTransform: SCNMatrix4?

    private var isAnchorVisible = false
    private var lastKnownImageAnchorTransform: simd_float4x4?
    private var hasPlacedInitialTracingNode = false
    private var anchorDetectionTimeout: Timer?

    private let updateQueue = DispatchQueue(label: "com.example.artracing.serialSceneKitQueue")
    private var isRestartAvailable = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupARView()
        setupStatusViewController()
        setupBlurView()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTracking()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
        UIApplication.shared.isIdleTimerDisabled = false
    }

    // MARK: - Setup
    private func setupARView() {
        arView = ARSCNView(frame: view.bounds)
        arView.delegate = self
        arView.session.delegate = self
        arView.autoenablesDefaultLighting = true
        arView.automaticallyUpdatesLighting = true
        arView.preferredFramesPerSecond = 60

        arView.antialiasingMode = .multisampling4X
        arView.contentScaleFactor = UIScreen.main.scale

        view.addSubview(arView)
        arView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            arView.topAnchor.constraint(equalTo: view.topAnchor),
            arView.leftAnchor.constraint(equalTo: view.leftAnchor),
            arView.rightAnchor.constraint(equalTo: view.rightAnchor),
            arView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupStatusViewController() {
        statusViewController = StatusViewController(nibName: nil, bundle: nil)

        addChild(statusViewController)
        view.addSubview(statusViewController.view)
        statusViewController.didMove(toParent: self)

        statusViewController.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            statusViewController.view.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            statusViewController.view.leftAnchor.constraint(equalTo: view.leftAnchor),
            statusViewController.view.rightAnchor.constraint(equalTo: view.rightAnchor),
        ])

        statusViewController.restartExperienceHandler = { [unowned self] in
            self.restartExperience()
        }
    }

    private func setupBlurView() {
        blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        blurView.isHidden = true
        blurView.alpha = 0
        view.addSubview(blurView)

        blurView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurView.topAnchor.constraint(equalTo: view.topAnchor),
            blurView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupGestures() {
        let panGesture = ThresholdPanGesture(target: self, action: #selector(didPan(_:)))
        panGesture.delegate = self
        arView.addGestureRecognizer(panGesture)

        let pinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(didPinch(_:)))
        arView.addGestureRecognizer(pinchGesture)

       
        let rotationGesture = UIRotationGestureRecognizer(target: self, action: #selector(didRotate(_:)))
        arView.addGestureRecognizer(rotationGesture)
    }


    private func resetTracking() {
        statusViewController.showMessage("Mencari anchor image...")

     
        anchorDetectionTimeout?.invalidate()

        isAnchorVisible = false
        lastKnownImageAnchorTransform = nil
        relativeTransform = nil
        hasPlacedInitialTracingNode = false

        tracingNode?.removeFromParentNode()
        worldAnchorNode?.removeFromParentNode()
        tracingNode = nil
        worldAnchorNode = nil
        imageAnchorNode = nil

        guard let referenceImage = createReferenceImage() else {
            statusViewController.showMessage("Error: Tidak dapat membuat reference image")
            return
        }

        self.referenceImage = referenceImage

        let configuration = ARWorldTrackingConfiguration()
        configuration.detectionImages = [referenceImage]
        configuration.maximumNumberOfTrackedImages = 1
        configuration.planeDetection = [.horizontal, .vertical]

        if #available(iOS 13.0, *) {
            configuration.isAutoFocusEnabled = true
            configuration.environmentTexturing = .automatic
        }

        arView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])

    }

    
    private func createReferenceImage() -> ARReferenceImage? {
        guard let cgImage = anchorImage.cgImage else { return nil }
        let referenceImage = ARReferenceImage(
            cgImage,
            orientation: .up,
            physicalWidth: referenceImagePhysicalWidth
        )
        referenceImage.name = "AnchorImage"
        return referenceImage
    }

    // MARK: - Tracing Node Management

    private func createTracingNode() -> SCNNode {
        let image = tracingImage!
        let width: CGFloat = 0.25
        let aspectRatio = image.size.height / image.size.width
        let height = width * aspectRatio

        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = image
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.lightingModel = .constant

        let node = SCNNode(geometry: plane)
        node.eulerAngles.x = -.pi / 2
        node.position = SCNVector3(0, 0, 0)
        node.opacity = 0.8
        return node
    }




    private func createTracingNode(for imageAnchor: ARImageAnchor? = nil) -> SCNNode {
        let imageSize = tracingImage.size

        let physicalWidth: CGFloat = 0.2
        let aspectRatio = imageSize.height / imageSize.width
        let physicalHeight = physicalWidth * aspectRatio

        let plane = SCNPlane(width: physicalWidth, height: physicalHeight)
        plane.firstMaterial?.diffuse.contents = tracingImage
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.lightingModel = .constant

        let node = SCNNode(geometry: plane)
        node.opacity = 0.8

        if let imageAnchor = imageAnchor {
            let anchorWidth = imageAnchor.referenceImage.physicalSize.width
            let anchorHeight = imageAnchor.referenceImage.physicalSize.height

            let posX = (anchorWidth / 2) + (Double(physicalWidth) / 2)
            let posZ = (anchorHeight / 2) + (Double(physicalHeight) / 2)

            node.position = SCNVector3(x: Float(posX), y: 0.001, z: Float(posZ))

            node.eulerAngles.x = -.pi / 2
        } else {
            node.eulerAngles = SCNVector3Zero
        }

        return node
    }


    private func prepareImages() {

        guard let anchorImage = anchorImage, let tracingImage = tracingImage else {
            print("Error: Missing images")
            return
        }

        let anchorAspect = anchorImage.size.width / anchorImage.size.height
        let tracingAspect = tracingImage.size.width / tracingImage.size.height

        if abs(anchorAspect - tracingAspect) > 0.05 {
            let size = CGSize(
                width: tracingImage.size.height * anchorAspect,
                height: tracingImage.size.height
            )

            UIGraphicsBeginImageContextWithOptions(size, false, tracingImage.scale)
            tracingImage.draw(in: CGRect(origin: .zero, size: size))
            if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
                self.tracingImage = resizedImage
            }
            UIGraphicsEndImageContext()

            print("Images normalized: Anchor aspect \(anchorAspect), Tracing aspect now \(anchorAspect)")
        }
    }

    private func placeTracingNodeInWorldSpace() {
        guard tracingNode == nil, worldAnchorNode == nil else { return }

        statusViewController.showMessage("Menggunakan gambar tanpa anchor", autoHide: true)

        let newTracingNode = createTracingNode()
         
           if let plane = newTracingNode.geometry as? SCNPlane {
               originalPlaneSize = CGSize(width: plane.width, height: plane.height)
           }

           let worldNode = SCNNode()

        if let currentFrame = arView.session.currentFrame {
            let cameraTransform = currentFrame.camera.transform
            let cameraPosition = cameraTransform.translation

            var position = cameraPosition
            position.z -= 0.5
            position.y -= 0.2

            var hasPlacedOnPlane = false

            if #available(iOS 13.0, *) {
                let raycastQuery = ARRaycastQuery(
                    origin: cameraPosition,
                    direction: SIMD3<Float>(0, 0, -1),
                    allowing: .estimatedPlane,
                    alignment: .horizontal
                )
                let results = arView.session.raycast(raycastQuery)

                if let firstResult = results.first {
                    worldNode.simdTransform = firstResult.worldTransform
                    worldNode.eulerAngles.x = -Float.pi / 2
                    hasPlacedOnPlane = true
                }
            } else {
                let viewCenter = CGPoint(x: arView.bounds.midX, y: arView.bounds.midY)
                let results = arView.hitTest(viewCenter, types: .existingPlaneUsingExtent)

                if let firstResult = results.first {
                    worldNode.simdTransform = firstResult.worldTransform
                    worldNode.eulerAngles.x = -Float.pi / 2
                    hasPlacedOnPlane = true
                }
            }

            if !hasPlacedOnPlane {
                worldNode.simdPosition = position
                worldNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
            }

            arView.scene.rootNode.addChildNode(worldNode)
            worldNode.addChildNode(newTracingNode)

            tracingNode = newTracingNode
            worldAnchorNode = worldNode
            hasPlacedInitialTracingNode = true

            if hasPlacedOnPlane {
                statusViewController.showMessage("Gambar diletakkan pada permukaan", autoHide: true)
            }
        }
    }

    private func updateRelativeTransform() {
        guard let tracingNode = tracingNode, let imageAnchorNode = imageAnchorNode else { return }

        relativeTransform = imageAnchorNode.convertTransform(tracingNode.transform, from: tracingNode.parent)
    }

   
    private func moveTracingNodeToWorldSpace() {
    
        guard let tracingNode = tracingNode,
              worldAnchorNode == nil,
              !hasRelocatedToWorld else { return }

        let worldTransform = tracingNode.worldTransform

        let worldNode = SCNNode()
        worldNode.transform = worldTransform
        arView.scene.rootNode.addChildNode(worldNode)

        tracingNode.removeFromParentNode()
        worldNode.addChildNode(tracingNode)

        tracingNode.transform = SCNMatrix4Identity

        self.worldAnchorNode = worldNode
        self.hasRelocatedToWorld = true

        statusViewController.showMessage("Anchor hilang - gambar tetap stabil", autoHide: true)
    }

    private func moveTracingNodeToImageAnchor() {
        guard let tracingNode = tracingNode,
              let worldNode = worldAnchorNode,
              let imageAnchorNode = imageAnchorNode else { return }

        tracingNode.removeFromParentNode()
        imageAnchorNode.addChildNode(tracingNode)

        if let relativeTransform = self.relativeTransform {
            tracingNode.transform = relativeTransform
        } else {
            tracingNode.transform = SCNMatrix4Identity
            tracingNode.position.y = 0.001
        }

        if let plane = tracingNode.geometry as? SCNPlane,
              let original = originalPlaneSize {
               plane.width  = original.width
               plane.height = original.height
           }

           worldNode.removeFromParentNode()
           worldAnchorNode = nil
           hasRelocatedToWorld = false
           statusViewController.showMessage("Anchor terdeteksi kembali!", autoHide: true)
    }

    // MARK: - Gesture Actions

    @objc func didPan(_ gesture: ThresholdPanGesture) {
        guard let tracingNode = tracingNode,
              gesture.state == .changed,
              gesture.isThresholdExceeded else { return }

        let translation = gesture.translation(in: arView)
        gesture.setTranslation(.zero, in: arView)

        updateQueue.async {
            let speed: Float = 0.001

            let dx = Float(translation.x) * speed
            let dy = Float(translation.y) * speed

            if self.worldAnchorNode != nil {
                
                let currentPosition = tracingNode.worldPosition
                tracingNode.worldPosition = SCNVector3(
                    currentPosition.x + dx,
                    currentPosition.y,
                    currentPosition.z + dy
                )
            } else if self.imageAnchorNode != nil {

                tracingNode.position.x += dx
                tracingNode.position.z += dy
                self.updateRelativeTransform()
            }
        }
    }





    @objc func didPinch(_ gesture: UIPinchGestureRecognizer) {
        guard let tracingNode = tracingNode,
              let plane = tracingNode.geometry as? SCNPlane,
              gesture.state == .changed else { return }

        let scaleFactor = Float(gesture.scale)

        plane.width *= CGFloat(scaleFactor)
        plane.height *= CGFloat(scaleFactor)

        if imageAnchorNode != nil && worldAnchorNode == nil {
            updateRelativeTransform()
        }

        gesture.scale = 1.0
    }

    @objc func didRotate(_ gesture: UIRotationGestureRecognizer) {
        guard let tracingNode = tracingNode, gesture.state == .changed else { return }

        let rotation = Float(gesture.rotation)
        gesture.rotation = 0

        if worldAnchorNode != nil {
         
            tracingNode.eulerAngles.z -= rotation
        } else if imageAnchorNode != nil {
        
            tracingNode.eulerAngles.y -= rotation

            self.updateRelativeTransform()
        }
    }


    // MARK: - Experience Actions

    @IBAction func closeAR() {
        dismiss(animated: true)
    }

    func restartExperience() {
        guard isRestartAvailable else { return }
        isRestartAvailable = false

        statusViewController.cancelAllScheduledMessages()

        relativeTransform = nil
        tracingNode?.removeFromParentNode()
        worldAnchorNode?.removeFromParentNode()
        tracingNode = nil
        worldAnchorNode = nil
        imageAnchorNode = nil
        hasPlacedInitialTracingNode = false

        resetTracking()

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.isRestartAvailable = true
        }
    }
}

// MARK: - ARSCNViewDelegate & ARSessionDelegate

extension ARTracingViewController: ARSCNViewDelegate, ARSessionDelegate {

    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor,
              imageAnchor.referenceImage.name == "AnchorImage" else { return }

        DispatchQueue.main.async {
            self.statusViewController.showMessage("Anchor terdeteksi!")
            self.hasPlacedInitialTracingNode = true

            self.anchorDetectionTimeout?.invalidate()
        }

       
        imageAnchorNode = node

      
        isAnchorVisible = true
        lastKnownImageAnchorTransform = imageAnchor.transform

        if let _ = tracingNode, let _ = worldAnchorNode {
            DispatchQueue.main.async {
                self.moveTracingNodeToImageAnchor()
            }
        } else if tracingNode == nil {
          
            let newTracingNode = createTracingNode(for: imageAnchor)
            node.addChildNode(newTracingNode)
                tracingNode = newTracingNode

                if let plane = newTracingNode.geometry as? SCNPlane {
                    originalPlaneSize = CGSize(width: plane.width, height: plane.height)
                }

                updateRelativeTransform()
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor,
              imageAnchor.referenceImage.name == "AnchorImage" else { return }

        imageAnchorNode = node

        if imageAnchor.isTracked {
            if !isAnchorVisible {
                isAnchorVisible = true
                lastKnownImageAnchorTransform = imageAnchor.transform

                if let _ = worldAnchorNode {
                    DispatchQueue.main.async {
                        self.moveTracingNodeToImageAnchor()
                    }
                }
            } else {
                lastKnownImageAnchorTransform = imageAnchor.transform
            }
        } else if isAnchorVisible {
            isAnchorVisible = false
            DispatchQueue.main.async {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0
                self.moveTracingNodeToWorldSpace()
                SCNTransaction.commit()
            }
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {
       
        if let imageAnchor = anchor as? ARImageAnchor,
           imageAnchor.referenceImage.name == "AnchorImage",
           isAnchorVisible,
           node == imageAnchorNode {

            isAnchorVisible = false
            imageAnchorNode = nil

            DispatchQueue.main.async {
                self.moveTracingNodeToWorldSpace()
            }
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        statusViewController.showTrackingQualityInfo(for: camera.trackingState, autoHide: true)

        switch camera.trackingState {
        case .notAvailable, .limited:
            statusViewController.escalateFeedback(for: camera.trackingState, inSeconds: 3.0)
        case .normal:
            statusViewController.cancelScheduledMessage(for: .trackingStateEscalation)
        }
    }
    
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        if !isAnchorVisible && !hasRelocatedToWorld {
            guard worldAnchorNode == nil,
                  frame.worldMappingStatus == .mapped || frame.worldMappingStatus == .extending else { return }

            DispatchQueue.main.async {
                SCNTransaction.begin()
                SCNTransaction.animationDuration = 0
                self.placeTracingNodeAtLastKnownTransform()
                SCNTransaction.commit()
            }
        }
    }

    
    private func placeTracingNodeAtLastKnownTransform() {
        guard let last = lastKnownImageAnchorTransform,
              worldAnchorNode == nil,
              !hasRelocatedToWorld else { return }

        let worldNode = SCNNode()
        worldNode.simdTransform = last
        arView.scene.rootNode.addChildNode(worldNode)

        if let tracing = tracingNode {
            tracing.removeFromParentNode()
            worldNode.addChildNode(tracing)
        }

        self.worldAnchorNode = worldNode
        self.hasRelocatedToWorld = true
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]

        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")

        DispatchQueue.main.async {
            self.statusViewController.showMessage("AR Session Failed: \(errorMessage)", autoHide: false)

            if self.tracingNode == nil && !self.hasPlacedInitialTracingNode {
                self.placeTracingNodeInWorldSpace()
            }
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        blurView.isHidden = false
        statusViewController.showMessage("Session Interrupted", autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        blurView.isHidden = true
        statusViewController.showMessage("Session Resumed", autoHide: true)

        if !isAnchorVisible && tracingNode == nil && !hasPlacedInitialTracingNode {
           
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                guard let self = self,
                      !self.hasPlacedInitialTracingNode,
                      self.tracingNode == nil else { return }

                self.placeTracingNodeInWorldSpace()
            }
        }
    }

    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
        return true
    }
}

// MARK: - UIGestureRecognizerDelegate

extension ARTracingViewController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        return true
    }
}

class StatusViewController: UIViewController {

    // MARK: - Properties

    var restartExperienceHandler: () -> Void = {}

    private let messagePanel = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private let messageLabel = UILabel()
    private let restartButton = UIButton(type: .system)

  
    private var messageHideTimer: Timer?

    // MARK: - Message Types

    enum MessageType {
        case trackingStateEscalation
        case contentPlacement

        static let all: [MessageType] = [.trackingStateEscalation, .contentPlacement]
    }

    private var timers: [MessageType: Timer] = [:]

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupMessagePanel()
    }

    // MARK: - Setup

    private func setupMessagePanel() {
      
        messagePanel.layer.cornerRadius = 8
        messagePanel.clipsToBounds = true
        messagePanel.isHidden = true
        view.addSubview(messagePanel)

        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)

        let stackView = UIStackView(arrangedSubviews: [messageLabel, restartButton])
        stackView.axis = .vertical
        stackView.spacing = 8
        stackView.alignment = .center
        stackView.layoutMargins = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        stackView.isLayoutMarginsRelativeArrangement = true

        restartButton.setTitle("Reset", for: .normal)
        restartButton.addTarget(self, action: #selector(restartExperience), for: .touchUpInside)
        restartButton.isHidden = true

        messagePanel.contentView.addSubview(stackView)

        messagePanel.translatesAutoresizingMaskIntoConstraints = false
        stackView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            messagePanel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            messagePanel.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            messagePanel.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.9),

            stackView.leadingAnchor.constraint(equalTo: messagePanel.contentView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: messagePanel.contentView.trailingAnchor),
            stackView.topAnchor.constraint(equalTo: messagePanel.contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: messagePanel.contentView.bottomAnchor)
        ])
    }

    // MARK: - Messages

    func showMessage(_ text: String, autoHide: Bool = true) {
        messageHideTimer?.invalidate()

        messageLabel.text = text

        let needsRestart = text.lowercased().contains("try resetting")
        restartButton.isHidden = !needsRestart

        messagePanel.isHidden = false
        messagePanel.alpha = 1

        if autoHide {
            let displayDuration: TimeInterval = needsRestart ? 10.0 : 4.0
            messageHideTimer = Timer.scheduledTimer(withTimeInterval: displayDuration, repeats: false, block: { [weak self] _ in
                self?.setMessageHidden(true, animated: true)
            })
        }
    }

    func scheduleMessage(_ text: String, inSeconds seconds: TimeInterval, messageType: MessageType) {
        cancelScheduledMessage(for: messageType)

        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [weak self] timer in
            self?.showMessage(text)
            timer.invalidate()
        })

        timers[messageType] = timer
    }

    func cancelScheduledMessage(for messageType: MessageType) {
        timers[messageType]?.invalidate()
        timers[messageType] = nil
    }

    func cancelAllScheduledMessages() {
        for messageType in MessageType.all {
            cancelScheduledMessage(for: messageType)
        }
    }

    // MARK: - ARKit

    func showTrackingQualityInfo(for trackingState: ARCamera.TrackingState, autoHide: Bool) {
        showMessage(trackingState.presentationString, autoHide: autoHide)
    }

    func escalateFeedback(for trackingState: ARCamera.TrackingState, inSeconds seconds: TimeInterval) {
        cancelScheduledMessage(for: .trackingStateEscalation)

        let timer = Timer.scheduledTimer(withTimeInterval: seconds, repeats: false, block: { [unowned self] _ in
            self.cancelScheduledMessage(for: .trackingStateEscalation)

            var message = trackingState.presentationString
            if let recommendation = trackingState.recommendation {
                message.append(": \(recommendation)")
            }

            self.showMessage(message, autoHide: false)
        })

        timers[.trackingStateEscalation] = timer
    }

    // MARK: - IBActions

    @IBAction private func restartExperience(_ sender: UIButton) {
        restartExperienceHandler()
    }

    // MARK: - Panel Visibility

    private func setMessageHidden(_ hide: Bool, animated: Bool) {
        messagePanel.isHidden = false

        guard animated else {
            messagePanel.alpha = hide ? 0 : 1
            messagePanel.isHidden = hide
            return
        }

        UIView.animate(withDuration: 0.2, delay: 0, options: [.beginFromCurrentState], animations: {
            self.messagePanel.alpha = hide ? 0 : 1
        }, completion: { _ in
            self.messagePanel.isHidden = hide
        })
    }
}

// MARK: - ARCamera.TrackingState Extension

extension ARCamera.TrackingState {
    var presentationString: String {
        switch self {
        case .notAvailable:
            return "TRACKING UNAVAILABLE"
        case .normal:
            return "TRACKING NORMAL"
        case .limited(.excessiveMotion):
            return "TRACKING LIMITED\nTerlalu banyak gerakan"
        case .limited(.insufficientFeatures):
            return "TRACKING LIMITED\nPermukaan kurang detail"
        case .limited(.initializing):
            return "Initializing"
        case .limited(.relocalizing):
            return "Recovering from interruption"
        @unknown default:
            return "Unknown tracking state."
        }
    }

    var recommendation: String? {
        switch self {
        case .limited(.excessiveMotion):
            return "Cobalah perlambat gerakan, atau reset sesi."
        case .limited(.insufficientFeatures):
            return "Cobalah arahkan ke permukaan yang lebih detail, atau reset sesi."
        case .limited(.relocalizing):
            return "Kembali ke posisi sebelumnya atau coba reset sesi."
        default:
            return nil
        }
    }
}

// MARK: - ThresholdPanGesture

class ThresholdPanGesture: UIPanGestureRecognizer {

    private(set) var isThresholdExceeded = false

    private var threshold: CGFloat

    init(target: Any?, action: Selector?, threshold: CGFloat = 30) {
        self.threshold = threshold
        super.init(target: target, action: action)
    }

    override var state: UIGestureRecognizer.State {
        didSet {
            switch state {
            case .began, .changed:
                break

            default:
                isThresholdExceeded = false
            }
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesMoved(touches, with: event)

        guard !isThresholdExceeded else { return }

        let translationMagnitude = translation(in: view).length
        if translationMagnitude > threshold {
            isThresholdExceeded = true

            setTranslation(.zero, in: view)
        }
    }
}

func metersFromImageSize(_ image: UIImage, dpi: CGFloat = 300) -> CGSize {
    let inchPerMeter: CGFloat = 39.3701
    let widthInches = image.size.width / dpi
    let heightInches = image.size.height / dpi

    let widthMeters = widthInches / inchPerMeter
    let heightMeters = heightInches / inchPerMeter

    return CGSize(width: widthMeters, height: heightMeters)
}


// MARK: - CGPoint extension

extension CGPoint {
    var length: CGFloat {
        return sqrt(x * x + y * y)
    }
}

// MARK: - Float4x4 Extension for Matrix Transformations

extension simd_float4x4 {

    var translation: SIMD3<Float> {
        let translation = columns.3
        return SIMD3<Float>(translation.x, translation.y, translation.z)
    }
    
    static func makeTranslation(_ translation: SIMD3<Float>) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.3.x = translation.x
        matrix.columns.3.y = translation.y
        matrix.columns.3.z = translation.z
        return matrix
    }

    static func makeRotationY(_ angle: Float) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = cos(angle)
        matrix.columns.0.z = -sin(angle)
        matrix.columns.2.x = sin(angle)
        matrix.columns.2.z = cos(angle)
        return matrix
    }

    static func makeScale(_ scale: SIMD3<Float>) -> simd_float4x4 {
        var matrix = matrix_identity_float4x4
        matrix.columns.0.x = scale.x
        matrix.columns.1.y = scale.y
        matrix.columns.2.z = scale.z
        return matrix
    }
}

// MARK: - Additional Helper Extensions

extension SCNNode {
    func setPosition(_ position: SIMD3<Float>) {
        self.position = SCNVector3(position.x, position.y, position.z)
    }

    func getPosition() -> SIMD3<Float> {
        return SIMD3<Float>(position.x, position.y, position.z)
    }

    func setScale(_ scale: SIMD3<Float>) {
        self.scale = SCNVector3(scale.x, scale.y, scale.z)
    }
}
