//
//  WeatherData.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 23/02/2025.
//

import SwiftUI

struct WeatherData: Codable, Equatable {
    let timezoneOffset: Int
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
    
    struct CurrentWeather: Codable, Equatable {
        let dt: Int
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        let uvi: Double
        let visibility: Int?
        let windSpeed: Double
        let windDeg: Int
        let windGust: Double?
        let weather: [WeatherCondition]
    }
    
    struct HourlyWeather: Codable, Equatable {
        let dt: Int
        let temp: Double
        let feelsLike: Double
        let pressure: Int
        let humidity: Int
        let uvi: Double
        let visibility: Int?
        let windSpeed: Double
        let windDeg: Int
        //    let windGust: Double?
        let weather: [WeatherCondition]
    }
    
    struct DailyWeather: Codable, Equatable {
        let dt: Int
        let sunrise: Int
        let sunset: Int
        let moonrise: Int
        let moonset: Int
        let moonPhase: Double
        let temp: DailyTemp
        let feelsLike: DailyFeelsLike
        let pressure: Int
        let humidity: Int
        let windSpeed: Double
        let windDeg: Int
        //    let windGust: Double?
        let weather: [WeatherCondition]
    }
    
    struct DailyTemp: Codable, Equatable {
        let day: Double
        let min: Double
        let max: Double
        let night: Double
        let eve: Double
        let morn: Double
    }
    
    struct DailyFeelsLike: Codable, Equatable {
        let day: Double
        let night: Double
        let eve: Double
        let morn: Double
    }
    
    struct WeatherCondition: Codable, Equatable {
//        let id: Int
//        let main: String
//        let description: String
        private let icon: String
        
        init(icon: String) {
            self.icon = icon
        }
    }
}

extension WeatherData.WeatherCondition {
    var isDaytime: Bool {
        icon.last == "d"
    }
    
    var condition: ConditionType {
        let weatherCode = String(icon.dropLast())
        
        return switch weatherCode {
        case "01": .clear(isDaytime: isDaytime)
        case "02": .fewClouds(isDaytime: isDaytime)
        case "03", "04": .clouds
        case "09": .drizzle
        case "10": .rain
        case "11": .thunderstorm
        case "13": .snow
        case "50": .haze(isDaytime: isDaytime)
        default: .clear(isDaytime: isDaytime)
        }
    }
    
    enum ConditionType: Codable, Hashable {
        case clear(isDaytime: Bool)
        case fewClouds(isDaytime: Bool)
        case clouds
        case drizzle
        case rain
        case thunderstorm
        case snow
        case haze(isDaytime: Bool)
        
        var iconName: String {
            switch self {
            case .clear(let isDaytime):
                isDaytime ? "sun.max.fill" : "moon.stars.fill"
            case .fewClouds(let isDaytime):
                isDaytime ? "cloud.sun.fill" : "cloud.moon.fill"
            case .clouds: "cloud.fill"
            case .drizzle: "cloud.drizzle.fill"
            case .rain: "cloud.rain.fill"
            case .thunderstorm: "cloud.bolt.fill"
            case .snow: "snowflake"
            case .haze(let isDaytime):
                isDaytime ? "sun.haze.fill" : "moon.haze.fill"
            }
        }
    }
}
