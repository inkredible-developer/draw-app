//
//  Draw+CoreDataProperties.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//
//

import Foundation
import CoreData


extension Draw {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Draw> {
        return NSFetchRequest<Draw>(entityName: "Draw")
    }

    @NSManaged public var draw_id: UUID
    @NSManaged public var angle_id: UUID
    @NSManaged public var current_step: Int16
    @NSManaged public var similarity_score: Int16
    @NSManaged public var finished_image: String?
    @NSManaged public var is_finished: Bool

}

extension Draw : Identifiable {

}
