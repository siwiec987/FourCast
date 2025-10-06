//
//  ClothingPreferences.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 06/10/2025.
//

import Foundation

struct ClothingPreferences: Codable {
    static let `default` = ClothingPreferences(
        temperatureOffset: 0,
        clothingItems: [.tShirt, .sweater, .lightJacket, .winterJacket, .hatWinter, .hatCap, .gloves, .scarf, .umbrella, .sunglasses]
    )
    
    var temperatureOffset: Int
    var clothingItems: [ClothingRecommender.ClothingItem]
}
