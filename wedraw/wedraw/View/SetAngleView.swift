//
//  SetAngleView.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//



import UIKit
import SceneKit

protocol SetAngleViewDelegate: AnyObject {
    func infoButtonTapped()
    func chooseButtonTapped()
    func presetAngleButtonTapped()
    func presetButtonTapped(at index: Int)
    func cameraPositionChanged(_ position: SCNVector3)
}

class SetAngleView: UIView {
    weak var delegate: SetAngleViewDelegate?

    
    let sceneView: SCNView = {
        let view = SCNView()
        view.backgroundColor = .clear
        view.allowsCameraControl = false
        return view
    }()
    
    // Expose the 3D model node for rotation
    private(set) var modelNode: SCNNode?
    
    let angleLabel: UILabel = {
        let label = UILabel()
        label.text = "3/4 Angle"
        label.textColor = .black
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    let cameraCoordinateLabel: UILabel = {
        let label = UILabel()
        label.text = "Model: (x: 0, y: 0, z: 0)"
        label.textColor = .darkGray
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    let presetAngleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Preset Angle", for: .normal)
        button.setTitleColor(UIColor(.black), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = .clear
        return button
    }()
    
    let chooseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 16
        return button
    }()
    
    let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Inkredible-LightPurple")
        return view
    }()
    
    let infoButton: UIButton = {
        let button = UIButton(type: .system)
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
        button.setImage(UIImage(systemName: "info.circle.fill", withConfiguration: symbolConfig), for: .normal)
        button.tintColor = UIColor(named: "Inkredible-LightPurple")
        return button
    }()
    
    let infoToastView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(white: 0.2, alpha: 0.95)
        view.layer.cornerRadius = 12
        view.alpha = 0
        return view
    }()
    
    let infoToastLabel: UILabel = {
        let label = UILabel()
        label.text = "Use your finger to rotate the model and choose the angle that best suits your needs."
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    let toastOverlayView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.alpha = 0
        return view
    }()
    
    private var cameraDisplayLink: CADisplayLink?
    private var presetButtons: [UIButton] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        setupConstraints()
        setupActions()
        setupRotationGesture()
        startCameraCoordinateUpdates()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
        setupConstraints()
        setupActions()
        setupRotationGesture()
        startCameraCoordinateUpdates()
    }
        
    private func setupView() {
        backgroundColor = .white
        
        addSubview(sceneView)
        addSubview(angleLabel)
        addSubview(cameraCoordinateLabel)
        addSubview(bottomContainerView)
        addSubview(infoButton)
        addSubview(infoToastView)
        addSubview(toastOverlayView)
        
        bottomContainerView.addSubview(presetAngleButton)
        bottomContainerView.addSubview(chooseButton)
        infoToastView.addSubview(infoToastLabel)
        
        setupSceneKit()
        setupPresetButtons()
        setupToastOverlay()
    }
    
    private func setupConstraints() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
        cameraCoordinateLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        presetAngleButton.translatesAutoresizingMaskIntoConstraints = false
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        infoToastView.translatesAutoresizingMaskIntoConstraints = false
        infoToastLabel.translatesAutoresizingMaskIntoConstraints = false
        toastOverlayView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // SceneView
            sceneView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            sceneView.centerXAnchor.constraint(equalTo: centerXAnchor),
            sceneView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            sceneView.heightAnchor.constraint(equalTo: sceneView.widthAnchor),

            // Camera Coordinate Label
            cameraCoordinateLabel.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 8),
            cameraCoordinateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            cameraCoordinateLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            
            // Angle Label
            angleLabel.topAnchor.constraint(equalTo: cameraCoordinateLabel.bottomAnchor, constant: 100),
            angleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            
            // Info Button
            infoButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5),
            infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Bottom Container
            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 157),
            
            // Choose Button
            chooseButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 44),
            chooseButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -55),
            chooseButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 32),
            chooseButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -32),
            
            // Preset Angle Button
            presetAngleButton.bottomAnchor.constraint(equalTo: chooseButton.topAnchor, constant: -15),
            presetAngleButton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
            
            // Info Toast
            infoToastView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            infoToastView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            infoToastView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            infoToastLabel.topAnchor.constraint(equalTo: infoToastView.topAnchor, constant: 16),
            infoToastLabel.bottomAnchor.constraint(equalTo: infoToastView.bottomAnchor, constant: -16),
            infoToastLabel.leadingAnchor.constraint(equalTo: infoToastView.leadingAnchor, constant: 16),
            infoToastLabel.trailingAnchor.constraint(equalTo: infoToastView.trailingAnchor, constant: -16),
            
            // Toast Overlay
            toastOverlayView.topAnchor.constraint(equalTo: topAnchor),
            toastOverlayView.bottomAnchor.constraint(equalTo: bottomAnchor),
            toastOverlayView.leadingAnchor.constraint(equalTo: leadingAnchor),
            toastOverlayView.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    private func setupActions() {
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        chooseButton.addTarget(self, action: #selector(chooseButtonTapped), for: .touchUpInside)
        presetAngleButton.addTarget(self, action: #selector(presetAngleButtonTapped), for: .touchUpInside)
    }
    
    private func setupSceneKit() {
        let scene = SCNScene(named: "SceneKit Asset Catalog.scnassets/head_angle.scn")
        
        // Find and store the model node (assuming it's the first child of root)
        if let rootNode = scene?.rootNode, let firstChild = rootNode.childNodes.first {
            modelNode = firstChild
        }
        
        // Create a light node
        let lightNode = SCNNode()
        let light = SCNLight()
        light.type = .area
        light.intensity = 100
        lightNode.light = light
        lightNode.position = SCNVector3(x: 0, y: 10, z: 10)

        // Add the light to the scene
        scene?.rootNode.addChildNode(lightNode)

        let ambientLightNode = SCNNode()
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 300
        ambientLight.color = UIColor.white
        ambientLightNode.light = ambientLight
        scene?.rootNode.addChildNode(ambientLightNode)

        sceneView.scene = scene
    }
    
    private func setupPresetButtons() {
        let radius: CGFloat = 150
        let buttonSize: CGFloat = 50
        let angles: [CGFloat] = [1.1, 1.35, 1.5707, 1.8, 2.05]
        let buttonIcons = ["preset_top", "preset_side_left", "preset_quarter", "preset_side_right", "preset_front"]

        for (index, angle) in angles.enumerated() {
            let button = UIButton()
            let image = UIImage(named: buttonIcons[index])
            button.setImage(image, for: .normal)
            button.imageView?.contentMode = .scaleAspectFit
            button.contentEdgeInsets = UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8)
            
            if index == 2 {
                button.backgroundColor = .black
                button.layer.borderColor = UIColor.white.cgColor
                button.layer.borderWidth = 2
            } else {
                button.backgroundColor = .systemGray3
            }
            button.layer.cornerRadius = buttonSize / 2
            button.tag = index
            
            button.addTarget(self, action: #selector(presetButtonTapped(_:)), for: .touchUpInside)
            
            addSubview(button)
            button.translatesAutoresizingMaskIntoConstraints = false
            presetButtons.append(button)
            
            let centerXConstant = radius * cos(angle)
            let centerYConstant = radius * sin(angle) - radius - 20
            
            NSLayoutConstraint.activate([
                button.centerXAnchor.constraint(equalTo: centerXAnchor, constant: centerXConstant),
                button.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: centerYConstant),
                button.widthAnchor.constraint(equalToConstant: buttonSize),
                button.heightAnchor.constraint(equalToConstant: buttonSize)
            ])
        }
    }
    
    private func setupToastOverlay() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissToast))
        toastOverlayView.addGestureRecognizer(tapGesture)
    }
    
    @objc private func infoButtonTapped() {
        delegate?.infoButtonTapped()
    }
    
    @objc private func chooseButtonTapped() {
        delegate?.chooseButtonTapped()
    }
    
    @objc private func presetAngleButtonTapped() {
        delegate?.presetAngleButtonTapped()
    }
    
    @objc private func presetButtonTapped(_ sender: UIButton) {
        delegate?.presetButtonTapped(at: sender.tag)
    }
    
    @objc private func dismissToast() {
        delegate?.infoButtonTapped()
    }
        
    func showToast() {
        bringSubviewToFront(toastOverlayView)
        bringSubviewToFront(infoToastView)
        
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.infoToastView.alpha = 1.0
            self.toastOverlayView.alpha = 1.0
        }, completion: nil)
    }
    
    func hideToast() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.infoToastView.alpha = 0.0
            self.toastOverlayView.alpha = 0.0
        }, completion: nil)
    }
    
    func updateAngleLabel(_ text: String) {
        angleLabel.text = text
    }
    
    func updateCameraCoordinateLabel(_ text: String) {
        cameraCoordinateLabel.text = text
    }
    
    func updatePresetButtonSelection(selectedIndex: Int) {
        for (index, button) in presetButtons.enumerated() {
            if index == selectedIndex {
                button.backgroundColor = .black
                button.layer.borderColor = UIColor.white.cgColor
                button.layer.borderWidth = 2
            } else {
                button.backgroundColor = .systemGray3
                button.layer.borderWidth = 0
            }
        }
    }
    
    private func startCameraCoordinateUpdates() {
        cameraDisplayLink = CADisplayLink(target: self, selector: #selector(updateCameraCoordinateDisplay))
        cameraDisplayLink?.add(to: .main, forMode: .default)
    }
    
    private func stopCameraCoordinateUpdates() {
        cameraDisplayLink?.invalidate()
        cameraDisplayLink = nil
    }
    
    @objc private func updateCameraCoordinateDisplay() {
        guard let modelNode = self.modelNode else { return }
        let pos = modelNode.eulerAngles
        let positionText = String(format: "Model: (x: %.2f, y: %.2f, z: %.2f)", pos.x, pos.y, pos.z)
        updateCameraCoordinateLabel(positionText)
        delegate?.cameraPositionChanged(pos)
    }
    
    private func setupRotationGesture() {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        sceneView.addGestureRecognizer(panGesture)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let modelNode = self.modelNode else { return }
        let translation = gesture.translation(in: sceneView)
        let widthRatio = Float(translation.x) / Float(sceneView.bounds.size.width) * Float.pi
        let heightRatio = Float(translation.y) / Float(sceneView.bounds.size.height) * Float.pi
        
        // Only allow rotation on x and z, keep y at 0
        if gesture.state == .changed || gesture.state == .ended {
            modelNode.eulerAngles.x += heightRatio
            modelNode.eulerAngles.z += widthRatio
            modelNode.eulerAngles.y = 0
            gesture.setTranslation(.zero, in: sceneView)
        }
    }
    
    deinit {
        stopCameraCoordinateUpdates()
    }
}

#Preview {
    SetAngleView()
}
