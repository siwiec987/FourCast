//
//  UnitFormatter.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 04/09/2025.
//

import Foundation

struct UnitFormatter {
    static func getFormattedTemperature(_ temperature: Double, to newUnit: UnitTemperature) -> String {
        let measurement = Measurement(value: temperature, unit: WeatherService.Units.temperature)
        let rounded = measurement.converted(to: newUnit).value.rounded()
        
        return Measurement(value: rounded, unit: newUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, hidesScaleName: true))
    }
    
    static func getFormattedWindSpeed(_ speed: Double, to newUnit: UnitSpeed) -> String {
        let measurement = Measurement(value: speed, unit: WeatherService.Units.windSpeed)
        let rounded = measurement.converted(to: newUnit).value.rounded()
        
        return Measurement(value: rounded, unit: newUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
    
    static func getFormattedPressure(_ pressure: Double, to newUnit: UnitPressure) -> String {
        let measurement = Measurement(value: pressure, unit: WeatherService.Units.pressure)
        let rounded = measurement.converted(to: newUnit).value.rounded()
        
        return Measurement(value: rounded, unit: newUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
    
    static func getFormattedDistance(_ distance: Double, to newUnit: UnitLength) -> String {
        let measurement = Measurement(value: distance, unit: WeatherService.Units.distance)
        let rounded = measurement.converted(to: newUnit).value.rounded()
        
        return Measurement(value: rounded, unit: newUnit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided))
    }
}
