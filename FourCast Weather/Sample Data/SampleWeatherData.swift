//
//  SampleWeatherData.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 03/03/2025.
//

import Foundation
import OSLog

struct SampleWeatherData {
    var data: WeatherData?
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "SampleData")
    
    init() {
        guard let url = Bundle.main.url(forResource: "sampleWeatherData", withExtension: "json") else {
            logger.debug("Cannot find sampleData.json")
                return
            }
            
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .convertFromSnakeCase
                let result = try decoder.decode(WeatherData.self, from: data)
                self.data = result
            } catch {
                logger.debug("Error loading sample data: \(error)")
            }
    }
}
