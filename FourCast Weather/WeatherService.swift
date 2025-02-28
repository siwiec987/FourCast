//
//  WeatherService.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation
import CoreLocation

class WeatherService: ObservableObject {
    static let shared = WeatherService()
    
    @Published public var weatherData: WeatherData?
    @Published private var isLoading = false
    
    private var lastFetchTime: Date?
    private var lastFetchLocation: CLLocation?
    
    private init() {}
    
    func fetchWeatherData(location: CLLocation) async throws {
        if self.isLoading {
            return
        }
        
        if let lastLocation = self.lastFetchLocation,
           let lastTime = self.lastFetchTime,
           location.distance(from: lastLocation) < 1000 &&
           Date().timeIntervalSince(lastTime) < 30 {
            if self.weatherData != nil {
                return
            }
        }
        
        await MainActor.run {
            self.isLoading = true
        }
        
        do {
            let latitude = location.coordinate.latitude
            let longitude = location.coordinate.longitude
            let apiKey = "792cfab2b422b4dbd5795ced996a90b0"
            let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(apiKey)"
            
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
            
            try await MainActor.run {
                weatherData = try decoder.decode(WeatherData.self, from: data)
                lastFetchTime = Date.now
                lastFetchLocation = location
                isLoading = false
            }
            
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
            throw OpenWeatherError.invalidData
        }
        
        await MainActor.run {
            self.isLoading = false
        }
    }
    
    func clearCache() {
        weatherData = nil
        lastFetchTime = nil
    }
}

enum OpenWeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
