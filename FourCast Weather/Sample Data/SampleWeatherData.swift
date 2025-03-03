//
// SampleWeatherData.swift
// FourCast Weather
//

import Foundation

struct SampleWeatherData {
    var data: WeatherData?
    
    init() {
        guard let url = Bundle.main.url(forResource: "sampleWeatherData", withExtension: "json") else {
                print("Cannot find sampleData.json")
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(WeatherData.self, from: data)
                self.data = result
            } catch {
                print("Error loading sample data: \(error)")
            }
    }
}
