//
//  DrawSeed.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//

import CoreData

class InitialDataSeeder {
    static func seedDrawIfNeeded() {
        let context = CoreDataManager.shared.context

        // Check if a draw already exists
        let fetchRequest: NSFetchRequest<Draw> = Draw.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        guard count < 2 else {
            print("✅ Draw already seeded.")
            return
        }
            
            let draw_id = UUID()
            let angle_id = UUID()	
            // Create the draw
            let draw = Draw(context: context)
            draw.draw_id = draw_id
            draw.angle_id = angle_id
            draw.current_step = Int16.random(in: 0...7)
            draw.similarity_score = Int16.random(in: 0...100)
            draw.is_finished = false
            draw.finished_image = "draw_preview.jpg" // This can be a filename or base64 depending on your needs

            CoreDataManager.shared.saveContext()
        
        
//        print("✅ Seeded draw with angle '\(a  ngle.angleName ?? "")'")
    }
}
