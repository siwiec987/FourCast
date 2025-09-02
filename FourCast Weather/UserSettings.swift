//
//  UserSettings.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/04/2025.
//

import Foundation

struct UserSettingsModel: Codable {
    private var temperatureUnitString: String
    private var windSpeedUnitString: String
    private var pressureUnitString: String
    private var distanceUnitString: String
    
    var activityStartOffset: TimeInterval
    
    var temperatureUnit: UnitTemperature {
        get {
            switch(temperatureUnitString) {
            case UnitTemperature.celsius.symbol:
                return .celsius
            case UnitTemperature.fahrenheit.symbol:
                return .fahrenheit
            default:
                return .kelvin
            }
        }
        
        set {
            temperatureUnitString = newValue.symbol
        }
    }
    
    var windSpeedUnit: UnitSpeed {
        get {
            switch(windSpeedUnitString) {
            case UnitSpeed.kilometersPerHour.symbol:
                return .kilometersPerHour
            case UnitSpeed.milesPerHour.symbol:
                return .milesPerHour
            case UnitSpeed.knots.symbol:
                return .knots
            default:
                return .metersPerSecond
            }
        }
        
        set {
            windSpeedUnitString = newValue.symbol
        }
    }
    
    var pressureUnit: UnitPressure {
        get {
            switch(pressureUnitString) {
            case UnitPressure.millibars.symbol:
                return .millibars
            case UnitPressure.inchesOfMercury.symbol:
                return .inchesOfMercury
            case UnitPressure.millimetersOfMercury.symbol:
                return .millimetersOfMercury
            case UnitPressure.hectopascals.symbol:
                return .hectopascals
            default:
                return .kilopascals
            }
        }
        
        set {
            pressureUnitString = newValue.symbol
        }
    }
    
    var distanceUnit: UnitLength {
        get {
            switch(distanceUnitString) {
            case UnitLength.miles.symbol:
                return .miles
            default:
                return .kilometers
            }
        }
        
        set {
            distanceUnitString = newValue.symbol
        }
    }
    
    init(
        activityStartOffset: TimeInterval = 15 * 60,
        tempUnit: UnitTemperature = .init(forLocale: .current, usage: .weather),
        speedUnit: UnitSpeed = .init(forLocale: .current, usage: .wind),
        pressureUnit: UnitPressure = .init(forLocale: .current, usage: .barometric),
        distanceUnit: UnitLength = .init(forLocale: .current, usage: .visibility)
    ) {
        self.activityStartOffset = activityStartOffset
        temperatureUnitString = tempUnit.symbol
        windSpeedUnitString = speedUnit.symbol
        pressureUnitString = pressureUnit.symbol
        distanceUnitString = distanceUnit.symbol
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
        
        settings = UserSettingsModel()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
