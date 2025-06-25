//
//  AngleRepository.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 25/06/25.
//


import Foundation
import CoreData

class AngleRepository {
    private let context = CoreDataManager.shared.context
    let request: NSFetchRequest<Angle> = Angle.fetchRequest()

    func fetchAllDraws() -> [Angle] {
        
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchAngleByPreset(isPreset: Bool) -> [Angle] {
        let request: NSFetchRequest<Angle> = Angle.fetchRequest()
        request.predicate = NSPredicate(format: "is_preset == %@", NSNumber(value: true))

        return (try? context.fetch(request)) ?? []
    }
    func getAngleById(id: UUID) -> [Angle] {
        let request: NSFetchRequest<Angle> = Angle.fetchRequest()
        request.predicate = NSPredicate(format: "angle_id == %@", id as CVarArg)

        return (try? context.fetch(request)) ?? []
    }

    func insertAngle(angle_id: UUID, angle_name: String,x:Double, y:Double, z:Double, angle_value: Double ) {
        let context = CoreDataManager.shared.context
        let angle = Angle(context: context)
        angle.angle_id = angle_id
        angle.angle_name = angle_name
        angle.x = x
        angle.y = y
        angle.z = z
        angle.angle = angle_value
        angle.is_preset = false
        angle.icon_name = ""
        CoreDataManager.shared.saveContext()
    }
}
