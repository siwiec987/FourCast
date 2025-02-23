//
//  WeatherData.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 23/02/2025.
//

struct WeatherData: Codable {
    let current: CurrentWeather
//    let hourly: [HourlyWeather]
//    let daily: [DailyWeather]
}

struct CurrentWeather: Codable {
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
    let visibility: Int
    let windSpeed: Double
    let windDeg: Int
//    let windGust: Double?
    let weather: [WeatherCondition]
}

struct HourlyWeather: Codable {
    let dt: Int
    let temp: Double
    let feelsLike: Double
    let pressure: Int
    let humidity: Int
    let dewPoint: Double
    let uvi: Double
    let clouds: Int
    let visibility: Int
    let windSpeed: Double
    let windDeg: Int
//    let windGust: Double?
    let weather: [WeatherCondition]
}

struct DailyWeather: Codable {
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

struct DailyTemp: Codable {
    let day: Double
    let min: Double
    let max: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct DailyFeelsLike: Codable {
    let day: Double
    let night: Double
    let eve: Double
    let morn: Double
}

struct WeatherCondition: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}
