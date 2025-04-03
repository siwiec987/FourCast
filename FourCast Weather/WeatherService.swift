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
    static let shared = WeatherService()
    
//    @Published public var weatherData: WeatherData?
    var isLoading = false
    
    private init() {}
    
    func fetchWeatherData(coordinate: CLLocationCoordinate2D, lastFetchTime: Date?) async throws  -> (WeatherData?, Date?) {
        if self.isLoading {
            throw OpenWeatherError.alreadyInUse
        }
        
           if let lastTime = lastFetchTime,
           Date().timeIntervalSince(lastTime) < 30 {
               throw OpenWeatherError.fetchNotNecessary
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let latitude = coordinate.latitude
            let longitude = coordinate.longitude
            let apiKey = "792cfab2b422b4dbd5795ced996a90b0"
//            let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(apiKey)"
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
//                weatherData = try decoder.decode(WeatherData.self, from: data)
//                lastFetchTime = Date.now
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
    
    static func getWeatherIcon(_ icon: String) -> String {
        switch(icon.last) {
        case "d":
            switch(icon) {
            case "01d":
                return "sun.max.fill"
            case "02d":
                return "cloud.sun.fill"
            case "03d", "04d":
                return "cloud.fill"
            case "09d":
                return "cloud.drizzle.fill"
            case "10d":
                return "cloud.sun.rain.fill"
            case "11d":
                return "cloud.bolt.fill"
            case "13d":
                return "snowflake"
            case "50d":
                return "sun.haze.fill"
            default:
                return "ellipsis"
            }
        case "n":
            switch(icon) {
            case "01n":
                return "moon.fill"
            case "02n":
                return "cloud.moon.fill"
            case "03n", "04n":
                return "cloud.fill"
            case "09n":
                return "cloud.drizzle.fill"
            case "10n":
                return "cloud.moon.rain.fill"
            case "11n":
                return "cloud.bolt.fill"
            case "13n":
                return "snowflake"
            case "50n":
                return "moon.haze.fill"
            default:
                return "ellipsis"
            }
        default:
            return "ellipsis"
        }
    }
    
    static func getConvertedTemperature(from temp: Double) -> Int {
        let userSettings = UserSettings.shared
        return Int(Measurement(value: temp, unit: UnitTemperature.kelvin).converted(to: userSettings.settings.temperatureUnit).value)
    }
}

enum OpenWeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
    case alreadyInUse
    case fetchNotNecessary
}
