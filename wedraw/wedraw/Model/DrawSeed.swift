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
struct DrawingStep {
    let title: String
    let description: String
    let imageName: String
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
            PresetData(name: "Side Left", iconName: "preset_side_left", x: Float(0), y: Float(0), z: Float.pi/2, angle: 1.35),
            PresetData(name: "Quarter", iconName: "preset_quarter", x: Float(0), y: Float(0), z: Float.pi/4, angle: 1.5707),
            PresetData(name: "Side Right", iconName: "preset_side_right", x: Float(0), y: Float(0), z: -Float.pi/2, angle: 1.8),
            PresetData(name: "Front", iconName: "preset_front", x: Float(0), y: Float(0), z: Float(0), angle: 2.05),
            PresetData(name: "Top", iconName: "preset_top", x: Float.pi/4, y: Float(0), z: Float(0), angle: 1.1),

        ]
        
        var steps: [DrawingStep] = [
            DrawingStep(
                title: "Draw the Base Circle",
                description: "Start with a simple circle, this will be the skull base. Don’t worry about perfection; just aim for a clean round shape",
                imageName: "step1"
            ),
            DrawingStep(
                title: "Draw Guide for Side",
                description: "Draw vertical line for direction. Use center as anchor.",
                imageName: "step2"
            ),
            DrawingStep(
                title: "Split Face Horizontally",
                description: "Add eye and nose level.",
                imageName: "step3"
            ),
            DrawingStep(title: "Add Chin Box", description: "Sketch box to shape the chin.", imageName: "step4"),
            DrawingStep(title: "Draw Eye Line", description: "Mark horizontal eye level.", imageName: "step5"),
            DrawingStep(title: "Mark Nose Line", description: "Place nose at 1/3 down from eyes to chin.", imageName: "step6"),
            DrawingStep(title: "Define Jaw", description: "Sketch jaw shape to connect head and chin.", imageName: "step7"),
            DrawingStep(title: "Add Ear Level", description: "Align ear from eye to nose level.", imageName: "step8"),
            DrawingStep(title: "Draw Neck Guide", description: "Extend lines for neck from jaw.", imageName: "step9"),
            DrawingStep(title: "Draw A Line to Make A Nose", description: "Add guide lines for a nose\nTip: Nose (1/3 down from eye line to chin)", imageName: "step10")
        ]
        
        var imageNameSet : [String] = ["step1","step2","step3","step4","step5","step6","step7","step8","step9","step10"]
        
        for data in initialPresetData {
            print("🆕 Seeding \(data.name) x:\(data.x) y:\(data.y) z:\(data.z) angle:\(data.angle)")
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
            for i in 1..<11 {  
                let step_id = UUID()
                let steps = Step(context: context)
                steps.step_id = step_id
                steps.angle_id = angle_id
                steps.step_number = Int16(i)
                steps.image = "\(data.name)_step\(i)"
            }
        }
        
        CoreDataManager.shared.saveContext()
        
    }
}
