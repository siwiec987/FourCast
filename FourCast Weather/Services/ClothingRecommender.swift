//
//  ClothingRecommender.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 17/09/2025.
//

import Foundation

struct ClothingRecommender {
    static func recommend(temperature: Double, weatherCondition: WeatherData.WeatherCondition, uvi: Double, preferences: ClothingPreferences) -> [ClothingItem] {
        let temp = Measurement(value: temperature, unit: WeatherService.Units.temperature).converted(to: .celsius)
        let rounded = (temp - preferences.temperatureOffset).converted(to: .celsius).value.rounded()
        let finalTemp = Measurement(value: rounded, unit: UnitTemperature.celsius)
        
        let isDaytime = weatherCondition.isDaytime
        let isRainy = weatherCondition.condition == .drizzle || weatherCondition.condition == .rain || weatherCondition.condition == .thunderstorm
        
        var result: Set<ClothingItem> = []
        
        for item in preferences.clothingItems {
            if let temperatureRange = item.temperatureRange, temperatureRange.contains(finalTemp) {
                result.insert(item)
            }
        }
        
        if isDaytime {
            if preferences.clothingItems.contains(.hatCap) && uvi >= 4 && !result.contains(.hatWinter) {
                result.insert(.hatCap)
            }
            
            if preferences.clothingItems.contains(.sunglasses) && uvi >= 3 {
                result.insert(.sunglasses)
            }
        }
        
        if isRainy {
            if preferences.clothingItems.contains(.umbrella) {
                result.insert(.umbrella)
            } else if !result.contains(where: { [.winterJacket, .coat].contains($0) }) {
                result.remove(.tShirt)
                result.remove(.sweater)
                
                result.insert(.lightJacket)
            }
        }

        return result.sorted { $0.rawValue < $1.rawValue }
    }
    
    enum ClothingItem: Int, CaseIterable, Codable, Identifiable {
        case tShirt = 1
        case sweater
        case lightJacket
        case winterJacket
        case coat
        
        case hatWinter
        case gloves
        case scarf
        
        case hatCap
        case sunglasses
        case umbrella
        
        var id: Self { self }
        
        var description: String {
            switch self {
            case .tShirt: "Lekki t-shirt"
            case .sweater: "Sweter lub bluza"
            case .lightJacket: "Lekka kurtka przejściowa"
            case .winterJacket: "Ciepła zimowa kurtka"
            case .coat: "Zimowy płaszcz"
                
            case .hatWinter: "Ciepła czapka zimowa"
            case .gloves: "Rękawiczki"
            case .scarf: "Szalik"
                
            case .hatCap: "Czapka z daszkiem"
            case .sunglasses: "Okulary przeciwsłoneczne"
            case .umbrella: "Parasol"
            }
        }
        
        var iconName: IconSource {
            switch self {
            case .tShirt: .system("tshirt.fill")
            case .sweater: .asset("crewneck.fill")
            case .lightJacket: .asset("jacket.light.fill")
            case .winterJacket: .system("jacket.fill")
            case .coat: .system("coat.fill")
                
            case .hatWinter: .asset("hat.winter.fill")
            case .gloves: .asset("gloves.fill")
            case .scarf: .asset("scarf.fill")
                
            case .hatCap: .system("hat.cap.fill")
            case .sunglasses: .system("sunglasses.fill")
            case .umbrella: .system("umbrella.fill")
            }
        }
        
        var temperatureRange: ClosedRange<Measurement<UnitTemperature>>? {
            let minTemp = -100
            let maxTemp = 100
            
            return switch self {
            case .tShirt: getCelsiusMeasurementClosedRange(min: 20, max: maxTemp)
            case .sweater: getCelsiusMeasurementClosedRange(min: 14, max: 19)
            case .lightJacket: getCelsiusMeasurementClosedRange(min: 8, max: 13)
            case .winterJacket: getCelsiusMeasurementClosedRange(min: minTemp, max: 7)
            case .coat: getCelsiusMeasurementClosedRange(min: minTemp, max: 7)
                
            case .hatWinter: getCelsiusMeasurementClosedRange(min: minTemp, max: 7)
            case .gloves: getCelsiusMeasurementClosedRange(min: minTemp, max: 3)
            case .scarf: getCelsiusMeasurementClosedRange(min: minTemp, max: 7)
                
            case .hatCap: nil
            case .sunglasses: nil
            case .umbrella: nil
            }
            
            func getCelsiusMeasurementClosedRange(min: Int, max: Int) -> ClosedRange<Measurement<UnitTemperature>> {
                Measurement(value: Double(min), unit: .celsius)...Measurement(value: Double(max), unit: .celsius)
            }
        }
        
        enum IconSource {
            case system(String)
            case asset(String)
        }
    }
}
