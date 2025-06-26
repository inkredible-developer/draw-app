//
//  StepRepository.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 25/06/25.
//

import Foundation
import CoreData

class StepRepository {
    private let context = CoreDataManager.shared.context
    let request: NSFetchRequest<Step> = Step.fetchRequest()

    func fetchAllDraws() -> [Step] {
        
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchStepsByAngleId(angle_id: UUID) -> [Step] {
        let request: NSFetchRequest<Step> = Step.fetchRequest()
        request.predicate = NSPredicate(format: "angle_id == %@", angle_id as CVarArg)
        request.sortDescriptors = [NSSortDescriptor(key: "step_number", ascending: true)]
        return (try? context.fetch(request)) ?? []
    }
    
    
    func insertStep(step_id: UUID?, angle_id: UUID?, step_number: Int16, image: String?) {
        let context = CoreDataManager.shared.context
        let step = Step(context: context)
        step.step_id = step_id
        step.angle_id = angle_id
        step.step_number = step_number
        step.image = image
        CoreDataManager.shared.saveContext()
    }
    

}
