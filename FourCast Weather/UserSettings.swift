//
//  UserSettings.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/04/2025.
//

import Foundation

struct UserSettingsModel: Codable {
    var temperatureUnitString: String
    var windSpeedUnitString: String
    
    var temperatureUnit: UnitTemperature {
        switch(temperatureUnitString) {
        case "celsius":
            return .celsius
        case "fahrenheit":
            return .fahrenheit
        default:
            return .kelvin
        }
    }
    
    var windSpeedUnit: UnitSpeed {
        switch(windSpeedUnitString) {
        case "km/h":
            return .kilometersPerHour
        case "mph":
            return .milesPerHour
        default:
            return .metersPerSecond
        }
    }
    
    init(tempUnit: UnitTemperature, speedUnit: UnitSpeed) {
        switch(tempUnit) {
        case .celsius: 
            temperatureUnitString = "celsius"
        case .fahrenheit:
            temperatureUnitString = "fahrenheit"
        default:
            temperatureUnitString = "kelvin"
        }
        
        switch(speedUnit) {
        case .kilometersPerHour:
            windSpeedUnitString = "km/h"
        case .milesPerHour:
            windSpeedUnitString = "mph"
        default:
            windSpeedUnitString = "m/s"
        }
    }
}

@Observable
class UserSettings {
    private let saveKey = "userSettings"
    
    var settings: UserSettingsModel {
        didSet {
            saveToUserDefaults()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(UserSettingsModel.self, from: data) {
                settings = decoded
                return
            }
        }
        
        let tempLocale = UnitTemperature(forLocale: .current, usage: .weather)
        let speedLocale = UnitSpeed(forLocale: .current, usage: .wind)
        
        settings = UserSettingsModel(tempUnit: tempLocale, speedUnit: speedLocale)
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
