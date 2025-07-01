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
    var drawId: UUID
    
    
    var drawService = DrawService()
    var stepService = StepService()
    
    var drawDetails : [Draw] = []
    var dataSteps : [Step] = []
    var steps: [DrawingStep] = []
    var currentImage : UIImage?
    
    var referenceImagePhysicalWidth: CGFloat = 0.1
    private let tracingPlaneWidth: CGFloat = 0.20
    private var originalPlaneSize: CGSize?
    
    private var referenceImage: ARReferenceImage?
    private var hasRelocatedToWorld = false
    
    private var tracingNode: SCNNode?
    private var imageAnchorNode: SCNNode?
    private var worldAnchorNode: SCNNode?
    
    private var tooltip: TooltipView?
    
    private var relativeTransform: SCNMatrix4?
    
    private var currentIndex = 0
    private let opacitySlider = OpacitySliderView()
    
    private var isAnchorVisible = false
    private var lastKnownImageAnchorTransform: simd_float4x4?
    private var hasPlacedInitialTracingNode = false
    
    private var lastScaleWhenAnchored: CGFloat = 1.0
    private var lastRelativePosition: SCNVector3?
    private var lastRelativeRotation: SCNVector3?
    
    private let updateQueue = DispatchQueue(label: "com.example.artracing.serialSceneKitQueue")
    private var isRestartAvailable = true
    
    // Anchor popup view
    private var anchorPopupView: AnchorPopupView?
    
    //    private var steps: [DrawingStep] = [
    //        DrawingStep(title: "Draw the Base Circle", description: "Start with a simple circle, this will be the skull base. Don't worry about perfection; just aim for a clean round shape", imageName: "step1"),
    //        DrawingStep(title: "Draw Guide for Side", description: "Draw vertical line for direction. Use center as anchor.", imageName: "step2"),
    //        DrawingStep(title: "Split Face Horizontally", description: "Add eye and nose level.", imageName: "step3"),
    //        DrawingStep(title: "Add Chin Box", description: "Sketch box to shape the chin.", imageName: "step4"),
    //        DrawingStep(title: "Draw Eye Line", description: "Mark horizontal eye level.", imageName: "step5"),
    //        DrawingStep(title: "Mark Nose Line", description: "Place nose at 1/3 down from eyes to chin.", imageName: "step6"),
    //        DrawingStep(title: "Define Jaw", description: "Sketch jaw shape to connect head and chin.", imageName: "step7"),
    //        DrawingStep(title: "Add Ear Level", description: "Align ear from eye to nose level.", imageName: "step8"),
    //        DrawingStep(title: "Draw Neck Guide", description: "Extend lines for neck from jaw.", imageName: "step9"),
    //        DrawingStep(title: "Draw A Line to Make A Nose", description: "Add guide lines for a nose\nTip: Nose (1/3 down from eye line to chin)", imageName: "step10")
    //    ]
    func loadDraw(){
        drawDetails = drawService.getDrawById(draw_id: drawId)
        //        print("drawDetails",drawDetails)
        currentIndex = Int(drawDetails[0].current_step - 1)
        print("currentIndex",currentIndex)
        
        dataSteps = stepService.getSteps(angle_id: drawDetails[0].angle_id)
        
        steps = [
            DrawingStep(
                title: "Draw the Base Circle",
                description: "Draw a circle as the base of the head.",
                imageName: dataSteps[0].image!
            ),
            DrawingStep(
                title: "Draw Guide for Side",
                description: "Add an oval next to the circle for the temple and ear area.",
                imageName: dataSteps[1].image!
            ),
            DrawingStep(
                title: "Split Face Horizontally",
                description: "Draw a horizontal line in the middle of the circle and oval for the position of the eyebrow and upper ear.",
                imageName: dataSteps[2].image!
            ),
            DrawingStep(
                title: "Add Chin Box",
                description: "Draw a vertical line in the circle to divide the face into left and right.",
                imageName: dataSteps[3].image!
            ),
            DrawingStep(
                title: "Draw Eye Line",
                description: "Split the side oval in half with the vertical line to help draw the ear.",
                imageName: dataSteps[4].image!
            ),
            DrawingStep(
                title: "Mark Nose Line",
                description: "Add a horizontal line below the circle to mark the position of the nose.",
                imageName: dataSteps[5].image!
            ),
            DrawingStep(
                title: "Define Jaw",
                description: "Draw the ear between the eyebrow line and the nose line, inside the side oval.",
                imageName: dataSteps[6].image!
            ),
            DrawingStep(
                title: "Add Ear Level",
                description: "Draw a line from under the oval towards the chin to form the jaw.",
                imageName: dataSteps[7].image!
            ),
            DrawingStep(
                title: "Draw Neck Guide",
                description: "Continue the jaw line from under the ear to the chin.",
                imageName: dataSteps[8].image!
            ),
            DrawingStep(
                title: "Draw A Line to Make A Nose",
                description: "draw the eyes, nose, and mouth in the appropriate places with the guide lines.",
                imageName: dataSteps[9].image!
            )
        ]
    }
    // UI Components
    private let infoButton = CustomIconButtonView(
        iconName: "info",
        iconColor: .white,
        backgroundColor: UIColor(named: "Inkredible-DarkPurple") ?? .systemYellow,
        iconScale: 0.5
    )
    
    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(UIColor(named: "Inkredible-Green"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(finishButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let stepTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let stepDescriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        //        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let bottomContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let sliderContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let buttonCardView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        view.layer.cornerRadius = 24
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let prevButton: UIButton = {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.left", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "Inkredible-DarkText")
        
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 55),
            button.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        
        let config = UIImage.SymbolConfiguration(pointSize: 16, weight: .medium)
        let image = UIImage(systemName: "chevron.right", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = UIColor(named: "Inkredible-DarkText")
        
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 24
        button.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            button.widthAnchor.constraint(equalToConstant: 55),
            button.heightAnchor.constraint(equalToConstant: 55)
        ])
        
        return button
    }()
    
    private let stepProgressLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .title3).pointSize, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    init(anchorImage: UIImage?, tracingImage: UIImage, drawId: UUID) {
        self.anchorImage = anchorImage
        self.tracingImage = tracingImage
        self.drawId = drawId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDraw()
        setupARView()
        setupAnchorPopupView()
        setupGestures()
        setupNavBarColor()
        configureNavigationBar()
        setupDrawingStepsUI()
        updateStep()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        resetTracking()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showTooltip(withText: self.steps[self.currentIndex].description)
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        arView.session.pause()
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    private func setupNavBarColor() {
        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .white
            appearance.titleTextAttributes = [.foregroundColor: UIColor(named: "Inkredible-DarkPurple") ?? .black]
            navigationController?.navigationBar.standardAppearance = appearance
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.tintColor = UIColor(named: "Inkredible-Green") ?? .green
        } else {
            navigationController?.navigationBar.barTintColor = .white
            navigationController?.navigationBar.tintColor = UIColor(named: "Inkredible-Green") ?? .green
            navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor(named: "Inkredible-DarkPurple") ?? .black]
        }
    }
    
    private func configureNavigationBar() {
        navigationItem.title = "Drawing With Reference"
        navigationItem.hidesBackButton = true
        
        finishButton.setTitle(currentIndex == steps.count - 1 ? "Finish" : "Save", for: .normal)
        
        let saveItem = UIBarButtonItem(
            customView: finishButton
        )
        
        lazy var infoItem = UIBarButtonItem(customView: infoButton)
        navigationItem.leftBarButtonItem = infoItem
        
        navigationItem.rightBarButtonItem = saveItem
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
            title: "Anchor not detected.",
            message: "Please ensure the camera is pointed at the anchor.",
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
        
        popup.isHidden = true
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
    
    //    private func createTracingNode() -> SCNNode {
    //        let image = tracingImage
    //        let width: CGFloat = 0.25
    //        let aspectRatio = image.size.height / image.size.width
    //        let height = width * aspectRatio
    //
    //        let plane = SCNPlane(width: width, height: height)
    //        plane.firstMaterial?.diffuse.contents = image
    //        plane.firstMaterial?.isDoubleSided = true
    //        plane.firstMaterial?.lightingModel = .constant
    //
    //        let node = SCNNode(geometry: plane)
    //        node.eulerAngles.x = -.pi / 2
    //        node.position = SCNVector3(0, 0, 0)
    //        node.opacity = 0.8
    //        return node
    //    }
    
    
//    swift
    private func createTracingNode() -> SCNNode {
        let step = steps[currentIndex]
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(step.imageName)
        var currentStepImage = tracingImage

        let width: CGFloat = 0.25
        let aspectRatio = currentStepImage.size.height / currentStepImage.size.width
        let height = width * aspectRatio

        let plane = SCNPlane(width: width, height: height)
        plane.firstMaterial?.diffuse.contents = currentStepImage
        plane.firstMaterial?.isDoubleSided = true
        plane.firstMaterial?.lightingModel = .constant

        let node = SCNNode(geometry: plane)
        node.eulerAngles.x = -.pi / 2
        node.position = SCNVector3(0, 0, 0)
        node.opacity = 0.8

        // Load image step di background, lalu update node di main thread
        DispatchQueue.global(qos: .userInitiated).async {
            if FileManager.default.fileExists(atPath: fileURL.path),
               let data = try? Data(contentsOf: fileURL),
               let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    plane.firstMaterial?.diffuse.contents = image
                }
            }
        }

        return node
    }
    
    //    private func createTracingNode(for imageAnchor: ARImageAnchor? = nil) -> SCNNode {
    //        let imageSize = tracingImage.size
    //
    //        let physicalWidth: CGFloat = 0.2
    //        let aspectRatio = imageSize.height / imageSize.width
    //        let physicalHeight = physicalWidth * aspectRatio
    //
    //        let plane = SCNPlane(width: physicalWidth, height: physicalHeight)
    //        plane.firstMaterial?.diffuse.contents = tracingImage
    //        plane.firstMaterial?.isDoubleSided = true
    //        plane.firstMaterial?.lightingModel = .constant
    //
    //        let node = SCNNode(geometry: plane)
    //        node.opacity = 0.8
    //
    //        if let imageAnchor = imageAnchor {
    //            let anchorWidth = imageAnchor.referenceImage.physicalSize.width
    //            let anchorHeight = imageAnchor.referenceImage.physicalSize.height
    //
    //            let posX = (anchorWidth / 2) + (Double(physicalWidth) / 2)
    //            let posZ = (anchorHeight / 2) + (Double(physicalHeight) / 2)
    //
    //            node.position = SCNVector3(x: Float(posX), y: 0.001, z: Float(posZ))
    //
    //            node.eulerAngles.x = -.pi / 2
    //        } else {
    //            node.eulerAngles = SCNVector3Zero
    //        }
    //
    //        return node
    //    }
    
    @objc private func finishButtonTapped() {
        print("self.steps[steps.count - 1].imageName",self.steps[steps.count - 1].imageName)
        if currentIndex == steps.count - 1 {
            router?.presentDirectly(
                .photoCaptureSheetViewController( currentImage!, self.drawId, true),
                animated: true
            )
            // This is the last step - go to CameraTesterViewController
            //            let nextVC = CameraTesterViewController()
            //            if let router = router {
            //                router.navigationController?.pushViewController(nextVC, animated: true)
            //            } else {
            //                navigationController?.pushViewController(nextVC, animated: true)
            //            }
        } else {
            router?.presentDirectly(
                .photoCaptureSheetViewController( self.tracingImage, self.drawId, false),
                animated: true
            )
            // Save functionality - shows photo capture sheet
            //            router?.presentDirectly(
            //                .photoCaptureSheetViewController( self.tracingImage),
            //                  animated: true
            //                )
            
        }
    }
    
    //    @objc private func finishButtonTapped() {
    //        // Close AR experience or save depending on current step
    //        if currentIndex == steps.count - 1 {
    //            // This is the last step - finish the experience
    //            dismiss(animated: true)
    //            router?.presentDirectly(.photoCaptureSheetViewController, animated: true)
    //        } else {
    //            // Save functionality
    //            // You can implement saving functionality here
    //            let alert = UIAlertController(title: "Save Drawing", message: "Your drawing progress has been saved.", preferredStyle: .alert)
    //            alert.addAction(UIAlertAction(title: "OK", style: <#UIAlertAction.Style#>, for: .default))
    //            present(alert, animated: true)
    //            router?.presentDirectly(
    //                .photoCaptureSheetViewController( self.tracingImage),
    //                  animated: true
    //                )
    //        }
    //    }
    
    //    private func prepareImages() {
    //        guard let anchorImage = anchorImage else {
    //            print("Error: Missing anchor image")
    //            return
    //        }
    //
    //        let anchorAspect = anchorImage.size.width / anchorImage.size.height
    //        let tracingAspect = tracingImage.size.width / tracingImage.size.height
    //
    //        if abs(anchorAspect - tracingAspect) > 0.05 {
    //            let size = CGSize(
    //                width: tracingImage.size.height * anchorAspect,
    //                height: tracingImage.size.height
    //            )
    //
    //            UIGraphicsBeginImageContextWithOptions(size, false, tracingImage.scale)
    //            tracingImage.draw(in: CGRect(origin: .zero, size: size))
    //            if let resizedImage = UIGraphicsGetImageFromCurrentImageContext() {
    //                self.tracingImage = resizedImage
    //            }
    //            UIGraphicsEndImageContext()
    //
    //            print("Images normalized: Anchor aspect \(anchorAspect), Tracing aspect now \(anchorAspect)")
    //        }
    //    }
    
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
        lastRelativePosition = tracingNode.position
        lastRelativeRotation = tracingNode.eulerAngles
        
        if let plane = tracingNode.geometry as? SCNPlane,
           let originalSize = originalPlaneSize {
            lastScaleWhenAnchored = plane.width / originalSize.width
        }
    }
    
    
    private func moveTracingNodeToWorldSpace() {
        guard let tracingNode = tracingNode,
              worldAnchorNode == nil,
              !hasRelocatedToWorld else { return }
        
        
        if let plane = tracingNode.geometry as? SCNPlane {
            if let originalSize = originalPlaneSize {
                lastScaleWhenAnchored = plane.width / originalSize.width
            }
        }
        
        if let imageAnchorNode = imageAnchorNode {
            lastRelativePosition = tracingNode.position
            lastRelativeRotation = tracingNode.eulerAngles
        }
        
        let worldTransform = tracingNode.worldTransform
        
        let worldNode = SCNNode()
        worldNode.transform = worldTransform
        arView.scene.rootNode.addChildNode(worldNode)
        
        tracingNode.removeFromParentNode()
        worldNode.addChildNode(tracingNode)
        
        tracingNode.transform = SCNMatrix4Identity
        
        self.worldAnchorNode = worldNode
        self.hasRelocatedToWorld = true
        
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
        
        if let lastPosition = lastRelativePosition {
            tracingNode.position = lastPosition
        } else if let relativeTransform = self.relativeTransform {
            tracingNode.transform = relativeTransform
        } else {
            tracingNode.transform = SCNMatrix4Identity
            tracingNode.position.y = 0.001
        }
        
        if let lastRotation = lastRelativeRotation {
            tracingNode.eulerAngles = lastRotation
        }
        
        if let plane = tracingNode.geometry as? SCNPlane,
           let original = originalPlaneSize {
            plane.width = original.width * lastScaleWhenAnchored
            plane.height = original.height * lastScaleWhenAnchored
        }
        
        worldNode.removeFromParentNode()
        worldAnchorNode = nil
        hasRelocatedToWorld = false
        
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
                self.lastRelativePosition = tracingNode.position
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
            if let originalSize = originalPlaneSize {
                lastScaleWhenAnchored = plane.width / originalSize.width
            }
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
            lastRelativeRotation = tracingNode.eulerAngles
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
    
    // MARK: - Drawing Steps UI Setup
    private func setupDrawingStepsUI() {
        
        infoButton.updateSize(width: 30)
        infoButton.delegate = self
        
        view.addSubview(infoButton)
        view.addSubview(sliderContainer)
        view.addSubview(bottomContainer)
        
        bottomContainer.addSubview(buttonCardView)
        buttonCardView.addSubview(prevButton)
        buttonCardView.addSubview(nextButton)
        buttonCardView.addSubview(stepProgressLabel)
        
        opacitySlider.translatesAutoresizingMaskIntoConstraints = false
        sliderContainer.addSubview(opacitySlider)
        sliderContainer.clipsToBounds = false
        
        prevButton.addTarget(self, action: #selector(prevTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextTapped), for: .touchUpInside)
        
        opacitySlider.onOpacityChanged = { [weak self] value in
            self?.tracingNode?.opacity = CGFloat(value)
        }
        
        NSLayoutConstraint.activate([
            infoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 16),
            infoButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            bottomContainer.heightAnchor.constraint(equalToConstant: 158),
            bottomContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            sliderContainer.heightAnchor.constraint(equalToConstant: 50),
            sliderContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            sliderContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            sliderContainer.bottomAnchor.constraint(equalTo: bottomContainer.topAnchor),
//            sliderContainer.topAnchor.constraint(equalTo: bottomContainer.topAnchor, constant: -50),

            buttonCardView.centerXAnchor.constraint(equalTo: bottomContainer.centerXAnchor),
            buttonCardView.centerYAnchor.constraint(equalTo: bottomContainer.centerYAnchor),
            buttonCardView.heightAnchor.constraint(equalToConstant: 55),
            buttonCardView.leadingAnchor.constraint(equalTo: bottomContainer.leadingAnchor, constant: 24),
            buttonCardView.trailingAnchor.constraint(equalTo: bottomContainer.trailingAnchor, constant: -24),
            
            prevButton.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor),
            prevButton.leadingAnchor.constraint(equalTo: buttonCardView.leadingAnchor, constant: 16),
            prevButton.widthAnchor.constraint(equalToConstant: 48),
            prevButton.heightAnchor.constraint(equalToConstant: 48),
            
            nextButton.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: buttonCardView.trailingAnchor, constant: -16),
            nextButton.widthAnchor.constraint(equalToConstant: 48),
            nextButton.heightAnchor.constraint(equalToConstant: 48),
            
            opacitySlider.leadingAnchor.constraint(equalTo: sliderContainer.leadingAnchor, constant: 0),
            opacitySlider.trailingAnchor.constraint(equalTo: sliderContainer.trailingAnchor, constant: 0),
            opacitySlider.centerYAnchor.constraint(equalTo: sliderContainer.centerYAnchor),
            stepProgressLabel.centerXAnchor.constraint(equalTo: buttonCardView.centerXAnchor),
            stepProgressLabel.centerYAnchor.constraint(equalTo: buttonCardView.centerYAnchor)
        ])
        
    }
    
    // MARK: - Step Navigation
    @objc private func prevTapped() {
        if currentIndex > 0 {
            currentIndex -= 1
            updateStep()
            updateTracingImageForCurrentStep()
        }
    }
    
    @objc private func nextTapped() {
        if currentIndex < steps.count - 1 {
            currentIndex += 1
            updateStep()
            updateTracingImageForCurrentStep()
        } else {
            showCompletionTooltip()
        }
    }
    
    private func showCompletionTooltip() {
        let tooltipView = TooltipView(text: "Great job! You've completed all the steps!") { [weak self] in
            self?.dismiss(animated: true)
        }
        
        view.addSubview(tooltipView)
        tooltipView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            tooltipView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            tooltipView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            tooltipView.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8)
        ])
    }
    
    private func updateStep() {
        print("currentIndex",currentIndex)
        let step = steps[currentIndex]
        stepTitleLabel.text = step.title
        stepDescriptionLabel.text = step.description
        stepProgressLabel.text = "Step \(currentIndex + 1) of \(steps.count)"
        
        let isLast = (currentIndex == steps.count - 1)
        finishButton.setTitle(isLast ? "Finish" : "Save", for: .normal)
        prevButton.isHidden = (currentIndex == 0)
        nextButton.isHidden = isLast
        
        showTooltip(withText: step.description)
    }
    
    
    private func updateTracingImageForCurrentStep() {
        // Get the current step
        let step = steps[currentIndex]
        
        // Get path to image in documents directory
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(step.imageName)
        
        // Check if file exists and load it
        if FileManager.default.fileExists(atPath: fileURL.path),
           let data = try? Data(contentsOf: fileURL),
           let image = UIImage(data: data) {
            currentImage = image
            
            // Replace the tracing image in the existing node
            if let tracingNode = self.tracingNode, let plane = tracingNode.geometry as? SCNPlane {
                plane.firstMaterial?.diffuse.contents = image
            }
        } else {
            print("Image not found at path: \(fileURL.path)")
        }
        
        //        if let newImage = UIImage(named: steps[currentIndex].imageName) {
        //            // Replace the tracing image in the existing node
        //            if let tracingNode = self.tracingNode, let plane = tracingNode.geometry as? SCNPlane {
        //                plane.firstMaterial?.diffuse.contents = newImage
        //            }
        //        }
        
        
    }
    
    @objc private func toggleTooltip() {
        if let tip = tooltip {
            // Sudah tampil → sembunyikan & buang
            UIView.animate(withDuration: 0.2, animations: {
                tip.alpha = 0
            }, completion: { _ in
                tip.removeFromSuperview()
                self.tooltip = nil
            })
        } else {
            // Belum tampil → buat & tampilkan
            let text = steps[currentIndex].description
            let tip = TooltipView(text: text)
            tip.alpha = 0
            tip.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(tip)
            self.tooltip = tip
            
            NSLayoutConstraint.activate([
                tip.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 12),
                tip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
                tip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16)
            ])
            
            UIView.animate(withDuration: 0.2) {
                tip.alpha = 1
            }
        }
    }
    
    private func showTooltip(withText text: String, autoDismiss: Bool = true) {
        tooltip?.removeFromSuperview()
        
        let tip = TooltipView(text: text) { [weak self] in
            self?.tooltip = nil
        }
        
        tip.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tip)
        tooltip = tip
        
        NSLayoutConstraint.activate([
            tip.topAnchor.constraint(equalTo: infoButton.bottomAnchor, constant: 20),
            tip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tip.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            tip.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
        
        view.layoutIfNeeded()
        
        if autoDismiss {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self, weak tip] in
                guard let tip = tip, tip == self?.tooltip else { return }
                
                UIView.animate(withDuration: 0.5, animations: {
                    tip.alpha = 0
                }, completion: { _ in
                    if tip == self?.tooltip {
                        tip.removeFromSuperview()
                        self?.tooltip = nil
                    }
                })
            }
        }
    }
    
}

extension ARTracingViewController: CustomIconButtonViewDelegate {
    func didTapCustomViewButton(_ button: CustomIconButtonView) {
        if button === infoButton {
            toggleTooltip()
        }
    }
}

// MARK: - ARSCNViewDelegate & ARSessionDelegate

extension ARTracingViewController: ARSCNViewDelegate, ARSessionDelegate {
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        guard let imageAnchor = anchor as? ARImageAnchor,
              imageAnchor.referenceImage.name == "AnchorImage" else { return }
        
        DispatchQueue.main.async {
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
            let newTracingNode = createTracingNode()
            let anchorWidth = imageAnchor.referenceImage.physicalSize.width
            let anchorHeight = imageAnchor.referenceImage.physicalSize.height

            if let plane = newTracingNode.geometry as? SCNPlane {
                // Offset so top-left of tracing image is at anchor center, node at bottom-right
                let offsetX = plane.width / 2
                let offsetZ = plane.height / 2
                newTracingNode.position = SCNVector3(x: Float(offsetX), y: 0.001, z: Float(offsetZ))
            }
            newTracingNode.eulerAngles.x = -.pi / 2

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
        
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }
        
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
            
            if self.tracingNode == nil && !self.hasPlacedInitialTracingNode {
                self.placeTracingNodeInWorldSpace()
            }
        }
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        DispatchQueue.main.async {
            self.anchorPopupView?.isHidden = false
        }
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
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

class OpacityUISlider: UISlider {
    private let trackHeight: CGFloat = 20
    
    override func trackRect(forBounds bounds: CGRect) -> CGRect {
        let y = (bounds.height - trackHeight) / 2
        return CGRect(x: 0, y: y, width: bounds.width, height: trackHeight)
    }
    
    override func thumbRect(
        forBounds bounds: CGRect,
        trackRect rect: CGRect,
        value: Float
    ) -> CGRect {
        let r = super.thumbRect(forBounds: bounds, trackRect: rect, value: value)
        let dy = rect.midY - r.midY
        return r.offsetBy(dx: 0, dy: dy)
    }
}

private func makeRoundedWedgeGradient(
    size: CGSize,
    startColor: UIColor,
    endColor: UIColor,
    startThickness: CGFloat,
    cornerRadius: CGFloat
) -> UIImage {
    let grad = CAGradientLayer()
    grad.frame = CGRect(origin: .zero, size: size)
    grad.colors = [ startColor.cgColor, endColor.cgColor ]
    grad.startPoint = CGPoint(x: 0, y: 0.5)
    grad.endPoint   = CGPoint(x: 1, y: 0.5)
    
    let midY = size.height/2
    let leftHalfH = startThickness/2
    let path = UIBezierPath()
    
    path.move(to: CGPoint(x: cornerRadius, y: midY - leftHalfH))
    path.addLine(to: CGPoint(x: size.width - cornerRadius, y: 0))
    path.addArc(
        withCenter: CGPoint(x: size.width - cornerRadius, y: cornerRadius),
        radius: cornerRadius,
        startAngle: -CGFloat.pi/2,
        endAngle: 0,
        clockwise: true
    )
    path.addLine(to: CGPoint(x: size.width, y: size.height - cornerRadius))
    path.addArc(
        withCenter: CGPoint(x: size.width - cornerRadius, y: size.height - cornerRadius),
        radius: cornerRadius,
        startAngle: 0,
        endAngle: CGFloat.pi/2,
        clockwise: true
    )
    path.addLine(to: CGPoint(x: cornerRadius, y: midY + leftHalfH))
    path.addArc(
        withCenter: CGPoint(x: cornerRadius, y: size.height/2 + leftHalfH - cornerRadius),
        radius: cornerRadius,
        startAngle: CGFloat.pi/2,
        endAngle: CGFloat.pi,
        clockwise: true
    )
    path.addArc(
        withCenter: CGPoint(x: cornerRadius, y: size.height/2 - leftHalfH + cornerRadius),
        radius: cornerRadius,
        startAngle: CGFloat.pi,
        endAngle: 3 * CGFloat.pi / 2,
        clockwise: true
    )
    path.close()
    
    let mask = CAShapeLayer()
    mask.path = path.cgPath
    grad.mask = mask
    
    UIGraphicsBeginImageContextWithOptions(size, false, 0)
    grad.render(in: UIGraphicsGetCurrentContext()!)
    let img = UIGraphicsGetImageFromCurrentImageContext()!
    UIGraphicsEndImageContext()
    return img
}


class OpacitySliderView: UIView {
    var onOpacityChanged: ((Float) -> Void)?
    
    private let label: UILabel = {
        let l = UILabel()
        l.text = "OPACITY"
        l.textColor = UIColor(named: "Inkredible-DarkPurple")
        l.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .bold)
        l.translatesAutoresizingMaskIntoConstraints = false
        return l
    }()
    
    private let slider: OpacityUISlider = {
        let s = OpacityUISlider()
        s.minimumValue = 0
        s.maximumValue = 1
        s.value = 0.8
        s.translatesAutoresizingMaskIntoConstraints = false
        s.setThumbImage(OpacitySliderView.generateThumb(size: 25), for: .normal)
        return s
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        backgroundColor = .white
        layer.cornerRadius = 16
        clipsToBounds = false
        
        addSubview(label)
        addSubview(slider)
        
        slider.addTarget(self, action: #selector(valueChanged), for: .valueChanged)
        
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            label.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            
            slider.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 10),
            slider.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            slider.centerYAnchor.constraint(equalTo: label.centerYAnchor),
            slider.heightAnchor.constraint(equalToConstant: 30),
            
            bottomAnchor.constraint(equalTo: slider.bottomAnchor, constant: 8)
        ])
        
        valueChanged(slider)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let trackRect = slider.trackRect(forBounds: slider.bounds)
        
        let img = makeRoundedWedgeGradient(
            size: trackRect.size,
            startColor: .white,
            endColor: UIColor(named: "Inkredible-DarkText") ?? .black,
            startThickness: 0,
            cornerRadius: trackRect.height/2
        )
        
        let caps = UIEdgeInsets(top: 0, left: trackRect.height/2, bottom: 0, right: trackRect.height/2)
        let stretchable = img.resizableImage(withCapInsets: caps, resizingMode: .stretch)
        
        slider.setMinimumTrackImage(stretchable, for: .normal)
        slider.setMaximumTrackImage(stretchable, for: .normal)
    }
    
    @objc private func valueChanged(_ s: UISlider) {
        onOpacityChanged?(s.value)
        let minD: CGFloat = 10, maxD: CGFloat = 35
        let d = minD + CGFloat(s.value) * (maxD - minD)
        s.setThumbImage(Self.generateThumb(size: d), for: .normal)
    }
    
    private static func generateThumb(size: CGFloat) -> UIImage {
        let scale = UIScreen.main.scale
        let diameter = floor(size * scale) / scale
        let rect = CGRect(origin: .zero, size: CGSize(width: diameter, height: diameter))
        
        UIGraphicsBeginImageContextWithOptions(rect.size, false, scale)
        guard let ctx = UIGraphicsGetCurrentContext() else {
            return UIImage()
        }
        
        let fillColor   = (UIColor(named: "Inkredible-Green") ?? .green).cgColor
        let strokeColor = UIColor.black.cgColor
        ctx.setFillColor(fillColor)
        ctx.setStrokeColor(strokeColor)
        
        let lineWidth = 1.0 / scale
        ctx.setLineWidth(lineWidth)
        
        let insetRect = rect.insetBy(dx: lineWidth/2, dy: lineWidth/2)
        
        ctx.fillEllipse(in: insetRect)
        ctx.strokeEllipse(in: insetRect)
        
        let img = UIGraphicsGetImageFromCurrentImageContext() ?? UIImage()
        UIGraphicsEndImageContext()
        return img
    }
}
//
//extension ARTracingViewController: PhotoCaptureSheetDelegate,
//                                   UIImagePickerControllerDelegate,
//                                   UINavigationControllerDelegate {
//
//  func photoCaptureSheetDidRequestPhoto(_ sheet: PhotoCaptureSheetViewController) {
//    presentCameraOverlay()
//  }
//
//  private func presentCameraOverlay() {
//    let picker = TaggedImagePickerController()
//    picker.delegate   = self
//    picker.sourceType = .camera
//    picker.pickerTag  = 100
//
//    // langsung pakai tracingImage (bukan Optional binding)
//    let overlay = UIView(frame: picker.view.frame)
//    let iv = UIImageView(image: tracingImage)
//    iv.contentMode = .scaleAspectFit
//    iv.alpha       = 0.3
//    iv.frame       = overlay.bounds
//    overlay.addSubview(iv)
//
//    picker.cameraOverlayView   = overlay
//    picker.showsCameraControls = true
//    present(picker, animated: true)
//  }
//
//  // MARK: – UIImagePickerControllerDelegate
//  func imagePickerController(_ picker: UIImagePickerController,
//                             didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//    picker.dismiss(animated: true)
//
//    // cast dulu ke TaggedImagePickerController
//    guard let tagged = picker as? TaggedImagePickerController,
//          tagged.pickerTag == 100,
//          let userPhoto = info[.originalImage] as? UIImage else {
//      return
//    }
//
//    let contourVC = ContourDetectionViewController()
//    contourVC.referenceImage    = tracingImage
//    contourVC.userDrawingImage  = userPhoto
//    navigationController?.pushViewController(contourVC, animated: true)
//  }
//
//  func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//    picker.dismiss(animated: true)
//  }
//
//  func photoCaptureSheetDidSkip(_ sheet: PhotoCaptureSheetViewController) {
//    // misal:
//    // navigationController?.popViewController(animated: true)
//  }
//}
