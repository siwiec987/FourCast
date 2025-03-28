//
//  AdditionalLocationData.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/03/2025.
//

import Foundation
import CoreLocation

struct AdditionalLocationData: Codable {
    let name: String
    let coordinate: Coordinate //CLLocationCoordinate2D nie jest Codable i trzeba było kombinować
    var weatherData: WeatherData?
    var lastFetchTime: Date?
    
    var coordinateObject: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
}

@Observable
class AdditionalLocations {
    static let shared = AdditionalLocations()
    
    private let filePath = "locations"
    
    var locations: [AdditionalLocationData] = [] {
        didSet {
            saveToJSON()
        }
    }
    
    private init() {
        loadFromJSON()
    }
    
    private func saveToJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let encoded = try? JSONEncoder().encode(locations) {
            try? encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
        }
    }
    
    private func loadFromJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([AdditionalLocationData].self, from: data) {
                locations = decoded
            }
        }
    }
}
