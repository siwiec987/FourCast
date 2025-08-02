//
//  StarField.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/07/2025.
//

import Foundation

class StarField {
    var stars: [Star] = []
    let leftEdge = -50.0
    let rightEdge = 500.0
    var lastUpdate = Date.now
    
    init() {
        for _ in 1...200 {
            let x = Double.random(in: leftEdge...rightEdge)
            let y = Double.random(in: 0...800)
            let size = Double.random(in: 1...3)
            let star = Star(x: x, y: y, size: size)
            stars.append(star)
        }
    }
    
    func update(date: Date) {
        let delta = date.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970
        
        for star in stars {
            star.x -= delta * 1.5
            
            if star.x < leftEdge {
                star.x = rightEdge
            }
        }
        
        lastUpdate = date
    }
}
