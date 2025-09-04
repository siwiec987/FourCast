//
//  WeatherIconMapper.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 04/09/2025.
//

import Foundation

struct WeatherIconMapper {
    private static let defaultIcon = "ellipsis"
    
    static func systemIcon(for apiIcon: String?) -> String {
        guard let icon = apiIcon else { return defaultIcon }
        
        let isDaytime = icon.last == "d"
        let weatherCode = String(icon.dropLast())
        
        switch weatherCode {
        case "01":
            return isDaytime ? "sun.max.fill" : "moon.stars.fill"
        case "02":
            return isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
        case "03", "04":
            return "cloud.fill"
        case "09":
            return "cloud.drizzle.fill"
        case "10":
            return "cloud.rain.fill"
        case "11":
            return "cloud.bolt.fill"
        case "13":
            return "snowflake"
        case "50":
            return isDaytime ? "sun.haze.fill" : "moon.haze.fill"
        default:
            return defaultIcon
        }
    }
}
