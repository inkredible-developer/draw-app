//
//  DrawRepository.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//


import Foundation
import CoreData

struct DrawWithAngle {
    let draw: Draw
    let angle: Angle
}

class DrawRepository {
    private let context = CoreDataManager.shared.context
    let request: NSFetchRequest<Draw> = Draw.fetchRequest()

    func fetchAllDraws() -> [Draw] {
        
        return (try? context.fetch(request)) ?? []
    }
    
    func fetchDraws(isFinished: Bool) -> [DrawWithAngle] {
        let request: NSFetchRequest<Draw> = Draw.fetchRequest()
        let angleRequest: NSFetchRequest<Angle> = Angle.fetchRequest()
        
        request.predicate = NSPredicate(format: "is_finished == %@", NSNumber(value: isFinished))
        guard
               let draws = try? context.fetch(request),
               let angles = try? context.fetch(angleRequest)
           else {
               return []
           }
        
        let angleDict = Dictionary(uniqueKeysWithValues: angles.map { ($0.angle_id, $0) })
        var mergedResults: [DrawWithAngle] = []
        for draw in draws {
            if let matchingAngle = angleDict[draw.angle_id] {
                mergedResults.append(DrawWithAngle(draw: draw, angle: matchingAngle))
            }
        }

        return mergedResults
    }
    
    func getDrawById(id: UUID) -> [Draw] {
        let request: NSFetchRequest<Draw> = Draw.fetchRequest()
        request.predicate = NSPredicate(format: "draw_id == %@", id as CVarArg)

        return (try? context.fetch(request)) ?? []
    }
    
    func updateDrawStep(draw: Draw, draw_step: Int) -> Bool{
        draw.current_step = Int16(draw_step)
        
        return (try? context.save()) != nil
    }

    func insertDraw(draw_id: UUID, angle_id: UUID, current_step: Int, similarity_score: Int, finished_image: String?, is_finished: Bool, draw_mode: String?) {
        print("insert in repo")
        let context = CoreDataManager.shared.context
        let draw = Draw(context: context)
        draw.draw_id = draw_id
        draw.angle_id = angle_id
        draw.current_step = Int16(current_step)
        draw.similarity_score = Int16(similarity_score)
        draw.finished_image = finished_image
        draw.is_finished = is_finished
        draw.draw_mode = draw_mode
        CoreDataManager.shared.saveContext()
    }
    
    func updateCurrentStep(draw_id: UUID, to newStep: Int) {
        let request: NSFetchRequest<Draw> = Draw.fetchRequest()
        request.predicate = NSPredicate(format: "draw_id == %@", draw_id as CVarArg)
        request.fetchLimit = 1

        do {
            if let draw = try context.fetch(request).first {
                draw.current_step = Int16(newStep)
                CoreDataManager.shared.saveContext()
            } else {
                print("❌ Draw with id \(draw_id) not found.")
            }
        } catch {
            print("❌ Failed to update current_step for Draw with id \(draw_id): \(error)")
        }
    }
    
    func updateFinishedStatus(draw_id: UUID, isFinished: Bool, finishedImage: String?) {
        let request: NSFetchRequest<Draw> = Draw.fetchRequest()
        request.predicate = NSPredicate(format: "draw_id == %@", draw_id as CVarArg)
        request.fetchLimit = 1

        do {
            if let draw = try context.fetch(request).first {
                draw.is_finished = isFinished
                draw.finished_image = finishedImage
                CoreDataManager.shared.saveContext()
            } else {
                print("❌ Draw with id \(draw_id) not found.")
            }
        } catch {
            print("❌ Failed to update finished status: \(error)")
        }
    }
    func delete(draw: Draw) {
        let context = CoreDataManager.shared.context
        context.delete(draw)
        CoreDataManager.shared.saveContext()
    }
}
