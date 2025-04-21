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
        case "°C":
            return .celsius
        case "°F":
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
}

@Observable
class UserSettings {
    static let shared = UserSettings()
    
    private let saveKey = "userSettings"
    
    var settings: UserSettingsModel {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(UserSettingsModel.self, from: data) {
                settings = decoded
                return
            }
        }
        
        let tempLocale = UnitTemperature.init(forLocale: .current)
        let speedLocale = UnitSpeed.init(forLocale: .current)
        
        let defaultTemperature = tempLocale == .celsius ? "°C" : tempLocale == .fahrenheit ? "°F" : "K"
        let defaultSpeed = speedLocale == .milesPerHour ? "mph" : "m/s"

        settings = UserSettingsModel(temperatureUnitString: defaultTemperature, windSpeedUnitString: defaultSpeed)
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
