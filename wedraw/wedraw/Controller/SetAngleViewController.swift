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

    // Router for navigation
    var router: MainFlowRouter?
    
    let angleService = AngleService()
    
    var allPresetAngle: [Angle] = []
    var selectedPresetIndex: Int = 2 // Default to quarter view
    var currentRotationAngles: SCNVector3 = SCNVector3(x: 0.3, y: -Float.pi/4, z: 0)
    

    // MARK: - Properties
    private let setAngleView = SetAngleView()
//    private let angleModel = AngleModel.shared
    private var isToastVisible = false
    private var dismissWorkItem: DispatchWorkItem?
    var cameraPresets: [AnglePreset] = []
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Your Angle"
        loadPreset()
        setupNavigationBar()
        setupView()
        setupInitialState()
    }
    func loadPreset() {
        allPresetAngle = angleService.getPresetAngle()
        print("=== Loaded \(allPresetAngle.count) total preset angle ===")
        
        for angle in allPresetAngle {
            cameraPresets.append(AnglePreset(name: angle.angle_name!, iconName: angle.icon_name!, rotationAngles: SCNVector3(x: angle.x, y: Float(angle.y), z: angle.y), angle: angle.angle))
        }
        
    }
    
    override func loadView() {
        view = setAngleView
    }
    
    // MARK: - Setup Methods
    private func setupNavigationBar() {
        navigationController?.navigationBar.tintColor = .label
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
    
}

// MARK: - SetAngleViewDelegate
extension SetAngleViewController: SetAngleViewDelegate {
    
    func infoButtonTapped() {
        if isToastVisible {
            dismissToast()
        } else {
            showToast()
        }
    }
    
    func chooseButtonTapped() {
        // Handle choose button action
        // Navigate to SelectDrawingViewController using the router
        router?.navigate(to: .selectDrawingViewController, animated: true)
    }
    
    func presetAngleButtonTapped() {
        // Handle preset angle button action
        print("Preset angle button tapped")
        
        // Here you could show a modal or sheet with preset options
        // For now, just print the action
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
        setAngleView.showToast()
        
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
        setAngleView.hideToast()
        isToastVisible = false
    }
}

#Preview {
    SetAngleViewController()
}
