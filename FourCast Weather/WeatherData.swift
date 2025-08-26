//
//  WeatherData.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 23/02/2025.
//

struct WeatherData: Codable, Equatable {
    let timezoneOffset: Int
    let current: CurrentWeather
    let hourly: [HourlyWeather]
    let daily: [DailyWeather]
}

struct CurrentWeather: Codable, Equatable {
    let dt: Int
    let sunrise: Int
    let sunset: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double
    let clouds: Int
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
    let dewPoint: Double
    let uvi: Double
    let clouds: Int
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
    let summary: String
    let temp: DailyTemp
    let feelsLike: DailyFeelsLike
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
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
    let id: Int
    let main: String
    let description: String
    let icon: String
}
