//
//  SearchLocationViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/12/2025.
//

import Foundation
import OSLog

@MainActor @Observable
class SearchLocationViewModel {
    @ObservationIgnored private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "SearchLocationVM")
    @ObservationIgnored private let locations: Locations
    
    init(locations: Locations) {
        self.locations = locations
    }
    
    func handleSelection(_ result: LocationSearchService.LocationResult) async -> Int? {
        do {
            let coordinate = try await LocationManager.getCoordinate(address: result.title)
            
            if let index = locations.locations.firstIndex(where: { $0.coordinate == coordinate }) {
                logger.debug("SearchLocationViewModel: location already exists!")
                return index
            }
            
            let (response, time) = try await WeatherService.fetchWeatherData(coordinate: coordinate)
            let newLocation = Location(name: result.title, coordinate: coordinate, role: .additional, weatherData: response, lastFetchTime: time)
            locations.locations.append(newLocation)
            
            return locations.locations.count - 1
        } catch {
            logger.error("handleSelection: \(error.localizedDescription)")
        }
        
        return nil
    }
}
