//
//  DrawSeed.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//

import CoreData

struct PresetData {
    let name: String
    let iconName: String
    let x: Float
    let y: Float
    let z: Float
    let angle: CGFloat
}

class InitialDataSeeder {
    static func seedDrawIfNeeded() {
        let context = CoreDataManager.shared.context
        
        let fetchRequest: NSFetchRequest<Draw> = Draw.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        guard count < 3 else {
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
            draw.draw_mode = "reference"

            CoreDataManager.shared.saveContext()
        
    }
    static func seedPresetAngle(){
        let context = CoreDataManager.shared.context
        let fetchRequest: NSFetchRequest<Angle> = Angle.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        
        guard count < 5 else {
            print("✅ Preset Angle already seeded.")
            return
        }
        print("Float.pi/2",Float.pi/2)
        let initialPresetData :[PresetData] = [
            PresetData(name: "Top", iconName: "preset_top", x: Float.pi/4, y: Float(0), z: Float(0), angle: 1.1),
            PresetData(name: "Side Left", iconName: "preset_side_left", x: Float(0), y: Float(0), z: Float(Float.pi/2), angle: 1.35),
            PresetData(name: "Quarter", iconName: "preset_quarter", x: Float(0), y: Float(0), z: Float(Float.pi/4), angle: 1.5707),
            PresetData(name: "Side Right", iconName: "preset_side_right", x: Float(0), y: Float(0), z: -1.5707963, angle: 1.8),
            PresetData(name: "Front", iconName: "preset_front", x: Float(0), y: Float(0), z: Float(0), angle: 2.05),
        ]
        
        for data in initialPresetData {
            let angle_id = UUID()
            let angle = Angle(context: context)
            angle.angle_id = angle_id
            angle.angle_name = data.name
            angle.x = data.x
            angle.y = data.y
            angle.z = data.z
            angle.is_preset = true
            angle.icon_name = data.iconName
            angle.angle = data.angle
            
            CoreDataManager.shared.saveContext()
        }
        
    }
}
