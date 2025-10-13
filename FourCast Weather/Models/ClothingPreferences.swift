//
//  ClothingPreferences.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 06/10/2025.
//

import Foundation

struct ClothingPreferences: Codable {
    static let `default` = ClothingPreferences(
        temperatureOffset: Measurement(value: 0, unit: .celsius),
        clothingItems: [.tShirt, .sweater, .lightJacket, .winterJacket, .hatWinter, .hatCap, .gloves, .scarf, .umbrella, .sunglasses]
    )
    
    var temperatureOffset: Measurement<UnitTemperature>
    var clothingItems: Set<ClothingRecommender.ClothingItem>
}
