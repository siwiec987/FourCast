//
//  View+Modifiers.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/08/2025.
//

import SwiftUI

extension View {
    func weatherComponent(addPadding: Bool = true) -> some View {
        modifier(WeatherComponent(addPadding: addPadding))
    }
}

struct WeatherComponent: ViewModifier {
    @Environment(\.weatherBackgroundBottomColor) private var weatherBackgroundColor
    
    let addPadding: Bool
    var paddingAmount: CGFloat {
        addPadding ? 20 : 0
    }
    
    func body(content: Content) -> some View {
        content
            .padding(paddingAmount)
            .foregroundStyle(.white)
            .background(
                weatherBackgroundColor
                    .opacity(0.8)
                    .animation(.default, value: weatherBackgroundColor)
            )
            .clipShape(.rect(cornerRadius: 20))
    }
}
