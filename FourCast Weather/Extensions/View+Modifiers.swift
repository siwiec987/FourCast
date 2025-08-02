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
    let addPadding: Bool
    
    var paddingAmount: CGFloat {
        addPadding ? 20 : 0
    }
    
    func body(content: Content) -> some View {
        content
            .padding(paddingAmount)
            .foregroundStyle(.white)
            .background(.clear.mix(with: .black, by: 0.2))
            .clipShape(.rect(cornerRadius: 20))
    }
}
