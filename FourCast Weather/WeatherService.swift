//
//  WeatherService.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation

class WeatherService {
    static let shared = WeatherService()
    
    private init() {}
    
    static func getWeatherData() async throws -> WeatherData {
        let latitude = 50.3757787
        let longitude = 18.937873187224838
        let apiKey = "792cfab2b422b4dbd5795ced996a90b0"
        let urlString = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: urlString) else {
            throw OpenWeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw OpenWeatherError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherData.self, from: data)
        } catch {
            throw OpenWeatherError.invalidData
        }
        
    }
}

enum OpenWeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}
