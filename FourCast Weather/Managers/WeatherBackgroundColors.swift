//
//  WeatherBackgroundColors.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 20/10/2025.
//

import SwiftUI

@Observable
class WeatherBackgroundColors {
    var topColor: Color = .clear.mix(with: .black, by: 0.6)
    var bottomColor: Color = .clear.mix(with: .black, by: 0.2)
}
