//
//  Location.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 06/10/2025.
//

import CoreLocation
import Foundation

struct Location: Identifiable, Codable, Equatable {
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
