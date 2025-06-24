//
//  DrawRepository.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//


import Foundation
import CoreData

class DrawRepository {
    private let context = CoreDataManager.shared.context
    let request: NSFetchRequest<Draw> = Draw.fetchRequest()

    func fetchAllDraws() -> [Draw] {
        
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchDraws(isFinished: Bool) -> [Draw] {
        print("isFinished",isFinished)
        let request: NSFetchRequest<Draw> = Draw.fetchRequest()
        request.predicate = NSPredicate(format: "is_finished == %@", NSNumber(value: isFinished))
        print(request)
        return (try? context.fetch(request)) ?? []
    }

    func insertDraw(draw_id: UUID, angle_id: UUID, current_step: Int, similarity_score: Int, finished_image: String?, is_finished: Bool) {
        let context = CoreDataManager.shared.context
        let draw = Draw(context: context)
        draw.draw_id = draw_id
        draw.angle_id = angle_id
        draw.current_step = Int16(current_step)
        draw.similarity_score = Int16(similarity_score)
        draw.finished_image = finished_image
        draw.is_finished = is_finished
        CoreDataManager.shared.saveContext()
    }

    func delete(draw: Draw) {
        let context = CoreDataManager.shared.context
        context.delete(draw)
        CoreDataManager.shared.saveContext()
    }
}
