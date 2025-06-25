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
    
    func getFinishedDraws() -> [Draw] {
        return repository.fetchDraws(isFinished: true)
    }

    func getUnfinishedDraws() -> [Draw] {
        return repository.fetchDraws(isFinished: false)
    }

    func createDraw(draw_id: UUID, angle_id: UUID) {
        
        // You can put validation or extra logic here
        repository.insertDraw(
            draw_id: draw_id,
            angle_id: angle_id,
            current_step: 1,
            similarity_score: 0,
            finished_image: nil,
            is_finished: false,
            draw_mode: ""
        )
    }

    func removeDraw(_ draw: Draw) {
        repository.delete(draw: draw)
    }
}
