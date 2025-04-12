//
//  ContentViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation
import CoreLocation

@Observable
class ContentViewModel {
    static var shared = ContentViewModel()
    
    private let weatherService = WeatherService.shared
    let locationManager = LocationManager()
    let additionalLocations = AdditionalLocations()
    let calendarManager = CalendarManager()
    
    var currentLocationWeatherData: WeatherData?
    var currentLocationLastFetchTime: Date?
    
//    var calendarEventLocationCoordinate: CLLocationCoordinate2D? {
//        calendarManager.events[0].structuredLocation?.geoLocation?.coordinate
//    }
//    var calendarEventLocationWeatherData: WeatherData?
//    var calendarEventLocationLastFetchTime: Date?
    
    var calendarEventLocation: AdditionalLocationData?
    
    var selection = -1
    var shouldRefresh = false
    
    var errorTitle = ""
    var errorMessage = ""
    var showingError = false
    
    var navbarTitle: String {
        if selection == -1 {
            return locationManager.locationName
        }
        if selection == -2 {
//            return "Następne wydarzenie: " + (calendarManager.events[0].title)
            guard let name = calendarEventLocation?.name else { return "" }
            return "Następne wydarzenie: " + (name)
        }
        if selection < additionalLocations.locations.count {
            return additionalLocations.locations[selection].name
        }
        
        return ""
    }
    
    var bottomToolbarMessage: String {
        guard let lastFetch =
                (selection == -1) ? currentLocationLastFetchTime :
                    (selection == -2) ? calendarEventLocation?.lastFetchTime :
                (selection >= 0 && selection < additionalLocations.locations.count ? additionalLocations.locations[selection].lastFetchTime : nil)
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
        guard let coordinate = calendarManager.events.first?.structuredLocation?.geoLocation?.coordinate,
        let name = calendarManager.events.first?.structuredLocation?.title else {
            return
        }
        
        calendarEventLocation = AdditionalLocationData(name: name, coordinate: Coordinate(coordinate))
        print("git")
    }
    
    func fetchCurrentLocationOrWeather() {
        if selection == -1 {
            fetchCurrentLocation()
        } else if selection == -2 {
            Task {
                await fetchWeatherForCalendarEventLocation()
            }
        } else {
            print("pogoda dla --\(selection)-- jest pobierana")
            Task {
                await refreshWeatherForAdditionalLocation(index: selection)
            }
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
    
    private func fetchWeatherForCalendarEventLocation() async {
        print("!!!!!!!!!!!!!!!!!!!!!!!!!")
        guard var event = calendarEventLocation else { return }
        print("po guardzie!!!!!!!!!!!!!!!!!!!!!!!!!")
        do {
            let (data, time) = try await weatherService.fetchWeatherData(coordinate: event.coordinateObject, lastFetchTime: event.lastFetchTime)
            event.weatherData = data
            event.lastFetchTime = time
            calendarEventLocation = event
        } catch {
            handleWeatherError(error)
        }
    }
    
    private func fetchCurrentLocation() {
        do {
            try locationManager.checkLocationAuthorization()
        } catch {
            errorTitle = "Daj lokalizację pls"
            errorMessage = "Daj lokalizację to damy pogodę"
            showingError = true
        }
    }
    
    private func refreshWeatherForAdditionalLocation(index: Int) async {
        guard index >= 0 else {
            print("refreshWeatherForAdditionalLocation index < 0")
            return
        }
        guard index < additionalLocations.locations.count else {
            print("refreshWeatherForAdditionalLocation index > count")
            return
        }
        
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
