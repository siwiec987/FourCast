//
//  UserSettingsModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 06/10/2025.
//

import Foundation

struct UserSettingsModel: Codable {
    private var temperatureUnitString: String
    private var windSpeedUnitString: String
    private var pressureUnitString: String
    private var distanceUnitString: String
    
    var activityStartOffset: TimeInterval
    
    var clothingPreferences: ClothingPreferences
    
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
        tempUnit: UnitTemperature = .init(forLocale: .current, usage: .weather),
        speedUnit: UnitSpeed = .init(forLocale: .current, usage: .wind),
        pressureUnit: UnitPressure = .init(forLocale: .current, usage: .barometric),
        distanceUnit: UnitLength = .init(forLocale: .current, usage: .visibility),
        activityStartOffset: TimeInterval = 30 * 60,
        clothingPreferences: ClothingPreferences = .default
    ) {
        temperatureUnitString = tempUnit.symbol
        windSpeedUnitString = speedUnit.symbol
        pressureUnitString = pressureUnit.symbol
        distanceUnitString = distanceUnit.symbol
        self.activityStartOffset = activityStartOffset
        self.clothingPreferences = clothingPreferences
    }
}
