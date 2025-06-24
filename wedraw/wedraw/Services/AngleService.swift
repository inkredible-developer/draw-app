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
    func getAngle(angle_id: UUID) -> [Angle] {
        return repository.getAngleById(id: angle_id)
    }
    func createAngle(angle_id: UUID, angle_name: String, x: Double, y: Double, z: Double, angle_value: Double) {
        
        // You can put validation or extra logic here
        repository.insertAngle(
            angle_id: angle_id, angle_name: angle_name, x: x, y: y, z: z, angle_value: angle_value
        )
    }

}
