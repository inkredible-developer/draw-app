//
//  SetAngleViewController.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 22/06/25.
//

import UIKit
import SceneKit

class SetAngleViewController: UIViewController {

    // Router for navigation
    var router: MainFlowRouter?

    // MARK: - Properties
    private let setAngleView = SetAngleView()
    private let angleModel = AngleModel.shared
    private var isToastVisible = false
    private var dismissWorkItem: DispatchWorkItem?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Select Your Angle"
        setupNavigationBar()
        setupView()
        setupInitialState()
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
        let selectedPreset = angleModel.getSelectedPreset()
        setAngleView.updateAngleLabel(selectedPreset.name)
        setAngleView.updatePresetButtonSelection(selectedIndex: angleModel.selectedPresetIndex)
        
        // Set initial rotation of the 3D model to the default preset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.rotateModel(to: selectedPreset.rotationAngles)
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
        angleModel.updateSelectedPreset(index)
        
        // Update the view to reflect the selection
        let selectedPreset = angleModel.getSelectedPreset()
        setAngleView.updateAngleLabel(selectedPreset.name)
        setAngleView.updatePresetButtonSelection(selectedIndex: index)
        
        // Rotate the 3D model to the new angle
        rotateModel(to: selectedPreset.rotationAngles)
        
        print("Preset button tapped: \(selectedPreset.name)")
    }
    
    func cameraPositionChanged(_ position: SCNVector3) {
        // Update the model with the new rotation angles
        angleModel.updateRotationAngles(position)
        
        // Determine the angle name based on the new rotation
        let angleName = angleModel.getAngleName(for: position)
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
        let presets = angleModel.cameraPresets
        
        for (index, preset) in presets.enumerated() {
            let distance = sqrt(
                pow(angles.x - preset.rotationAngles.x, 2) +
                pow(angles.y - preset.rotationAngles.y, 2) +
                pow(angles.z - preset.rotationAngles.z, 2)
            )
            
            // If we're close enough to a preset, update the selection
            if distance < 0.3 {
                if index != angleModel.selectedPresetIndex {
                    angleModel.updateSelectedPreset(index)
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
