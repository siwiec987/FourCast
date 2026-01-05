//
//  ClothingRecommenderTests.swift
//  FourCast WeatherTests
//
//  Created by Jakub Siwiec on 05/01/2026.
//

import Foundation
import Testing

@testable import FourCast_Weather

struct ClothingRecommenderTests {
    let allItems = ClothingRecommender.ClothingItem.allCases

    func makePreferences(clothingItems: [ClothingRecommender.ClothingItem]? = nil, offset: Double = 0) -> ClothingPreferences {
        ClothingPreferences(
            temperatureOffset: Measurement(value: offset, unit: .celsius),
            clothingItems: Set(clothingItems ?? allItems)
        )
    }

    let clearSkyDay = WeatherData.WeatherCondition(icon: "01d")
    let clearSkyNight = WeatherData.WeatherCondition(icon: "01n")
    let rainDay = WeatherData.WeatherCondition(icon: "10d") // deszcz

    func check(_ temperature: Double, uvi: Double = 0, condition: WeatherData.WeatherCondition, preferences: ClothingPreferences, expected: [ClothingRecommender.ClothingItem]) {
        let tempKelvin = Measurement(value: temperature, unit: UnitTemperature.celsius).converted(to: .kelvin).value
        let result = ClothingRecommender.recommend(temperature: tempKelvin, weatherCondition: condition, uvi: uvi, preferences: preferences)
        for item in expected {
            #expect(result.contains(item))
        }
    }

    @Test func temperatureBasedClothing() {
        let prefs = makePreferences()
        check(25, condition: clearSkyDay, preferences: prefs, expected: [.tShirt])
        check(17, condition: clearSkyDay, preferences: prefs, expected: [.sweater])
        check(10, condition: clearSkyDay, preferences: prefs, expected: [.lightJacket])
        check(0,  condition: clearSkyDay, preferences: prefs, expected: [.winterJacket])
    }

    @Test func uviBasedAccessories() {
        let prefs = makePreferences()
        check(25, uvi: 5, condition: clearSkyDay, preferences: prefs, expected: [.hatCap])
        check(20, uvi: 3, condition: clearSkyDay, preferences: prefs, expected: [.sunglasses])
        check(25, uvi: 5, condition: clearSkyNight, preferences: prefs, expected: [])
    }

    @Test func rainConditions() {
        let prefs = makePreferences()
        // parasol powinien pojawić się tylko jeśli jest w preferencjach
        check(20, condition: rainDay, preferences: prefs, expected: [.umbrella])
        
        // brak parasola w preferencjach → lightJacket zamiast tShirt
        let prefsNoUmbrella = makePreferences(clothingItems: allItems.filter { $0 != .umbrella })
        check(20, condition: rainDay, preferences: prefsNoUmbrella, expected: [.lightJacket])
    }

    @Test func temperatureOffset() {
        let prefs = makePreferences(offset: 5)
        check(20, condition: clearSkyDay, preferences: prefs, expected: [.sweater])
    }

    @Test func missingItemsInPreferences() {
        let prefs = makePreferences(clothingItems: allItems.filter { ![.hatCap, .sunglasses].contains($0) })
        check(25, uvi: 5, condition: clearSkyDay, preferences: prefs, expected: [])
    }
}
