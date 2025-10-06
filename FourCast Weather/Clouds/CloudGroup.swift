//
//  CloudGroup.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/06/2025.
//

import Foundation

class CloudGroup {
    var clouds: [Cloud] = []
    let opacity: Double
    var lastUpdate = Date.now
    
    init(thickness: Cloud.Thickness) {
        let cloudsToCreate: Int
        let cloudScale: ClosedRange<Double>
        
        switch thickness {
        case .none:
            cloudsToCreate = 0
            opacity = 1
            cloudScale = 1...1
            
        case .thin:
            cloudsToCreate = 10
            opacity = 0.6
            cloudScale = 0.4...0.6
            
        case .light:
            cloudsToCreate = 20
            opacity = 0.7
            cloudScale = 0.5...0.7
            
        case .regular:
            cloudsToCreate = 30
            opacity = 0.85
            cloudScale = 0.7...0.9
            
        case .thick:
            cloudsToCreate = 40
            opacity = 0.9
            cloudScale = 1.0...1.3
            
        case .ultraThick:
            cloudsToCreate = 50
            opacity = 1
            cloudScale = 1.2...1.6
        }
        
        for i in 0..<cloudsToCreate {
            let scale = Double.random(in: cloudScale)
            let imageNumber = i % 8
            
            let cloud = Cloud(imageNumber: imageNumber, scale: scale)
            clouds.append(cloud)
        }
    }
    
    func update(date: Date) {
        let delta = date.timeIntervalSince1970 - lastUpdate.timeIntervalSince1970
        
        for cloud in clouds {
            cloud.position.x -= delta * cloud.speed
            
            let offScreenDistance = max(400, 400 * cloud.scale)
            
            if cloud.position.x < -offScreenDistance {
                cloud.position.x = offScreenDistance
            }
        }
        
        lastUpdate = date
    }
}
