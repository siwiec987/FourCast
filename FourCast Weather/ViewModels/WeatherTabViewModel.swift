//
//  WeatherTabViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation
import CoreLocation
import ActivityKit

@MainActor @Observable
class WeatherTabViewModel {
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
    
    var lastFetchTimeForSelectedTab: Date? {
        let lastFetch: Date?
        if selection == -2 {
            lastFetch = calendarEventLocation?.location.lastFetchTime
        } else if selection >= 0 && selection < locations.locations.count {
            lastFetch = locations.locations[selection].lastFetchTime
        } else {
            lastFetch = nil
        }
        
        return lastFetch
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
                print("selection == \(selection)")
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
        
        await startOrUpdateLiveActivity()
        print("initializeData done!")
    }
    
    func startOrUpdateLiveActivity() async {
        await liveActivityManager.startOrUpdateActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
    }
    
    private func fetchCurrentLocation() async {
        print("fetchCurrentLocation called!")
        do {
            let coordinate = try await locationManager.getCurrentLocationIfAuthorized()
            
//            guard shouldUpdateCurrentLocation(coordinate: coordinate) else { return } // nie wiem czy potrzebne
            
            if let currentLocationIndex {
                locations.locations[currentLocationIndex].coordinate = coordinate
            } else {
                let location = Location(name: ". . .", coordinate: coordinate, role: .current)
                locations.locations.insert(location, at: 0)
            }
            
            Task {
                await updateCurrentLocationName(coordinate: coordinate)
            }
        } catch LocationManagerError.permissionDenied {
            if let currentLocationIndex {
                locations.locations.remove(at: currentLocationIndex)
            }
        } catch LocationManagerError.alreadyInUse {
            print("locationManager.getCurrentLocationIfAuthorized() already in use!")
        } catch {
            errorTitle = "Nie można określić lokalizacji"
            errorMessage = "Sprawdź czy GPS jest włączony i spróbuj ponownie"
            showingError = true
        }
        print("fetchCurrentLocation done!")
    }
    
//    private func shouldUpdateCurrentLocation(coordinate: CLLocationCoordinate2D, tolerance: CLLocationDistance = 10) -> Bool {
//        print("shouldUpdateCurrentLocation called!")
//        guard let oldCoordinate = currentLocation?.coordinate else { return true }
//        
//        let oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
//        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        
//        let result = oldLocation.distance(from: newLocation) > 10
//        print("shouldUpdateCurrentLocation return \(result)")
//        return result
//    }
    
    private func updateCurrentLocationName(coordinate: CLLocationCoordinate2D) async {
        print("updateCurrentLocationName called!")
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let name = await LocationManager.getLocationName(for: location)
        
        if let name, let currentLocationIndex {
            locations.locations[currentLocationIndex].name = name
        }
        print("updateCurrentLocationName done!")
    }
    
    private func getCalendarEventLocation() async {
        print("getCalendarEventLocation called!")
        guard let calendarEvent = await calendarManager.getEventIfAuthorized(), let coordinate = calendarEvent.structuredLocation?.geoLocation?.coordinate, let name = calendarEvent.structuredLocation?.title else {
            if let _ = calendarEventLocation {
                selection = 0
                calendarEventLocation = nil
            }
            print("getCalendarEventLocation done: no calendar event found")
            return
        }

        let travelTime = calendarEvent.value(forKey: "travelTime") as? TimeInterval
        if var copy = calendarEventLocation {
            copy.location.name = name
            copy.location.coordinate = coordinate
            copy.startDate = calendarEvent.startDate
            copy.travelTime = travelTime
            calendarEventLocation = copy
        } else {
            let event = CalendarEventLocation(
                location: Location(name: name, coordinate: coordinate, role: .calendarEvent),
                startDate: calendarEvent.startDate,
                travelTime: travelTime
            )
            calendarEventLocation = event
        }
        print("getCalendarEventLocation done!")
    }
    
    private func fetchWeatherForCalendarEventLocation() async {
        print("fetchWeatherForCalendarEventLocation called!")
        let oldCoordinate = calendarEventLocation?.location.coordinate
        
        await getCalendarEventLocation()
        guard var location = calendarEventLocation else { return print("fetchWeatherForCalendarEventLocation done: no calendarEventLocation") }
        
        let newCoordinate = location.location.coordinate
        
        guard shouldFetchWeather(oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, minDistance: 5_000, lastFetchTime: location.location.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: location.location.coordinate) {
            
            location.location.weatherData = data
            location.location.lastFetchTime = time
            calendarEventLocation = location
        }
        print("fetchWeatherForCalendarEventLocation done!")
    }
    
    private func fetchWeatherForCurrentLocation() async {
        print("fetchWeatherForCurrentLocation called!")
        let oldCoordinate = currentLocation?.coordinate
        
        await fetchCurrentLocation()
        guard let currentLocationIndex, let currentLocation else { return }
        
        let newCoordinate = currentLocation.coordinate
        
        guard shouldFetchWeather(oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, minDistance: 5_000, lastFetchTime: currentLocation.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: currentLocation.coordinate) {
            locations.locations[currentLocationIndex].weatherData = data
            locations.locations[currentLocationIndex].lastFetchTime = time
        }
        print("fetchWeatherForCurrentLocation done!")
    }
    
    private func fetchWeatherForAdditionalLocation(index: Int) async {
        print("fetchWeatherForAdditionalLocation(index: \(index)) called!")
        guard let startIndex = additionalLocationsStartIndex, index >= startIndex, index < locations.locations.count else { return print("fetchWeatherForAdditionalLocation(index: \(index)) done: wrong index") }
        guard shouldFetchWeather(lastFetchTime: locations.locations[index].lastFetchTime) else { return }
        
        var location = locations.locations[index]
        
        if let (data, time) = await fetchWeather(for: location.coordinate) {
            
            location.weatherData = data
            location.lastFetchTime = time
            locations.locations[index] = location
        }
        print("fetchWeatherForAdditionalLocation(index: \(index)) done!")
    }
  
    private func fetchWeather(for coordinate: CLLocationCoordinate2D) async -> (WeatherData, Date)? {
        print("fetchWeather called!")
        do {
            let (data, time) = try await WeatherService.fetchWeatherData(coordinate: coordinate)
            print("fetchWeather return data")
            return (data, time)
        } catch {
            handleWeatherError(error)
        }
        
        print("fetchWeather return nil")
        return nil
    }
    
    private func shouldFetchWeather(oldCoordinate: CLLocationCoordinate2D? = nil, newCoordinate: CLLocationCoordinate2D? = nil, minDistance: CLLocationDistance? = nil, lastFetchTime: Date?, minInterval: TimeInterval = 1800) -> Bool {
        print("shouldFetchWeather called!")
        guard let lastFetchTime else {
            print("shouldFetchWeather return true: lastFetchTime nil")
            return true
        }
        if !Calendar.current.isDate(.now, equalTo: lastFetchTime, toGranularity: .hour) {
            print("shouldFetchWeather return true: hours differ")
            return true
        }
        
        if let oldCoordinate, let newCoordinate, let minDistance {
            let oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
            let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            if oldLocation.distance(from: newLocation) > minDistance {
                print("shouldFetchWeather return true for minDistance")
                return true
            }
        }
        
        let result = Date.now.timeIntervalSince(lastFetchTime) > minInterval
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
