//
//  WeatherTabViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation
import CoreLocation
import ActivityKit
import OSLog

@MainActor @Observable
class WeatherTabViewModel {
    @ObservationIgnored private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "WeatherTabVM")
    
    let locationManager: LocationManager
    let locations: Locations
    let calendarManager: CalendarManager
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
    
    init(locationManager: LocationManager = LocationManager(), locations: Locations = Locations(), calendarManager: CalendarManager = CalendarManager(), userSettings: UserSettings, liveActivityManager: LiveActivityManager) {
        self.locationManager = locationManager
        self.locations = locations
        self.calendarManager = calendarManager
        self.userSettings = userSettings
        self.liveActivityManager = liveActivityManager
    }
    
    func refreshData() async {
        logger.debug("refreshData called")
        async let additionalLocations: () = refreshAdditionalLocationData()
        async let currentLocation: () = fetchWeatherForCurrentLocation()
        async let calendarLocation: () = fetchWeatherForCalendarEventLocation()
        
        await _ = (additionalLocations, currentLocation, calendarLocation)
        
        await startOrUpdateLiveActivity()
        logger.debug("refreshData done")
    }
    
    func refreshAdditionalLocationData() async {
        logger.debug("refreshAdditionalLocationData called")
        if let additionalLocationsStartIndex {
            if selection >= additionalLocationsStartIndex && selection < locations.locations.count {
                logger.debug("selection == \(self.selection)")
                await fetchWeatherForAdditionalLocation(index: selection)
            }
        }
        logger.debug("refreshAdditionalLocationData done")
    }
    
//    private func initializeData() async {
//        logger.debug("initializeData called")
//        async let currentLocation: () = fetchWeatherForCurrentLocation()
//        async let calendarLocation: () = fetchWeatherForCalendarEventLocation()
//        
//        await currentLocation
//        await calendarLocation
//        
//        await startOrUpdateLiveActivity()
//        logger.debug("initializeData done")
//    }
    
    func startOrUpdateLiveActivity() async {
        await liveActivityManager.startOrUpdateActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
    }
    
    private func fetchCurrentLocation() async {
        logger.debug("fetchCurrentLocation called")
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
            logger.debug("locationManager.getCurrentLocationIfAuthorized() already in use")
        } catch {
            errorTitle = "Nie można określić lokalizacji"
            errorMessage = "Sprawdź czy GPS jest włączony i spróbuj ponownie"
            showingError = true
        }
        logger.debug("fetchCurrentLocation done")
    }
    
//    private func shouldUpdateCurrentLocation(coordinate: CLLocationCoordinate2D, tolerance: CLLocationDistance = 10) -> Bool {
//        logger.debug("shouldUpdateCurrentLocation called!")
//        guard let oldCoordinate = currentLocation?.coordinate else { return true }
//        
//        let oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
//        let newLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
//        
//        let result = oldLocation.distance(from: newLocation) > 10
//        logger.debug("shouldUpdateCurrentLocation return \(result)")
//        return result
//    }
    
    private func updateCurrentLocationName(coordinate: CLLocationCoordinate2D) async {
        logger.debug("updateCurrentLocationName called")
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let name = await LocationManager.getLocationName(for: location)
        
        if let name, let currentLocationIndex {
            locations.locations[currentLocationIndex].name = name
        }
        logger.debug("updateCurrentLocationName done")
    }
    
    private func getCalendarEventLocation() async {
        logger.debug("getCalendarEventLocation called")
        guard let calendarEvent = await calendarManager.getEventIfAuthorized(), let coordinate = calendarEvent.structuredLocation?.geoLocation?.coordinate, let name = calendarEvent.structuredLocation?.title else {
            if let _ = calendarEventLocation {
                selection = 0
                calendarEventLocation = nil
            }
            logger.debug("getCalendarEventLocation done: no calendar event found")
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
        logger.debug("getCalendarEventLocation done")
    }
    
    private func fetchWeatherForCalendarEventLocation() async {
        logger.debug("fetchWeatherForCalendarEventLocation called")
        let oldCoordinate = calendarEventLocation?.location.coordinate
        
        await getCalendarEventLocation()
        guard var location = calendarEventLocation else { return logger.debug("fetchWeatherForCalendarEventLocation done: no calendarEventLocation") }
        
        let newCoordinate = location.location.coordinate
        
        guard shouldFetchWeather(oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, minDistance: 5_000, lastFetchTime: location.location.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: location.location.coordinate) {
            
            location.location.weatherData = data
            location.location.lastFetchTime = time
            calendarEventLocation = location
        }
        logger.debug("fetchWeatherForCalendarEventLocation done")
    }
    
    private func fetchWeatherForCurrentLocation() async {
        logger.debug("fetchWeatherForCurrentLocation called")
        let oldCoordinate = currentLocation?.coordinate
        
        await fetchCurrentLocation()
        guard let currentLocationIndex, let currentLocation else { return }
        
        let newCoordinate = currentLocation.coordinate
        
        guard shouldFetchWeather(oldCoordinate: oldCoordinate, newCoordinate: newCoordinate, minDistance: 5_000, lastFetchTime: currentLocation.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: currentLocation.coordinate) {
            locations.locations[currentLocationIndex].weatherData = data
            locations.locations[currentLocationIndex].lastFetchTime = time
        }
        logger.debug("fetchWeatherForCurrentLocation done")
    }
    
    private func fetchWeatherForAdditionalLocation(index: Int) async {
        logger.debug("fetchWeatherForAdditionalLocation(index: \(index)) called")
        guard let startIndex = additionalLocationsStartIndex, index >= startIndex, index < locations.locations.count else { return logger.debug("fetchWeatherForAdditionalLocation(index: \(index)) done: wrong index") }
        guard shouldFetchWeather(lastFetchTime: locations.locations[index].lastFetchTime) else { return }
        
        var location = locations.locations[index]
        
        if let (data, time) = await fetchWeather(for: location.coordinate) {
            
            location.weatherData = data
            location.lastFetchTime = time
            locations.locations[index] = location
        }
        logger.debug("fetchWeatherForAdditionalLocation(index: \(index)) done")
    }
  
    private func fetchWeather(for coordinate: CLLocationCoordinate2D) async -> (WeatherData, Date)? {
        logger.debug("fetchWeather called")
        do {
            let (data, time) = try await WeatherService.fetchWeatherData(coordinate: coordinate)
            logger.debug("fetchWeather return data")
            return (data, time)
        } catch {
            handleWeatherError(error)
        }
        
        logger.debug("fetchWeather return nil")
        return nil
    }
    
    private func shouldFetchWeather(oldCoordinate: CLLocationCoordinate2D? = nil, newCoordinate: CLLocationCoordinate2D? = nil, minDistance: CLLocationDistance? = nil, lastFetchTime: Date?, minInterval: TimeInterval = 1800) -> Bool {
        logger.debug("shouldFetchWeather called")
        guard let lastFetchTime else {
            logger.debug("shouldFetchWeather return true: lastFetchTime nil")
            return true
        }
        if !Calendar.current.isDate(.now, equalTo: lastFetchTime, toGranularity: .hour) {
            logger.debug("shouldFetchWeather return true: hours differ")
            return true
        }
        
        if let oldCoordinate, let newCoordinate, let minDistance {
            let oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
            let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
            
            if oldLocation.distance(from: newLocation) > minDistance {
                logger.debug("shouldFetchWeather return true for minDistance")
                return true
            }
        }
        
        let result = Date.now.timeIntervalSince(lastFetchTime) > minInterval
        logger.debug("shouldFetchWeather returned \(result) for minInterval")
        return result
    }
    
    private func handleWeatherError(_ error: Error) {
//        switch error {
//        case OpenWeatherError.invalidData:
//            logger.debug("Invalid data")
//            
//        case OpenWeatherError.invalidURL:
//            logger.debug("Invalid URL")
//            
//        case OpenWeatherError.invalidResponse:
//            logger.debug("Invalid response")
//            
//        case OpenWeatherError.invalidKey:
//            logger.debug("Invalid API key")
//            
//        case OpenWeatherError.keyNotFound:
//            logger.debug("API key not found")
//
//        default:
//            logger.debug("Unknown weather error")
//
//        }
        
//        return
        
        logger.error("WeatherError: \(error.localizedDescription)")
    }
}
