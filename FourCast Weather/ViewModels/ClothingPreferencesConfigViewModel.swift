//
//  ClothingPreferencesConfigViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/12/2025.
//

import Foundation

@MainActor @Observable
class ClothingPreferencesViewModel {
    var likesUmbrellas = true
    var likesCaps = true
    var likesSunglasses = true

    var likesWinterHats = true
    var likesGloves = true
    var likesScarves = true

    var winterOuterwear: ClothingRecommender.ClothingItem = .winterJacket
    var temperatureOffset = 0.0

    private let userSettings: UserSettings

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        load()
    }
    
    func load() {
        let preferences = userSettings.settings.clothingPreferences
        
        temperatureOffset = preferences.temperatureOffset.converted(to: .celsius).value
        print(temperatureOffset)
        
        likesUmbrellas = preferences.clothingItems.contains(.umbrella)
        likesCaps = preferences.clothingItems.contains(.hatCap)
        likesSunglasses = preferences.clothingItems.contains(.sunglasses)
        likesWinterHats = preferences.clothingItems.contains(.hatWinter)
        likesGloves = preferences.clothingItems.contains(.gloves)
        likesScarves = preferences.clothingItems.contains(.scarf)
        winterOuterwear = preferences.clothingItems.contains(.winterJacket) ? .winterJacket : .coat
    }

    func save() {
        var preferences = userSettings.settings.clothingPreferences

        preferences.likesUmbrellas(likesUmbrellas)
        preferences.likesCaps(likesCaps)
        preferences.likesSunglasses(likesSunglasses)
        preferences.likesWinterHats(likesWinterHats)
        preferences.likesGloves(likesGloves)
        preferences.likesScarves(likesScarves)
        preferences.winterOuterwearChoice(winterOuterwear)

        preferences.temperatureOffset = Measurement(value: temperatureOffset, unit: .celsius)

        userSettings.settings.clothingPreferences = preferences
        
        print("Preferences saved!")
    }
}
