//
//  ClothingRecommender.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 17/09/2025.
//

import Foundation

struct ClothingRecommender {
    
    static func recommend(temp: Int, isWindy: Bool, isRainy: Bool, uv: Int, preferences: ClothingPreferences) -> [ClothingItem] {
        var result: [ClothingItem] = []
        result = []
        // logika
        
        return result
    }
    
    enum ClothingItem: CaseIterable, Codable {
        case tShirt
        case sweater
        case lightJacket
        //    case rainJacket
        case winterJacket
        case coat
        
        case hatWinter
        case hatCap
        case gloves
        case scarf
        case umbrella
        case sunglasses
        
        var iconName: IconSource {
            switch self {
            case .tShirt: .system("tshirt.fill")
            case .sweater: .asset("crewneck.fill")
            case .lightJacket: .asset("jacket.light.fill")
                //        case .rainJacket: ""
            case .winterJacket: .system("jacket.fill")
            case .coat: .system("coat.fill")
                
            case .hatWinter: .asset("hat.winter.fill")
            case .hatCap: .system("hat.cap.fill")
            case .gloves: .asset("gloves.fill")
            case .scarf: .asset("scarf.fill")
            case .umbrella: .system("umbrella.fill")
            case .sunglasses: .system("sunglasses.fill")
            }
        }
        
        var temperatureRange: ClosedRange<Measurement<UnitTemperature>> {
            let minTemp = -100
            let maxTemp = 100
            
            return switch self {
            case .tShirt: getCelsiusMeasurementClosedRange(min: 20, max: maxTemp)
            case .sweater: getCelsiusMeasurementClosedRange(min: 12, max: 20)
            case .lightJacket: getCelsiusMeasurementClosedRange(min: 8, max: 15)
            case .winterJacket: getCelsiusMeasurementClosedRange(min: minTemp, max: 8)
            case .coat: getCelsiusMeasurementClosedRange(min: minTemp, max: 8)
                
            case .hatWinter: getCelsiusMeasurementClosedRange(min: minTemp, max: 8)
            case .hatCap: getCelsiusMeasurementClosedRange(min: 15, max: maxTemp)
            case .gloves: getCelsiusMeasurementClosedRange(min: minTemp, max: 3)
            case .scarf: getCelsiusMeasurementClosedRange(min: minTemp, max: 8)
            case .umbrella: getCelsiusMeasurementClosedRange(min: minTemp, max: maxTemp)
            case .sunglasses: getCelsiusMeasurementClosedRange(min: minTemp, max: maxTemp)
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
