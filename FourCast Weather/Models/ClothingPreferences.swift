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
        clothingItems: [.tShirt, .sweater, .lightJacket, .winterJacket, .hatWinter, .gloves, .scarf, .hatCap, .sunglasses, .umbrella]
    )
    
    var temperatureOffset: Measurement<UnitTemperature>
    var clothingItems: Set<ClothingRecommender.ClothingItem>
    
    mutating func likesUmbrellas(_ isTrue: Bool) {
        isTrue ? addItem(.umbrella) : removeItem(.umbrella)
    }
    
    mutating func likesCaps(_ isTrue: Bool) {
        isTrue ? addItem(.hatCap) : removeItem(.hatCap)
    }
    
    mutating func likesSunglasses(_ isTrue: Bool) {
        isTrue ? addItem(.sunglasses) : removeItem(.sunglasses)
    }
    
    mutating func likesWinterHats(_ isTrue: Bool) {
        isTrue ? addItem(.hatWinter) : removeItem(.hatWinter)
    }
    
    mutating func likesGloves(_ isTrue: Bool) {
        isTrue ? addItem(.gloves) : removeItem(.gloves)
    }
    
    mutating func likesScarves(_ isTrue: Bool) {
        isTrue ? addItem(.scarf) : removeItem(.scarf)
    }
    
    mutating func winterOuterwearChoice(_ item: ClothingRecommender.ClothingItem) {
        if item == .coat {
            addItem(.coat)
            removeItem(.winterJacket)
        } else {
            addItem(.winterJacket)
            removeItem(.coat)
        }
    }
    
    private mutating func addItem(_ item: ClothingRecommender.ClothingItem) {
        clothingItems.insert(item)
    }
    
    private mutating func removeItem(_ item: ClothingRecommender.ClothingItem) {
        clothingItems.remove(item)
    }
}
