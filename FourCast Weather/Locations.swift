//
//  Locations.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/03/2025.
//

import Foundation
import CoreLocation

struct Location: Identifiable, Codable {
    private var latitude: Double
    private var longitude: Double
    
    var id = UUID()
    
    var name: String
    var coordinate: CLLocationCoordinate2D {  //CLLocationCoordinate2D nie jest Codable i trzeba było kombinować
        get {
            CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        set {
            latitude = newValue.latitude
            longitude = newValue.longitude
        }
    }
    
    let role: Role
    var weatherData: WeatherData?
    var lastFetchTime: Date?
    
    init(id: UUID = UUID(), name: String, coordinate: CLLocationCoordinate2D, role: Role, weatherData: WeatherData? = nil, lastFetchTime: Date? = nil) {
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        
        self.id = id
        self.name = name
        self.role = role
        self.weatherData = weatherData
        self.lastFetchTime = lastFetchTime
    }
    
    enum Role: Codable {
        case calendarEvent
        case current
        case additional
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
        
        if let encoded = try? JSONEncoder().encode(locations) {
            try? encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
        }
    }
    
    private func loadFromJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([Location].self, from: data) {
//                locations.append(contentsOf: decoded)
                locations = decoded
            }
        }
    }
}
