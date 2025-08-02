//
//  Cloud.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/06/2025.
//

import Foundation

class Cloud {
    var position: CGPoint
    let imageNumber: Int
    let speed = Double.random(in: 4...12)
    let scale: Double
    
    init(imageNumber: Int, scale: Double) {
        self.imageNumber = imageNumber
        self.scale = scale
        
        let startX = Double.random(in: -200...400)
        let startY = Double.random(in: -50...350)
        position = CGPoint(x: startX, y: startY)
    }
    
    enum Thickness: CaseIterable {
        case none
        case thin
        case light
        case regular
        case thick
        case ultraThick
    }
}
