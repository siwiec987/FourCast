//
//  StormView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 26/07/2025.
//

import SwiftUI

struct StormView: View {
    let storm: Storm
    
    var body: some View {
        TimelineView(.animation) { timeline in
            Canvas { context, size in
                storm.update(date: timeline.date, size: size)
                
                for drop in storm.drops {
                    var contextCopy = context
                    
                    let xPos = drop.x * size.width
                    let yPos = drop.y * size.height
                    
                    contextCopy.opacity = drop.opacity
                    contextCopy.translateBy(x: xPos, y: yPos)
                    contextCopy.rotate(by: drop.direction + drop.rotation)
                    contextCopy.scaleBy(x: drop.xScale, y: drop.yScale)
                    contextCopy.draw(storm.image, at: .zero)
                }
            }
        }
        .ignoresSafeArea()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    init(type: Storm.Contents, direction: Angle, strength: Int) {
        storm = Storm(type: type, direction: direction, strength: strength)
    }
}

#Preview {
    StormView(type: .rain, direction: .zero, strength: 100)
}
