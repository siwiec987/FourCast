//
//  AdditionalLocationData.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/03/2025.
//

import Foundation
import CoreLocation

struct AdditionalLocationData {
    var name: String
    var coordinate: CLLocationCoordinate2D
    var weatherData: WeatherData?
    var lastFetchTime: Date?
}

@Observable
class AdditionalLocations {
    static let shared = AdditionalLocations()
    
    var locations: [AdditionalLocationData] = []
    
    private init() {}
}
