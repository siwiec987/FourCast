//
//  ContentViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation
import CoreLocation
import ActivityKit

@MainActor @Observable
class ContentViewModel {
    @ObservationIgnored let weatherService = WeatherService()
    let locationManager = LocationManager()
    let locations = Locations()
    let calendarManager = CalendarManager()
    let userSettings: UserSettings
    
    var selection = 0
    
    var errorTitle = ""
    var errorMessage = ""
    var showingError = false
    
    var activity: Activity<CalendarEventWidgetAttributes>? = nil
    
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
    
    var calendarEventLocation: Location? = nil
    
    var weatherDataForSelectedTab: WeatherData? {
        let result: WeatherData?
        if selection == -2 {
            result = calendarEventLocation?.weatherData
        } else if selection >= 0 && selection < locations.locations.count {
            result = locations.locations[selection].weatherData
        } else {
            result = nil
        }
        
        return result
    }
    
    var navbarTitle: String {
        if selection == -2, let calendarEventLocation {
            return calendarEventLocation.name
        }
        if selection >= 0 && selection < locations.locations.count {
            return locations.locations[selection].name
        }
        
        return ""
    }
    
    var bottomToolbarMessage: String {
        let lastFetch: Date?
        if selection == -2 {
            lastFetch = calendarEventLocation?.lastFetchTime
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
    
    init(userSettings: UserSettings) {
        self.userSettings = userSettings
    }
    
    func refreshData() async {
        print("refreshData called!")
        await initializeData()
        
        if let additionalLocationsStartIndex {
            if selection >= additionalLocationsStartIndex && selection < locations.locations.count {
                await fetchWeatherForAdditionalLocation(index: selection)
            }
        }
        print("refreshData done!")
    }
    
    private func initializeData() async {
        print("initializeData called!")
        await fetchWeatherForCurrentLocation()
        await fetchWeatherForCalendarEventLocation()
//        await startOrUpdateActivity()
        print("initializeData done!")
    }
    
    private func fetchCurrentLocation() async {
        print("fetchCurrentLocation called!")
        do {
            let coordinate = try await locationManager.getCurrentLocationIfAuthorized()
            
            guard shouldUpdateCurrentLocation(coordinate: coordinate) else { return }
            
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
    
    private func getCalendarEventLocation() /*async*/ {
        print("getCalendarEventLocation called!")
        guard let event = calendarManager.getEventIfAuthorized(), let coordinate = event.structuredLocation?.geoLocation?.coordinate, let name = event.structuredLocation?.title else {
            if let _ = calendarEventLocation {
                selection = 0
                calendarEventLocation = nil
            }
            print("getCalendarEventLocation done: no calendar event found")
            return
        }
        
        if var copy = calendarEventLocation {
            copy.name = name
            copy.coordinate = Location.Coordinate(coordinate)
            calendarEventLocation = copy
        } else {
            let event = Location(name: name, coordinate: Location.Coordinate(coordinate), role: .calendarEvent)
            calendarEventLocation = event
        }
        print("getCalendarEventLocation done!")
    }
    
//    func startOrUpdateActivity() async {
//        print("startOrUpdateActivity wywołane")
//        if activity != nil {
//            print("update")
//            await updateActivity(userSettings: userSettings)
//        } else {
//            print("start")
//            await startActivityIfNeeded(userSettings: userSettings)
//        }
//    }
//
//    func startActivityIfNeeded(userSettings: UserSettings) async {
//        guard activity == nil else { return }
//        print("startActivity(): pierwszy guard przeszedł")
//        guard let calendarEventLocation else { return }
//        print("startActivity(): drugi guard przeszedł")
//        guard let startDate = calendarManager.firstEvent?.startDate else { return }
//        print("startActivity(): czwarty guard przeszedł")
//        guard let weatherData = calendarEventLocation.weatherData else { return }
//        print("startActivity(): piąty guard przeszedł")
//
//        var eventStartDateWeatherData: HourlyWeather?
//        for hour in weatherData.hourly {
//            let timeInterval = TimeInterval(hour.dt)
//            let weatherDate = Date(timeIntervalSince1970: timeInterval)
//
//            if Calendar.current.isDate(weatherDate, equalTo: startDate, toGranularity: .hour) {
//                eventStartDateWeatherData = hour
//            }
//        }
//
//        guard let eventStartDateWeatherData else { return }
//        print("startActivity(): szósty guard przeszedł")
//        let weatherIcon = eventStartDateWeatherData.weather.first?.icon
//
//        let temp = WeatherService.getConvertedTemperature(from: eventStartDateWeatherData.temp, userSettings: userSettings)
//        let icon = WeatherService.getWeatherIcon(weatherIcon)
////        let travelTime = calendarManager.events.first?.value(forKey: "travelTime")
//
//        let attributes = CalendarEventWidgetAttributes()
//        let content = ActivityContent(
//            state: CalendarEventWidgetAttributes.ContentState(
//                eventDate: startDate,
//                name: calendarEventLocation.name,
//                temperature: temp,
//                iconName: icon,
//                timezoneOffset: weatherData.timezoneOffset,
//                weatherIcon: weatherIcon,
//                sunrise: weatherData.current.sunrise,
//                sunset: weatherData.current.sunset
//            ),
//            staleDate: startDate
//        )
//
//        do {
//            activity = try Activity<CalendarEventWidgetAttributes>.request(attributes: attributes, content: content, pushType: nil)
//            print("Activity started successfully")
//        } catch {
//            print("Failed to assign an activity: \(error.localizedDescription)")
//        }
//    }
//
//    func updateActivity(userSettings: UserSettings) async {
//        guard let activity else { return }
//        guard let calendarEventLocation else { return }
//        guard let weatherData = calendarEventLocation.weatherData else { return }
//        guard let startDate = calendarManager.firstEvent?.startDate else { return }
//
//        var eventStartDateWeatherData: HourlyWeather?
//        for hour in weatherData.hourly {
//            let timeInterval = TimeInterval(hour.dt)
//            let weatherDate = Date(timeIntervalSince1970: timeInterval)
//
//            if Calendar.current.isDate(weatherDate, equalTo: startDate, toGranularity: .hour) {
//                eventStartDateWeatherData = hour
//            }
//        }
//
//        guard let eventStartDateWeatherData else { return }
//
//        let temp = WeatherService.getConvertedTemperature(from: eventStartDateWeatherData.temp, userSettings: userSettings)
//        let icon = WeatherService.getWeatherIcon(eventStartDateWeatherData.weather.first?.icon)
//
//        let content = ActivityContent(
//            state: CalendarEventWidgetAttributes.ContentState(
//                eventDate: startDate,
//                name: calendarEventLocation.name,
//                temperature: temp,
//                iconName: icon
//            ),
//            staleDate: startDate
//        )
//
//        await activity.update(content)
//        print("Activity updated successfully!")
//        }
//
//    func stopActivity() async {
//        guard let activity else { return }
//
//        await activity.end(ActivityContent(state: CalendarEventWidgetAttributes.ContentState(eventDate: .now, name: "AAA", temperature: 112, iconName: "dog.fill"), staleDate: nil), dismissalPolicy: .immediate)
//        self.activity = nil
//    }
//
    
    private func fetchWeatherForCalendarEventLocation() async {
        print("fetchWeatherForCalendarEventLocation called!")
        let oldLocation: CLLocation?
        if let oldCoordinate = calendarEventLocation?.coordinateObject {
            oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
        } else {
            oldLocation = nil
        }
        
        /*await */getCalendarEventLocation()
        guard var location = calendarEventLocation else { return print("fetchWeatherForCalendarEventLocation done: no calendarEventLocation") }
        
        let newCoordinate = location.coordinateObject
        let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        
        guard shouldFetchWeather(oldLocation: oldLocation, newLocation: newLocation, minDistance: 5_000, lastFetchTime: location.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: location.coordinateObject) {
            
            location.weatherData = data
            location.lastFetchTime = time
            calendarEventLocation = location
        }
        print("fetchWeatherForCalendarEventLocation done!")
    }
    
    private func fetchWeatherForCurrentLocation() async {
        print("fetchWeatherForCurrentLocation called!")
        let oldLocation: CLLocation?
        if let oldCoordinate = currentLocation?.coordinateObject {
            oldLocation = CLLocation(latitude: oldCoordinate.latitude, longitude: oldCoordinate.longitude)
        } else {
            oldLocation = nil
        }
        
        await fetchCurrentLocation()
        guard let currentLocationIndex, var currentLocation else { return }
        
        let newCoordinate = currentLocation.coordinateObject
        let newLocation = CLLocation(latitude: newCoordinate.latitude, longitude: newCoordinate.longitude)
        
        guard shouldFetchWeather(oldLocation: oldLocation, newLocation: newLocation, minDistance: 5_000, lastFetchTime: currentLocation.lastFetchTime) else { return }
        
        if let (data, time) = await fetchWeather(for: currentLocation.coordinateObject) {
            
            currentLocation.weatherData = data
            currentLocation.lastFetchTime = time
            locations.locations[currentLocationIndex] = currentLocation
        }
        print("fetchWeatherForCurrentLocation done!")
    }
    
    private func fetchWeatherForAdditionalLocation(index: Int) async {
        print("fetchWeatherForAdditionalLocation(index: \(index) called!")
        guard let startIndex = additionalLocationsStartIndex, index >= startIndex, index < locations.locations.count else { return }
        guard shouldFetchWeather(lastFetchTime: locations.locations[index].lastFetchTime) else { return }
        
        var location = locations.locations[index]
        
        if let (data, time) = await fetchWeather(for: location.coordinateObject) {
            
            location.weatherData = data
            location.lastFetchTime = time
            locations.locations[index] = location
        }
        print("fetchWeatherForAdditionalLocation(index: \(index) done!")
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
    
    private func shouldFetchWeather(oldLocation: CLLocation? = nil, newLocation: CLLocation? = nil, minDistance: CLLocationDistance? = nil, lastFetchTime: Date?, minInterval: TimeInterval = 90) -> Bool {
        print("shouldFetchWeather called!")
        
        if let oldLocation, let newLocation, let minDistance {
            if oldLocation.distance(from: newLocation) > minDistance {
                print("shouldFetchWeather return true for minDistance")
                return true
            }
        }
        
        if Date.now.timeIntervalSince(lastFetchTime ?? .distantPast) > minInterval {
            print("shouldFetchWeather return true for minInterval")
            return true
        }
        
        print("shouldFetchWeather return false")
        return false
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
