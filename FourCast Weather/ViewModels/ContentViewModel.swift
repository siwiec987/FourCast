//
//  ContentViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation
import CoreLocation
import ActivityKit

struct CalendarEventLocation {
    var location: Location
    var startDate: Date
    var travelTime: Any? // pole "czas ruszać" w szczegółach eventu
}

@MainActor @Observable
class ContentViewModel {
    @ObservationIgnored let weatherService = WeatherService()
    let locationManager = LocationManager()
    let locations = Locations()
    let calendarManager = CalendarManager()
    let userSettings: UserSettings
    let liveActivityManager: LiveActivityManager
    
    var selection = 0
    
    var errorTitle = ""
    var errorMessage = ""
    var showingError = false
    
    var currentLocationIndex: Int? {
        locations.locations.firstIndex { $0.role == .current }
    }
    var currentLocation: Location? {
        guard let currentLocationIndex else { return nil}
        
        return locations.locations[currentLocationIndex]
    }
    
    var additionalLocationsStartIndex: Int? {
        locations.locations.firstIndex { $0.role == .additional }
    }
    
    var calendarEventLocation: CalendarEventLocation? = nil
    
    var weatherDataForSelectedTab: WeatherData? {
        let result: WeatherData?
        if selection == -2 {
            result = calendarEventLocation?.location.weatherData
        } else if selection >= 0 && selection < locations.locations.count {
            result = locations.locations[selection].weatherData
        } else {
            result = nil
        }
        
        return result
    }
    
    var navbarTitle: String {
        if selection == -2, let calendarEventLocation {
            return calendarEventLocation.location.name
        }
        if selection >= 0 && selection < locations.locations.count {
            return locations.locations[selection].name
        }
        
        return ""
    }
    
    var bottomToolbarMessage: String {
        let lastFetch: Date?
        if selection == -2 {
            lastFetch = calendarEventLocation?.location.lastFetchTime
        } else if selection >= 0 && selection < locations.locations.count {
            lastFetch = locations.locations[selection].lastFetchTime
        } else {
            lastFetch = nil
        }
        
        guard let lastFetch else { return "" }
        
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
    
    init(userSettings: UserSettings, liveActivityManager: LiveActivityManager) {
        self.userSettings = userSettings
        self.liveActivityManager = liveActivityManager
    }
    
    func refreshData() async {
        print("refreshData called!")
        await refreshAdditionalLocationData()
        await initializeData()
        print("refreshData done!")
    }
    
    func refreshAdditionalLocationData() async {
        print("refreshAdditionalLocationData called!")
        if let additionalLocationsStartIndex {
            if selection >= additionalLocationsStartIndex && selection < locations.locations.count {
                await fetchWeatherForAdditionalLocation(index: selection)
            }
        }
        print("refreshAdditionalLocationData done!")
    }
    
    private func initializeData() async {
        print("initializeData called!")
        async let currentLocation: () = fetchWeatherForCurrentLocation()
        async let calendarLocation: () = fetchWeatherForCalendarEventLocation()
        
        await currentLocation
        await calendarLocation
        
        // TODO: trzeba dodać do ustawień wybór offsetu dla startu live activity, np. 30 minut przed startem wydarzenia
        await liveActivityManager.startOrUpdateActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
        print("initializeData done!")
    }
    
    private func fetchCurrentLocation() async {
        print("fetchCurrentLocation called!")
        do {
            let coordinate = try await locationManager.getCurrentLocationIfAuthorized()
            
//            guard shouldUpdateCurrentLocation(coordinate: coordinate) else { return } // nie wiem czy potrzebne
            
            if let currentLocationIndex {
                locations.locations[currentLocationIndex].coordinate = Location.Coordinate(coordinate)
            } else {
                let location = Location(name: ". . .", coordinate: Location.Coordinate(coordinate), role: .current)
                locations.locations.insert(location, at: 0)
            }
            
            Task {
                await updateCurrentLocationName(coordinate: coordinate)
            }
        } catch LocationManagerError.permissionDenied {
            errorTitle = "Brak dostępu do lokalizacji"
            errorMessage = "Aby wyświetlić prognozę pogody dla Twojej lokalizacji, włącz dostęp w Ustawieniach"
            showingError = true
        } catch LocationManagerError.alreadyInUse {
            print("locationManager.getCurrentLocationIfAuthorized() already in use!")
        } catch {
            errorTitle = "Nie można określić lokalizacji"
            errorMessage = "Sprawdź czy GPS jest włączony i spróbuj ponownie"
            showingError = true
        }
        print("fetchCurrentLocation done!")
    }
    
    private func shouldUpdateCurrentLocation(coordinate: CLLocationCoordinate2D, tolerance: CLLocationDistance = 10) -> Bool {
        print("shouldUpdateCurrentLocation called!")
        guard let oldCoordinate = currentLocation?.coordinateObject else { return true }
        
        let oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        
        let result = oldLocation.distance(from: newLocation) > 10
        print("shouldUpdateCurrentLocation return \(result)")
        return result
    }
    
    private func updateCurrentLocationName(coordinate: CLLocationCoordinate2D) async {
        print("updateCurrentLocationName called!")
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let name = await LocationManager.getLocationName(for: location)
        
        if let name, let currentLocationIndex {
            locations.locations[currentLocationIndex].name = name
        }
        print("updateCurrentLocationName done!")
    }
    
    private func getCalendarEventLocation() {
        print("getCalendarEventLocation called!")
        guard let calendarEvent = calendarManager.getEventIfAuthorized(), let coordinate = calendarEvent.structuredLocation?.geoLocation?.coordinate, let name = calendarEvent.structuredLocation?.title else {
            if let _ = calendarEventLocation {
                selection = 0
                calendarEventLocation = nil
            }
            print("getCalendarEventLocation done: no calendar event found")
            return
        }

        if var copy = calendarEventLocation {
            copy.location.name = name
            copy.location.coordinate = Location.Coordinate(coordinate)
            copy.startDate = calendarEvent.startDate
            copy.travelTime = calendarEvent.value(forKey: "travelTime")
            calendarEventLocation = copy
        } else {
            let event = CalendarEventLocation(
                location: Location(name: name, coordinate: Location.Coordinate(coordinate), role: .calendarEvent),
                startDate: calendarEvent.startDate,
                travelTime: calendarEvent.value(forKey: "travelTime")
            )
            calendarEventLocation = event
        }
        print("getCalendarEventLocation done!")
    }
    
    private func fetchWeatherForCalendarEventLocation() async {
        print("fetchWeatherForCalendarEventLocation called!")
        let oldCoordinate = calendarEventLocation?.location.coordinateObject
        
        getCalendarEventLocation()
        guard var location = calendarEventLocation else { return print("fetchWeatherForCalendarEventLocation done: no calendarEventLocation") }
        
        let newCoordinate = location.location.coordinateObject
        
        guard shouldFetchWeather(oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, minDistance: 5_000, lastFetchTime: location.location.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: location.location.coordinateObject) {
            
            location.location.weatherData = data
            location.location.lastFetchTime = time
            calendarEventLocation = location
        }
        print("fetchWeatherForCalendarEventLocation done!")
    }
    
    private func fetchWeatherForCurrentLocation() async {
        print("fetchWeatherForCurrentLocation called!")
        let oldCoordinate = currentLocation?.coordinateObject
        
        await fetchCurrentLocation()
        guard let currentLocationIndex, var currentLocation else { return }
        
        let newCoordinate = currentLocation.coordinateObject
        
        guard shouldFetchWeather(oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, minDistance: 5_000, lastFetchTime: currentLocation.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: currentLocation.coordinateObject) {
            
            currentLocation.weatherData = data
            currentLocation.lastFetchTime = time
            locations.locations[currentLocationIndex] = currentLocation
        }
        print("fetchWeatherForCurrentLocation done!")
    }
    
    private func fetchWeatherForAdditionalLocation(index: Int) async {
        print("fetchWeatherForAdditionalLocation(index: \(index)) called!")
        guard let startIndex = additionalLocationsStartIndex, index >= startIndex, index < locations.locations.count else { return print("fetchWeatherForAdditionalLocation(index: \(index)) done: wrong index") }
        guard shouldFetchWeather(lastFetchTime: locations.locations[index].lastFetchTime) else { return }
        
        var location = locations.locations[index]
        
        if let (data, time) = await fetchWeather(for: location.coordinateObject) {
            
            location.weatherData = data
            location.lastFetchTime = time
            locations.locations[index] = location
        }
        print("fetchWeatherForAdditionalLocation(index: \(index)) done!")
    }
  
    private func fetchWeather(for coordinate: CLLocationCoordinate2D) async -> (WeatherData, Date)? {
        print("fetchWeather called!")
        do {
            let (data, time) = try await weatherService.fetchWeatherData(coordinate: coordinate)
            print("fetchWeather return data")
            return (data, time)
        } catch {
            handleWeatherError(error)
        }
        
        print("fetchWeather return nil")
        return nil
    }
    
    private func shouldFetchWeather(oldCoordinate: CLLocationCoordinate2D? = nil, newCoordinate: CLLocationCoordinate2D? = nil, minDistance: CLLocationDistance? = nil, lastFetchTime: Date?, minInterval: TimeInterval = 90) -> Bool {
        print("shouldFetchWeather called!")
        
        if let oldCoordinate, let newCoordinate, let minDistance {
            let oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
            let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            if oldLocation.distance(from: newLocation) > minDistance {
                print("shouldFetchWeather return true for minDistance")
                return true
            }
        }
        
        let result = Date.now.timeIntervalSince(lastFetchTime ?? .distantPast) > minInterval
        print("shouldFetchWeather returned \(result) for minInterval")
        return result
    }
    
    private func handleWeatherError(_ error: Error) {
//        switch error {
//        case OpenWeatherError.invalidData:
//            print("Invalid data")
//            
//        case OpenWeatherError.invalidURL:
//            print("Invalid URL")
//            
//        case OpenWeatherError.invalidResponse:
//            print("Invalid response")
//            
//        case OpenWeatherError.invalidKey:
//            print("Invalid API key")
//            
//        case OpenWeatherError.keyNotFound:
//            print("API key not found")
//
//        default:
//            print("Unknown weather error")
//
//        }
        
//        return
        
        print("WeatherError:", error)
    }
}
