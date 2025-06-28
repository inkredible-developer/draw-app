//
//  AngleService.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 25/06/25.
//

import Foundation

class AngleService {
    
    private let repository = AngleRepository()
    
    func getPresetAngle() -> [Angle] {
        return repository.fetchAngleByPreset(isPreset: true)
    }
    func getNonPresetAngle() -> [Angle] {
        return repository.fetchAngleByPreset(isPreset: false)
    }
    func getAngle(angle_id: UUID) -> [Angle] {
        return repository.getAngleById(id: angle_id)
    }
    func getAngleByName(angle_name: String) -> Angle? {
        return repository.getAngleByName(name: angle_name)
    }
    func createAngle(angle_id: UUID, angle_name: String, x: Float, y: Float, z: Float, angle_value: Double, angle_number: Int16) {
        
        // You can put validation or extra logic here
        repository.insertAngle(
            angle_id: angle_id, angle_name: angle_name, x: x, y: y, z: z, angle_value: angle_value, angle_number: angle_number
        )
    }

}
