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
//    let coordinate: CLLocationCoordinate2D
    let coordinate: Coordinate
    var weatherData: WeatherData?
    var lastFetchTime: Date?
}

struct Coordinate: Codable {
    let latitude: Double
    let longitude: Double
    
    init(_ coordinate: CLLocationCoordinate2D) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
    }
    
    func getCoordinate() -> CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
}

@Observable
class AdditionalLocations {
    static let shared = AdditionalLocations()
    
    private let saveKey = "savedLocations"
    
    var locations: [AdditionalLocationData] = [] {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private init() {
        loadFromUserDefaults()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(locations) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
    
    private func loadFromUserDefaults() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode([AdditionalLocationData].self, from: data) {
                locations = decoded
                return
            }
        }
    }
}
