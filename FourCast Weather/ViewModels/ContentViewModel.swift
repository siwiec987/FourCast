//
//  ContentViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation

@Observable
class ContentViewModel {
    static var shared = ContentViewModel()
    
    var currentLocationWeatherData: WeatherData?
    var currentLocationLastFetchTime: Date?
    
    var selection = -1
    var shouldRefresh = false
    
    var errorTitle = ""
    var errorMessage = ""
    var showingError = false
    
    private let weatherService = WeatherService.shared
    private let locationManager = LocationManager.shared
    private let additionalLocations = AdditionalLocations.shared
    
    var navbarTitle: String {
        if selection == -1 {
            return locationManager.locationName
        }
        if selection == -2 {
            return "Kalendarz"
        }
        if selection < additionalLocations.locations.count {
            return additionalLocations.locations[selection].name
        }
        
        return ""
    }
    
    var bottomToolbarMessage: String {
        guard let lastFetch =
                (selection == -1) ?
                currentLocationLastFetchTime : (
                    selection >= 0 && selection < additionalLocations.locations.count ?
                    additionalLocations.locations[selection].lastFetchTime : nil)
        else {
            return ""
        }
        
        let calendar = Calendar.current
        if calendar.isDateInToday(lastFetch) {
            return lastFetch.formatted(date: .omitted, time: .shortened)
        }
        
        return lastFetch.formatted(date: .abbreviated, time: .shortened)
    }

    
    var bottomToolbarTitle: String {
        guard !bottomToolbarMessage.isEmpty else {
            return ""
        }
        
        return "Ostatnia aktualizacja:"
    }
    
    private init() {
        
    }
    
    func fetchCurrentLocation() {
        do {
            try locationManager.checkLocationAuthorization()
        } catch {
            errorTitle = "Daj lokalizację pls"
            errorMessage = "Daj lokalizację to damy pogodę"
            showingError = true
        }
    }
    
    func fetchWeatherForCurrentLocation() {
        guard let location = locationManager.location, locationManager.locationReady else { return }
        
        Task {
            do {
                (currentLocationWeatherData, currentLocationLastFetchTime) = try await weatherService.fetchWeatherData(coordinate: location.coordinate, lastFetchTime: currentLocationLastFetchTime)
            } catch {
                handleWeatherError(error)
            }
        }
    }
    
    func refreshWeatherForAdditionalLocation(index: Int) async {
        guard index < additionalLocations.locations.count else { return }
        
        do {
            (additionalLocations.locations[index].weatherData, additionalLocations.locations[index].lastFetchTime) =
            try await weatherService.fetchWeatherData(coordinate: additionalLocations.locations[index].coordinateObject,
                                                      lastFetchTime: additionalLocations.locations[index].lastFetchTime)
        } catch {
            handleWeatherError(error)
        }
    }
    
    private func handleWeatherError(_ error: Error) {
        switch error {
        case OpenWeatherError.invalidData:
//            errorTitle = "Błąd danych"
//            errorMessage = "Nie udało się pobrać poprawnych danych."
            print("Invalid data")
            return
        case OpenWeatherError.alreadyInUse:
            print("Already in use")
            return
        case OpenWeatherError.fetchNotNecessary:
            print("Not necessary")
            return
        default:
//            errorTitle = "Błąd"
//            errorMessage = "Coś poszło nie tak."
            print("Unknown weather error")
            return
        }
//        showingError = true
    }
}
