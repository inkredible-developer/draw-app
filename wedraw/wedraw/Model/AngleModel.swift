//
//  AngleModel.swift
//  wedraw
//
//  Created by Rudi Butarbutar on 24/06/25.
//


import Foundation
import SceneKit

// MARK: - Angle Model
struct AnglePreset {
    let name: String
    let iconName: String
    let rotationAngles: SCNVector3
    let angle: CGFloat
}

class AngleModel {
    static let shared = AngleModel()
    
    let cameraPresets: [AnglePreset] = [
        // Top view - looking down from above
        AnglePreset(name: "Top", iconName: "preset_top",
                   rotationAngles: SCNVector3(x: Float.pi/2, y: 0, z: 0), angle: 1.1),
        
        // Side Left - 3/4 view from left
        AnglePreset(name: "Side Left", iconName: "preset_side_left",
                   rotationAngles: SCNVector3(x: 0.3, y: Float.pi/2, z: 0), angle: 1.35),
        
        // Quarter - 3/4 view from right
        AnglePreset(name: "Quarter", iconName: "preset_quarter",
                   rotationAngles: SCNVector3(x: 0.3, y: -Float.pi/4, z: 0), angle: 1.5707),
        
        // Side Right - 3/4 view from right side
        AnglePreset(name: "Side Right", iconName: "preset_side_right",
                   rotationAngles: SCNVector3(x: 0.3, y: -Float.pi/2, z: 0), angle: 1.8),
        
        // Front - straight on view
        AnglePreset(name: "Front", iconName: "preset_front",
                   rotationAngles: SCNVector3(x: 0, y: 0, z: 0), angle: 2.05)
    ]
    
    var selectedPresetIndex: Int = 2 // Default to quarter view
    var currentRotationAngles: SCNVector3 = SCNVector3(x: 0.3, y: -Float.pi/4, z: 0)
    
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
