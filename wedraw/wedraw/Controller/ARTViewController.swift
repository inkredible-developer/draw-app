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

    var router: MainFlowRouter?
    private var anchorImage: UIImage?
    private var tracingImage: UIImage
    
    var referenceImagePhysicalWidth: CGFloat = 0.1
    private let tracingPlaneWidth: CGFloat = 0.20
    private var originalPlaneSize: CGSize?
    
    private var referenceImage: ARReferenceImage?
    private var hasRelocatedToWorld = false

    private var tracingNode: SCNNode?
    private var imageAnchorNode: SCNNode?
    private var worldAnchorNode: SCNNode?

    private var relativeTransform: SCNMatrix4?

    private var isAnchorVisible = false
    private var lastKnownImageAnchorTransform: simd_float4x4?
    private var hasPlacedInitialTracingNode = false
    
    private let updateQueue = DispatchQueue(label: "com.example.artracing.serialSceneKitQueue")
    private var isRestartAvailable = true
    
    // Anchor popup view
    private var anchorPopupView: AnchorPopupView?
    
    init(anchorImage: UIImage?, tracingImage: UIImage) {
        self.anchorImage = anchorImage
        self.tracingImage = tracingImage
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        setupARView()
        setupAnchorPopupView()
        setupGestures()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        router?.navigationController?.setNavigationBarHidden(true, animated: animated)
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
    
    private func setupAnchorPopupView() {
        let popup = AnchorPopupView(
            title: "Mencari Anchor",
            message: "Arahkan kamera ke anchor yang telah ditentukan",
            backgroundColor: UIColor(white: 0, alpha: 0.6)
        )
        
        view.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            popup.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            popup.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            popup.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8),
            popup.heightAnchor.constraint(lessThanOrEqualToConstant: 120)
        ])
        
        popup.isHidden = true // Initially hidden
        anchorPopupView = popup
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
        // Show the popup when starting tracking
        anchorPopupView?.isHidden = false
        
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
        guard let cgImage = anchorImage?.cgImage else { return nil }
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
        let image = tracingImage
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
        guard let anchorImage = anchorImage else {
            print("Error: Missing anchor image")
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
        
        // Show popup when anchor is lost
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
        }
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
        
        // Hide popup when anchor is found
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = true
        }
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
            // Hide popup when anchor is detected
            self.anchorPopupView?.isHidden = true
            self.hasPlacedInitialTracingNode = true
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
                
                // Hide popup when anchor becomes visible
                DispatchQueue.main.async {
                    self.anchorPopupView?.isHidden = true
                }

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
            
            // Show popup when anchor becomes invisible
            DispatchQueue.main.async {
                self.anchorPopupView?.isHidden = false
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
            
            // Show popup when anchor is removed
            DispatchQueue.main.async {
                self.anchorPopupView?.isHidden = false
                self.moveTracingNodeToWorldSpace()
            }
        }
    }

    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        // Just update the tracking state without showing any messages
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
        
        // Show popup when using last known transform
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
        }
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        // Show popup for AR session failures
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
            
            if self.tracingNode == nil && !self.hasPlacedInitialTracingNode {
                self.placeTracingNodeInWorldSpace()
            }
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        // Show popup when session is interrupted
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
        }
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Keep popup visible if anchor is not visible
        if !isAnchorVisible {
            DispatchQueue.main.async {
                self.anchorPopupView?.isHidden = false
            }
            
            if !hasPlacedInitialTracingNode && tracingNode == nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
                    guard let self = self,
                          !self.hasPlacedInitialTracingNode,
                          self.tracingNode == nil else { return }

                    self.placeTracingNodeInWorldSpace()
                }
            }
        } else {
            // Hide popup if anchor is visible
            DispatchQueue.main.async {
                self.anchorPopupView?.isHidden = true
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
