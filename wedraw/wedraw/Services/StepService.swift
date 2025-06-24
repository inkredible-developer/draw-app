//
//  StepService.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 25/06/25.
//

import Foundation

class StepService {
    
    private let repository = StepRepository()
    
    func getSteps(angle_id: UUID) -> [Step] {
        return repository.fetchStepsByAngleId(angle_id: angle_id)
    }
    

    func insertStep(step_id: UUID, angle_id: UUID, step_number: Int16, image: String) {
        repository.insertStep(step_id: step_id, angle_id: angle_id, step_number: step_number, image: image)
    }

}
