//
//  DrawService.swift
//  wedraw
//
//  Created by M. Evan Cendekia Suryandaru on 24/06/25.
//


import Foundation

class DrawService {
    private let repository = DrawRepository()

    func getDraws() -> [Draw] {
        return repository.fetchAllDraws()
    }
    
    func getFinishedDraws() -> [DrawWithAngle] {
        return repository.fetchDraws(isFinished: true)
    }

    func getUnfinishedDraws() -> [DrawWithAngle] {
        return repository.fetchDraws(isFinished: false)
    }
    func getDrawById(draw_id: UUID) -> [Draw] {
        return repository.getDrawById(id: draw_id)
    }
    
    func updateDrawStep(draw: Draw, draw_step: Int) -> Bool{
        print("draw_step",draw_step)
        return repository.updateDrawStep(draw: draw, draw_step: draw_step)
    }
    
    func setFinishedDraw(draw_id: UUID, similarity_score: Int, finished_image: String){
        return repository.updateFinishedStatus(draw_id: draw_id, similarity_score: similarity_score, finishedImage: finished_image)
    }


    func createDraw(draw_id: UUID, angle_id: UUID, draw_mode: String) {
        print("draw_id",draw_id)
        print("create draw")
        // You can put validation or extra logic here
        repository.insertDraw(
            draw_id: draw_id,
            angle_id: angle_id,
            current_step: 1,
            similarity_score: 0,
            finished_image: nil,
            is_finished: false,
            draw_mode: draw_mode
        )
    }

    func removeDraw(_ draw: Draw) {
        repository.delete(draw: draw)
    }
    
}
