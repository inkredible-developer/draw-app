//
//  Angle+CoreDataProperties.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 25/06/25.
//
//

import Foundation
import CoreData


extension Angle {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Angle> {
        return NSFetchRequest<Angle>(entityName: "Angle")
    }

    @NSManaged public var angle: Double
    @NSManaged public var angle_id: UUID?
    @NSManaged public var angle_name: String?
    @NSManaged public var icon_name: String?
    @NSManaged public var is_preset: Bool
    @NSManaged public var x: Float
    @NSManaged public var y: Float
    @NSManaged public var z: Float

}

extension Angle : Identifiable {

}
