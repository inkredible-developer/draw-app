//
//  Step+CoreDataProperties.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 25/06/25.
//
//

import Foundation
import CoreData


extension Step {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Step> {
        return NSFetchRequest<Step>(entityName: "Step")
    }

    @NSManaged public var step_id: UUID?
    @NSManaged public var angle_id: UUID?
    @NSManaged public var step_number: Int16
    @NSManaged public var image: String?

}

extension Step : Identifiable {

}
