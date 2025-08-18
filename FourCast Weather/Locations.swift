//
//  Locations.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/03/2025.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable {
    var id = UUID()
    
    var name: String
    var coordinate: Coordinate //CLLocationCoordinate2D nie jest Codable i trzeba było kombinować
    let role: Role
    var weatherData: WeatherData?
    var lastFetchTime: Date?
    
    var coordinateObject: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: coordinate.latitude, longitude: coordinate.longitude)
    }
    
    enum Role: Codable {
        case calendarEvent
        case current
        case additional
    }
    
    struct Coordinate: Codable {
        let latitude: Double
        let longitude: Double
        
        init(_ coordinate: CLLocationCoordinate2D) {
            self.latitude = coordinate.latitude
            self.longitude = coordinate.longitude
        }
    }
}


@Observable
class Locations {
    private let filePath = "locations"
    
    var locations: [Location] = [] {
        didSet {
            saveToJSON()
        }
    }
    
    private var additionalLocations: [Location] {
        locations.filter { $0.role == .additional }
    }
    
    init() {
        loadFromJSON()
    }
    
    private func saveToJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let encoded = try? JSONEncoder().encode(additionalLocations) {
            try? encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
        }
    }
    
    private func loadFromJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([Location].self, from: data) {
                locations.append(contentsOf: decoded)
            }
        }
    }
}
