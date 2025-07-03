//
//  SetAngleViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit
import SceneKit

struct AnglePreset {
    let name: String
    let iconName: String
    let rotationAngles: SCNVector3
    let angle: CGFloat
}

class SetAngleViewController: UIViewController {

    var router: MainFlowRouter?
    
    let angleService = AngleService()
    let stepService = StepService()
    
    private var loadingView: UIActivityIndicatorView?
    
    private var loadingOverlay: UIView?
    
    var allPresetAngle: [Angle] = []
    var selectedPresetIndex: Int = 0 // Default to quarter view
    var currentRotationAngles: SCNVector3 = SCNVector3(x: 0.3, y: -Float.pi/4, z: 0)
    
    private let modelNames = ["step1", "step2", "step3", "step4", "step5", "step6", "step7", "step8", "step9", "step10"]
    private var currentModelIndex = 0
    

    // MARK: - Properties
    private let setAngleView = SetAngleView()
    private var isToastVisible = false
    private var dismissWorkItem: DispatchWorkItem?
    var cameraPresets: [AnglePreset] = []
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Your Angle"
        loadPreset()
        setupView()
        setupInitialState()
    }
    func loadPreset() {
        allPresetAngle = angleService.getPresetAngle()
        print("=== Loaded \(allPresetAngle.count) total preset angle ===")
        
        var angleByIcon: [String: Angle] = [:]
        for angle in allPresetAngle {
            if let iconName = angle.icon_name {
                angleByIcon[iconName] = angle
            }
        }

        let presetIconOrder = ["preset_front", "preset_side_right", "preset_quarter", "preset_side_left", "preset_top"]
        cameraPresets = []
        for iconName in presetIconOrder {
            if let angle = angleByIcon[iconName], let name = angle.angle_name, let icon = angle.icon_name {
                cameraPresets.append(AnglePreset(name: name, iconName: icon, rotationAngles: SCNVector3(x: angle.x, y: angle.y, z: angle.z), angle: angle.angle))
            }
        }
    }
    
    override func loadView() {
        view = setAngleView
    }
    
    
    private func setupView() {
        setAngleView.delegate = self
    }
    
    private func setupInitialState() {
        // Set initial angle label based on default preset
        
        let selectedPreset = getSelectedPreset()
        setAngleView.updateAngleLabel(selectedPreset.name)
        setAngleView.updatePresetButtonSelection(selectedIndex: selectedPresetIndex)
        
        // Set initial rotation of the 3D model to the default preset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.rotateModel(to: selectedPreset.rotationAngles)
        }
    }
    
    func getSelectedPreset() -> AnglePreset {
        return cameraPresets[selectedPresetIndex]
    }
    
    func updateSelectedPreset(_ index: Int) {
        guard index >= 0 && index < cameraPresets.count else { return }
        selectedPresetIndex = index
        currentRotationAngles = cameraPresets[index].rotationAngles
    }
    
    func updateRotationAngles(_ angles: SCNVector3) {
        currentRotationAngles = angles
    }
    
    func getAngleName(for angles: SCNVector3) -> String {
        // Find the closest preset based on rotation angles
        var closestPreset = cameraPresets[0]
        var minDistance = Float.greatestFiniteMagnitude
        
        for preset in cameraPresets {
            let distance = sqrt(
                pow(angles.x - preset.rotationAngles.x, 2) +
                pow(angles.y - preset.rotationAngles.y, 2) +
                pow(angles.z - preset.rotationAngles.z, 2)
            )
            
            if distance < minDistance {
                minDistance = distance
                closestPreset = preset
            }
        }
        
        // If we're close enough to a preset, return its name
        if minDistance < 0.3 {
            return closestPreset.name
        } else {
            return "Custom Angle"
        }
    }
    
    private let modelConfigs: [String: ModelConfig] = [
        "head": ModelConfig(
            zoomDistance: 2.0,
            position: SCNVector3(0, 0, 0),
            rotation: SCNVector3(-Float.pi/1.5, Float.pi/3, 0)
        ),
        "step1": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step2": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step3": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step4": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step5": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step6": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step7": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step8": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step9": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        ),
        "step10fix": ModelConfig(
            zoomDistance: 2.7,
            position: SCNVector3(0, 0, 0),
//            rotation: SCNVector3(-Float.pi/2, Float.pi/3, 0)
            rotation: SCNVector3(-Float.pi/1.5 + Float.pi/6, Float.pi/3, 0)
        )
    ]
    
}

// MARK: - SetAngleViewDelegate
extension SetAngleViewController: SetAngleViewDelegate {
    
    func infoButtonTapped() {
        // Remove any existing tooltip
        setAngleView.tooltip?.removeFromSuperview()
        // Create and show a new tooltip
        let tip = TooltipView(text: "Use your finger to rotate the model and choose the angle that best suits your needs.") { [weak self] in
            self?.setAngleView.tooltip = nil
        }
        tip.translatesAutoresizingMaskIntoConstraints = false
        setAngleView.addSubview(tip)
        setAngleView.tooltip = tip

        // Position the tooltip below the info button
        NSLayoutConstraint.activate([
            tip.topAnchor.constraint(equalTo: setAngleView.infoButton.bottomAnchor, constant: 8),
            tip.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
//            tip.widthAnchor.constraint(equalToConstant: 250),
            tip.trailingAnchor.constraint(lessThanOrEqualTo: setAngleView.infoButton.trailingAnchor),
            tip.heightAnchor.constraint(greaterThanOrEqualToConstant: 60)
        ])
    }
    
    // Swift
    func chooseButtonTapped() {
        showLoading()
        let current: SCNVector3 = getCurrentModelRotation()!
        let (isPreset, matched) = checkIfUsingPreset()
        var dataAngle: Angle!
        if isPreset {
            dataAngle = angleService.getAngleByName(angle_name: matched?.name ?? "")!
            let getSteps : [Step] = stepService.getSteps(angle_id: dataAngle.angle_id!)
            if getSteps.isEmpty {
                Task {
                    for i in 1...10 {
                        await exportModelNamed(modelNames[i-1], rotation: current, angle_id: dataAngle.angle_id!, step_number: i)
                    }
                    DispatchQueue.main.async { [weak self] in
                        self?.hideLoading()
                        self?.router?.navigate(to: .selectDrawingViewController(selectedAngle: dataAngle), animated: true)
                    }
                }
                return
            }else{
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.router?.navigate(to: .selectDrawingViewController(selectedAngle: dataAngle), animated: true)
                }
                return
            }
        } else {
            let customAngle : [Angle] = angleService.getNonPresetAngle()
            let newAngleId = UUID()
            let angleName = "Custom \(customAngle.count + 1)"
            angleService.createAngle(
                angle_id: newAngleId,
                angle_name: angleName,
                x: Float(0),
                y: Float(0),
                z: Float(0),
                angle_value: Double(0),
                angle_number: Int16(customAngle.count + 6)
            )
            Task {
                for i in 1...10 {
                    await exportModelNamed(modelNames[i-1], rotation: current, angle_id: newAngleId, step_number: i)
                }
                dataAngle = angleService.getAngleByName(angle_name: angleName)!
                DispatchQueue.main.async { [weak self] in
                    self?.hideLoading()
                    self?.router?.navigate(to: .selectDrawingViewController(selectedAngle: dataAngle), animated: true)
                }
            }
            return
        }
    }
    
    func getCurrentModelRotation() -> SCNVector3? {
        return setAngleView.modelNode?.eulerAngles
    }
    
    func presetAngleButtonTapped() {
        // Handle preset angle button action
        print("Preset angle button tapped")
    }
    
    // Swift
    private func showLoading() {
        // Create a completely new window at a higher level instead of using existing window
        guard let windowScene = UIApplication.shared.connectedScenes
            .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
        
        // Create a new window at a higher level
        let overlayWindow = UIWindow(windowScene: windowScene)
        overlayWindow.windowLevel = .alert + 1 // Higher than alerts
        overlayWindow.backgroundColor = .clear
        overlayWindow.isUserInteractionEnabled = true
        overlayWindow.makeKeyAndVisible()
        
        // Create full screen overlay
        let overlay = UIView(frame: overlayWindow.bounds)
        overlay.backgroundColor = UIColor(white: 0, alpha: 0.5)
        overlay.isUserInteractionEnabled = true
        overlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        // Add tap gesture recognizer
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        overlay.addGestureRecognizer(tapGesture)
        
        overlayWindow.addSubview(overlay)
        self.loadingOverlay = overlay
        
        // Store window reference to prevent it from being deallocated
        objc_setAssociatedObject(self, &AssociatedKeys.loadingWindow, overlayWindow, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        // Create and position the activity indicator
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .white
        indicator.center = overlay.center
        indicator.startAnimating()
        overlay.addSubview(indicator)
        loadingView = indicator
        
        // Loading label
        let loadingLabel = UILabel()
        loadingLabel.text = "Processing your journey..."
        loadingLabel.textColor = .white
        loadingLabel.textAlignment = .center
        loadingLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingLabel.translatesAutoresizingMaskIntoConstraints = false
        overlay.addSubview(loadingLabel)
        
        NSLayoutConstraint.activate([
            loadingLabel.centerXAnchor.constraint(equalTo: indicator.centerXAnchor),
            loadingLabel.topAnchor.constraint(equalTo: indicator.bottomAnchor, constant: 12)
        ])
    }

    
    // Add this method to handle taps on the overlay
    @objc private func overlayTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        // This method just captures the tap and does nothing
        // Ensure we're consuming the touch event
        print("Overlay tapped - touch intercepted")
    }
    
    private struct AssociatedKeys {
        static var loadingWindow: UInt8 = 0
    }
    
    private func hideLoading() {
        // Remove the loading indicator
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
        
        // Remove the overlay
        loadingOverlay?.removeFromSuperview()
        loadingOverlay = nil
        
        // Get and hide the window
        if let window = objc_getAssociatedObject(self, &AssociatedKeys.loadingWindow) as? UIWindow {
            window.isHidden = true
            // Remove the association
            objc_setAssociatedObject(self, &AssociatedKeys.loadingWindow, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    func presetButtonTapped(at index: Int) {
        // Update the model with the selected preset
        updateSelectedPreset(index)
        
        // Update the view to reflect the selection
        let selectedPreset = getSelectedPreset()
        setAngleView.updateAngleLabel(selectedPreset.name)
        setAngleView.updatePresetButtonSelection(selectedIndex: index)
        
        // Rotate the 3D model to the new angle
        rotateModel(to: selectedPreset.rotationAngles)
        
        print("Preset button tapped: \(selectedPreset.name)")
    }
    
    func cameraPositionChanged(_ position: SCNVector3) {
        // Update the model with the new rotation angles
        updateRotationAngles(position)
        
        // Determine the angle name based on the new rotation
        let angleName = getAngleName(for: position)
        setAngleView.updateAngleLabel(angleName)
        
        // Check if the rotation matches any preset and update selection if needed
        updatePresetSelectionIfNeeded(for: position)
    }
    
    // MARK: - Private Methods
    private func rotateModel(to angles: SCNVector3) {
        guard let modelNode = setAngleView.modelNode else { return }
        
        // Create a smooth rotation animation
        let rotateAction = SCNAction.rotateTo(x: CGFloat(angles.x),
                                            y: CGFloat(angles.y),
                                            z: CGFloat(angles.z),
                                            duration: 1.0)
        rotateAction.timingMode = .easeInEaseOut
        
        modelNode.runAction(rotateAction)
        
        if let modelNode = setAngleView.modelNode {
            let (min, max) = modelNode.boundingBox
            let center = SCNVector3(
                (min.x + max.x) / 2,
                (min.y + max.y) / 2,
                (min.z + max.z) / 2
            )
            modelNode.pivot = SCNMatrix4MakeTranslation(center.x, center.y, center.z)
        }
    }
    
    private func updatePresetSelectionIfNeeded(for angles: SCNVector3) {
        let presets = cameraPresets
        
        for (index, preset) in presets.enumerated() {
            let distance = sqrt(
                pow(angles.x - preset.rotationAngles.x, 2) +
                pow(angles.y - preset.rotationAngles.y, 2) +
                pow(angles.z - preset.rotationAngles.z, 2)
            )
            
            // If we're close enough to a preset, update the selection
            if distance < 0.3 {
                if index != selectedPresetIndex {
                    updateSelectedPreset(index)
//                    setAngleView.updatePresetButtonSelection(selectedIndex: index)
                }
                break
            }
        }
    }
        
    private func showToast() {
        isToastVisible = true
        
        dismissWorkItem?.cancel()
        let workItem = DispatchWorkItem { [weak self] in
            self?.dismissToast()
        }
        dismissWorkItem = workItem
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: workItem)
    }
    
    private func dismissToast() {
        if !isToastVisible { return }
        
        dismissWorkItem?.cancel()
        isToastVisible = false
    }
    func checkIfUsingPreset() -> (isPreset: Bool, matchedPreset: AnglePreset?) {
        guard let currentRotation = getCurrentModelRotation() else {
            return (false, nil)
        }

        for preset in cameraPresets {
            let distance = sqrt(
                pow(currentRotation.x - preset.rotationAngles.x, 2) +
                pow(currentRotation.y - preset.rotationAngles.y, 2) +
                pow(currentRotation.z - preset.rotationAngles.z, 2)
            )
            if distance < 0.1 {
                return (true, preset)
            }
        }

        return (false, nil)
    }
    
    private func exportModelNamed(_ name: String, rotation: SCNVector3, angle_id: UUID, step_number: Int) async {
        guard let scene = SCNScene(named: "SceneKit Asset Catalog.scnassets/\(name).scn") else {
            return
        }

        let config = ModelConfig(
            zoomDistance: 5.0,
            position: SCNVector3Zero,
            rotation: SCNVector3(rotation.x + Float.pi/6 - Float.pi/2, rotation.z, -rotation.y )
        )

        // Setup camera
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, config.zoomDistance - 3.0)
        scene.rootNode.addChildNode(cameraNode)

        // Load and configure model
        if let modelNode = scene.rootNode.childNodes.first {
            modelNode.position = config.position
            modelNode.eulerAngles = config.rotation
            modelNode.scale = SCNVector3(1, 1, 1)
            modelNode.enumerateChildNodes { child, _ in
                child.geometry?.materials.forEach { $0.lightingModel = .constant }
            }
        }

        // Add ambient and omni light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 500
        ambientLight.color = UIColor.white
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)

        let omniLight = SCNLight()
        omniLight.type = .omni
        omniLight.intensity = 500
        omniLight.color = UIColor.white
        let omniNode = SCNNode()
        omniNode.light = omniLight
        omniNode.position = SCNVector3(5, 5, 10)
        scene.rootNode.addChildNode(omniNode)

        guard let device = MTLCreateSystemDefaultDevice(), let commandQueue = device.makeCommandQueue() else {
            return
        }

        let renderer = SCNRenderer(device: device, options: nil)
        renderer.scene = scene
        renderer.pointOfView = cameraNode

        let width = 1024
        let height = 1024
        let textureDesc = MTLTextureDescriptor.texture2DDescriptor(
            pixelFormat: .bgra8Unorm_srgb,
            width: width,
            height: height,
            mipmapped: false
        )
        textureDesc.usage = [.renderTarget, .shaderRead]
        textureDesc.storageMode = .shared

        guard let texture = device.makeTexture(descriptor: textureDesc) else {
            return
        }

        let passDescriptor = MTLRenderPassDescriptor()
        passDescriptor.colorAttachments[0].texture = texture
        passDescriptor.colorAttachments[0].loadAction = .clear
        passDescriptor.colorAttachments[0].storeAction = .store
        passDescriptor.colorAttachments[0].clearColor = MTLClearColorMake(0, 0, 0, 0)

        guard let commandBuffer = commandQueue.makeCommandBuffer() else {
            return
        }

        renderer.render(
            atTime: CACurrentMediaTime(),
            viewport: CGRect(x: 0, y: 0, width: width, height: height),
            commandBuffer: commandBuffer,
            passDescriptor: passDescriptor
        )
        commandBuffer.commit()
        commandBuffer.waitUntilCompleted()

        // Read pixels
        var rawData = [UInt8](repeating: 0, count: width * height * 4)
        texture.getBytes(&rawData, bytesPerRow: width * 4,
                         from: MTLRegionMake2D(0, 0, width, height),
                         mipmapLevel: 0)

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        guard let context = CGContext(
            data: &rawData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: width * 4,
            space: colorSpace,
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ),
        let cgImage = context.makeImage() else {
            return
        }

        let image = UIImage(cgImage: cgImage)
        guard let pngData = image.pngData() else {
            return
        }

        let fileName = "\(angle_id)_Export_\(name).png"
        let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent(fileName)
        let step_id = UUID()
        stepService.insertStep(
            step_id: step_id,
            angle_id: angle_id,
            step_number: Int16(step_number),
            image: fileName
        )
        
        do {
            try pngData.write(to: fileURL)
        } catch {
            print("Save failed: \(error)")
        }
    }
}
#Preview {
    SetAngleViewController()
}

