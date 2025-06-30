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
    func presetButtonTapped(at index: Int)
    func presetAngleButtonTapped()
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
    
    private(set) var modelNode: SCNNode?
    
    let angleLabel: UILabel = {
        let label = UILabel()
        label.text = "3/4 Angle"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .footnote).pointSize, weight: .semibold)
        return label
    }()
    
//    let cameraCoordinateLabel: UILabel = {
//        let label = UILabel()
////        label.text = "Model: (x: 0, y: 0, z: 0)"
//        label.textColor = .darkGray
//        label.font = .systemFont(ofSize: 14, weight: .regular)
//        label.textAlignment = .center
//        return label
//    }()
    
    let presetAngleButton: UIButton = {
        let button = UIButton()
        button.setTitle("Preset Angle", for: .normal)
        button.setTitleColor(UIColor(.white), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .subheadline).pointSize, weight: .regular)
        button.backgroundColor = .clear
        return button
    }()
    
    let chooseButton: UIButton = {
        let button = UIButton()
        button.setTitle("Choose", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: UIFont.preferredFont(forTextStyle: .body).pointSize, weight: .semibold)
        button.backgroundColor = UIColor(named: "Inkredible-Green")
        button.layer.cornerRadius = 20
        return button
    }()
    
    let bottomContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "Inkredible-DarkPurple")
        return view
    }()
    
//    let infoButton: UIButton = {
//        let button = UIButton(type: .system)
//        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)
//        button.setImage(UIImage(systemName: "info.circle.fill", withConfiguration: symbolConfig), for: .normal)
//        button.tintColor = UIColor(named: "Inkredible-LightPurple")
//        return button
//    }()
    
    var infoButton = CustomIconButtonView(iconName: "info", iconColor: UIColor(named: "Inkredible-DarkPurple") ?? .systemYellow, backgroundColor: UIColor(named: "Inkredible-Green") ?? .systemYellow, iconScale: 0.5)
    
    private var cameraDisplayLink: CADisplayLink?
    private var presetButtons: [UIButton] = []
    private let choosePresetPickerView = ChoosePresetPickerView()
    var tooltip: TooltipView?
    
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
//        addSubview(cameraCoordinateLabel)
        addSubview(bottomContainerView)
        addSubview(infoButton)
        
        bottomContainerView.addSubview(presetAngleButton)
        bottomContainerView.addSubview(chooseButton)
        
        addSubview(choosePresetPickerView)
        
        infoButton.updateSize(width: 30)
        
        setupSceneKit()
//        setupPresetButtons()
    }
    
    private func setupConstraints() {
        sceneView.translatesAutoresizingMaskIntoConstraints = false
        angleLabel.translatesAutoresizingMaskIntoConstraints = false
//        cameraCoordinateLabel.translatesAutoresizingMaskIntoConstraints = false
        bottomContainerView.translatesAutoresizingMaskIntoConstraints = false
        presetAngleButton.translatesAutoresizingMaskIntoConstraints = false
        chooseButton.translatesAutoresizingMaskIntoConstraints = false
        infoButton.translatesAutoresizingMaskIntoConstraints = false
        choosePresetPickerView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            // SceneView
            sceneView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 20),
            sceneView.centerXAnchor.constraint(equalTo: centerXAnchor),
            sceneView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),
            sceneView.heightAnchor.constraint(equalTo: sceneView.widthAnchor),

            // Camera Coordinate Label
//            cameraCoordinateLabel.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 8),
//            cameraCoordinateLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
//            cameraCoordinateLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.8),

            // Angle Label
            angleLabel.topAnchor.constraint(equalTo: sceneView.bottomAnchor, constant: 80),
            angleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),

            // Choose Preset Picker (directly above bottom container)
            choosePresetPickerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            choosePresetPickerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            choosePresetPickerView.bottomAnchor.constraint(equalTo: bottomContainerView.topAnchor),
            choosePresetPickerView.heightAnchor.constraint(equalToConstant: 50),

            // Info Button
            infoButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 16),
            infoButton.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),

            // Bottom Container
            bottomContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            bottomContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            bottomContainerView.bottomAnchor.constraint(equalTo: bottomAnchor),
            bottomContainerView.heightAnchor.constraint(equalToConstant: 158),

            // Choose Button
//            chooseButton.topAnchor.constraint(equalTo: bottomContainerView.topAnchor, constant: 44),
//            chooseButton.bottomAnchor.constraint(equalTo: bottomContainerView.bottomAnchor, constant: -55),
            chooseButton.centerYAnchor.constraint(equalTo: bottomContainerView.centerYAnchor),
            chooseButton.leadingAnchor.constraint(equalTo: bottomContainerView.leadingAnchor, constant: 16),
            chooseButton.trailingAnchor.constraint(equalTo: bottomContainerView.trailingAnchor, constant: -16),
            chooseButton.heightAnchor.constraint(equalToConstant: 55),
            
            // Preset Angle Button
            presetAngleButton.bottomAnchor.constraint(equalTo: chooseButton.topAnchor, constant: -15),
            presetAngleButton.centerXAnchor.constraint(equalTo: bottomContainerView.centerXAnchor),
        ])
    }
    
    private func setupActions() {
        infoButton.addTarget(self, action: #selector(infoButtonTapped), for: .touchUpInside)
        chooseButton.addTarget(self, action: #selector(chooseButtonTapped), for: .touchUpInside)
        choosePresetPickerView.delegate = self
        presetAngleButton.addTarget(self, action: #selector(presetAngleButtonTapped), for: .touchUpInside)
    }
    
    private func setupSceneKit() {
        let scene = SCNScene(named: "SceneKit Asset Catalog.scnassets/head.scn")
        
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
//        updateCameraCoordinateLabel(positionText)
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
    
//    func updateCameraCoordinateLabel(_ text: String) {
//        cameraCoordinateLabel.text = text
//    }
    
    func updateAngleLabel(_ text: String) {
        angleLabel.text = text
    }
    
    func updatePresetButtonSelection(selectedIndex: Int) {
        // If you still have presetButtons, update their selection state here.
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
}

extension SetAngleView: ChoosePresetPickerViewDelegate {
    func choosePresetPickerView(_ picker: ChoosePresetPickerView, didSelectPresetAt index: Int) {
        delegate?.presetButtonTapped(at: index)
    }
}
