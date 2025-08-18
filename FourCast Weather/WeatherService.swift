//
//  WeatherService.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation
import CoreLocation

@Observable
class WeatherService {
    var isLoading = false
    
    init() {}
    
    func fetchWeatherData(coordinate: CLLocationCoordinate2D) async throws  -> (WeatherData?, Date?) {
        if self.isLoading {
            throw OpenWeatherError.alreadyInUse
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude

            guard let apiKeyURL = Bundle.main.url(forResource: "OpenWeatherApiKey", withExtension: "txt") else {
                throw OpenWeatherError.keyNotFound
            }
                
            guard let apiKey = try? String(contentsOf: apiKeyURL, encoding: .utf8).trimmingCharacters(in: .whitespacesAndNewlines) else {
                throw OpenWeatherError.invalidKey
            }
            let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&appid=\(apiKey)"
            
            guard let url = URL(string: urlString) else {
                throw OpenWeatherError.invalidURL
            }
            
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw OpenWeatherError.invalidResponse
            }
            
            if let jsonString = String(data: data, encoding: .utf8) {
                print("Raw JSON response (first 200 chars): \(String(jsonString.prefix(200)))...")
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            let result = try decoder.decode(WeatherData.self, from: data)
            
            await MainActor.run {
                isLoading = false
            }
            
            return (data: result, fetchTime: Date.now)
            
        } catch {
            print("Decoding error: \(error)")
            if let decodingError = error as? DecodingError {
                switch decodingError {
                case .keyNotFound(let key, let context):
                    print("Key not found: \(key), context: \(context)")
                case .valueNotFound(let type, let context):
                    print("Value not found: \(type), context: \(context)")
                case .typeMismatch(let type, let context):
                    print("Type mismatch: \(type), context: \(context)")
                case .dataCorrupted(let context):
                    print("Data corrupted: \(context)")
                @unknown default:
                    print("Unknown decoding error")
                }
            }
            await MainActor.run {
                self.isLoading = false
            }
            
            throw OpenWeatherError.invalidData
        }
    }
    
    static func getWeatherIcon(_ icon: String?) -> String {
        let defaultIcon = "ellipsis"
        
        guard let icon else {return defaultIcon}
        
        switch(icon.last) {
        case "d":
            switch(icon.dropLast()) {
            case "01":
                return "sun.max.fill"
            case "02":
                return "cloud.sun.fill"
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
                return "sun.haze.fill"
            default:
                return defaultIcon
            }
        case "n":
            switch(icon.dropLast()) {
            case "01":
                return "moon.stars.fill"
            case "02":
                return "cloud.moon.fill"
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
                return "moon.haze.fill"
            default:
                return defaultIcon
            }
        default:
            return defaultIcon
        }
    }
    
    static func getConvertedTemperature(from temp: Double, userSettings: UserSettings) -> Int {
        return Int(Measurement(value: temp, unit: UnitTemperature.kelvin).converted(to: userSettings.settings.temperatureUnit).value)
    }
    
    static func getConvertedWindSpeed(from speed: Double, userSettings: UserSettings) -> Int {
        return Int(Measurement(value: speed, unit: UnitSpeed.metersPerSecond).converted(to: userSettings.settings.windSpeedUnit).value)
    }
}

enum OpenWeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case alreadyInUse
    case fetchNotNecessary
    case keyNotFound
    case invalidKey
}
