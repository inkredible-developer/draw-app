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
        request.predicate = NSPredicate(format: "is_preset == %@", NSNumber(value: isPreset))
        request.sortDescriptors = [NSSortDescriptor(key: "angle_number", ascending: true)]

        return (try? context.fetch(request)) ?? []
    }
    func getAngleById(id: UUID) -> [Angle] {
        let request: NSFetchRequest<Angle> = Angle.fetchRequest()
        request.predicate = NSPredicate(format: "angle_id == %@", id as CVarArg)
        

        return (try? context.fetch(request)) ?? []
    }
    func getAngleByName(name: String) -> Angle? {
        let request: NSFetchRequest<Angle> = Angle.fetchRequest()
        request.predicate = NSPredicate(format: "angle_name == %@", name)
        request.fetchLimit = 1

        return try? context.fetch(request).first
    }

    func insertAngle(angle_id: UUID, angle_name: String,x:Float, y:Float, z:Float, angle_value: Double, angle_number: Int16 ) {
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
        angle.angle_number = angle_number
        CoreDataManager.shared.saveContext()
    }
}
