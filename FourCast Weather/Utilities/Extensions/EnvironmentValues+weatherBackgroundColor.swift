//
//  EnvironmentValues+weatherBackgroundColor.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 11/09/2025.
//

import SwiftUI

extension EnvironmentValues {
    @Entry var weatherBackgroundTopColor: Color = .clear.mix(with: .black, by: 0.6)
    @Entry var weatherBackgroundBottomColor: Color = .clear.mix(with: .black, by: 0.2)
}
