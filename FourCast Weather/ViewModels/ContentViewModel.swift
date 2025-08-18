//
//  ContentViewModel.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/04/2025.
//

import Foundation
import CoreLocation
import ActivityKit

@Observable
class ContentViewModel {
    let weatherService = WeatherService()
    var locationManager = LocationManager()
    let locations = Locations()
    let calendarManager = CalendarManager()
    
    var selection = -1
    
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
    
    var calendarEventLocationIndex: Int? {
        locations.locations.firstIndex { $0.role == .calendarEvent }
    }
    var calendarEventLocation: Location? {
        guard let calendarEventLocationIndex else { return nil }
        
        return locations.locations[calendarEventLocationIndex]
    }
    
    var weatherDataForSelectedTab: WeatherData? {
        let result: WeatherData?
        if selection == -2 {
            result = calendarEventLocation?.weatherData
        } else if selection == -1 {
            result = currentLocation?.weatherData
        } else if let additionalLocationsStartIndex, selection >= additionalLocationsStartIndex && selection < locations.locations.count {
            result = locations.locations[selection].weatherData
        } else {
            result = nil
        }
        
        return result
    }
    
    var hasEventStarted: Bool {
        guard let startDate = calendarManager.events.first?.startDate else { return false }
        return startDate < Date.now
    }
    
    var navbarTitle: String {
        if selection == -2, let calendarEventLocation {
            return hasEventStarted ? "W trakcie: " + calendarEventLocation.name : calendarEventLocation.name
        }
        if selection == -1, let currentLocation {
            return currentLocation.name
        }
        if let additionalLocationsStartIndex, selection >= additionalLocationsStartIndex && selection < locations.locations.count {
            return locations.locations[selection].name
        }
        
        return ""
    }
    
    var bottomToolbarMessage: String {
        let lastFetch: Date?
        if selection == -2 {
            lastFetch = calendarEventLocation?.lastFetchTime
        } else if selection == -1 {
            lastFetch = currentLocation?.lastFetchTime
        } else if let additionalLocationsStartIndex, selection >= additionalLocationsStartIndex && selection < locations.locations.count {
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
    
    init() {
        getEventLocation()
    }
    
    func startActivity(weatherData: WeatherData, userSettings: UserSettings) async {
        guard activity == nil else { return }
        print("startActivity(): pierwszy guard przeszedł")
        guard let calendarEventLocation else { return }
        print("startActivity(): drugi guard przeszedł")
        guard let startDate = calendarManager.events.first?.startDate else { return }
        print("startActivity(): czwarty guard przeszedł")
        
        var eventStartDateWeatherData: HourlyWeather?
        for hour in weatherData.hourly {
            let timeInterval = TimeInterval(hour.dt)
            let weatherDate = Date(timeIntervalSince1970: timeInterval)
            
            if Calendar.current.isDate(weatherDate, equalTo: startDate, toGranularity: .hour) {
                eventStartDateWeatherData = hour
            }
        }
        
        guard let eventStartDateWeatherData else { return }
        print("startActivity(): piąty guard przeszedł")
        let weatherIcon = eventStartDateWeatherData.weather.first?.icon
        
        let temp = WeatherService.getConvertedTemperature(from: eventStartDateWeatherData.temp, userSettings: userSettings)
        let icon = WeatherService.getWeatherIcon(weatherIcon)
//        let travelTime = calendarManager.events.first?.value(forKey: "travelTime")
        
        let attributes = CalendarEventWidgetAttributes()
        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: startDate,
                name: calendarEventLocation.name,
                temperature: temp,
                iconName: icon,
                timezoneOffset: weatherData.timezoneOffset,
                weatherIcon: weatherIcon,
                sunrise: weatherData.current.sunrise,
                sunset: weatherData.current.sunset
            ),
            staleDate: startDate
        )
        
        do {
            activity = try Activity<CalendarEventWidgetAttributes>.request(attributes: attributes, content: content, pushType: nil)
            print("Activity started successfully")
        } catch {
            print("Failed to assign an activity: \(error.localizedDescription)")
        }
    }
    
    func updateActivity(weatherData: WeatherData, userSettings: UserSettings) async {
        guard let activity else { return }
        guard let calendarEventLocation else { return }
        guard let weatherData = calendarEventLocation.weatherData else { return }
        guard let startDate = calendarManager.events.first?.startDate else { return }
        
        var eventStartDateWeatherData: HourlyWeather?
        for hour in weatherData.hourly {
            let timeInterval = TimeInterval(hour.dt)
            let weatherDate = Date(timeIntervalSince1970: timeInterval)
            
            if Calendar.current.isDate(weatherDate, equalTo: startDate, toGranularity: .hour) {
                eventStartDateWeatherData = hour
            }
        }
        
        guard let eventStartDateWeatherData else { return }
        
        let temp = WeatherService.getConvertedTemperature(from: eventStartDateWeatherData.temp, userSettings: userSettings)
        let icon = WeatherService.getWeatherIcon(eventStartDateWeatherData.weather.first?.icon)
        
        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: startDate,
                name: calendarEventLocation.name,
                temperature: temp,
                iconName: icon
            ),
            staleDate: startDate
        )
        
        await activity.update(content)
        print("Activity updated successfully!")
        }
    
    func stopActivity() async {
        guard let activity else { return }
        
        await activity.end(ActivityContent(state: CalendarEventWidgetAttributes.ContentState(eventDate: .now, name: "AAA", temperature: 112, iconName: "dog.fill"), staleDate: nil), dismissalPolicy: .immediate)
        self.activity = nil
    }
    
    func getEventLocation() {
        guard let coordinate = calendarManager.events.first?.structuredLocation?.geoLocation?.coordinate, let name = calendarManager.events.first?.structuredLocation?.title else {
            if let calendarEventLocationIndex {
                selection = -1
                locations.locations.remove(at: calendarEventLocationIndex)
            }
            return
        }
        
        if let calendarEventLocationIndex {
            locations.locations[calendarEventLocationIndex].name = name
            locations.locations[calendarEventLocationIndex].coordinate = Location.Coordinate(coordinate)
        } else {
            let event = Location(name: name, coordinate: Location.Coordinate(coordinate), role: .calendarEvent)
            locations.locations.insert(event, at: 0)
        }
    }
    
    func fetchCurrentLocation() {
        do {
            try locationManager.checkLocationAuthorization()
        } catch {
//            errorTitle = "Daj lokalizację pls"
//            errorMessage = "Daj lokalizację to damy pogodę"
//            showingError = true
            print("TUTAJ CHYBA NIE TRZEBA ALERTA POKAZYWAĆ")
        }
    }
    
    func updateCurrentLocationCoordinate() {
        guard let coordinate = locationManager.location?.coordinate, locationManager.locationReady else { return }
        
        if let currentLocationIndex {
            locations.locations[currentLocationIndex].coordinate = Location.Coordinate(coordinate)
        } else {
            let location = Location(name: locationManager.locationName ?? ". . .", coordinate: Location.Coordinate(coordinate), role: .current)
            let index = (calendarEventLocationIndex ?? -1) + 1
            locations.locations.insert(location, at: index)
        }
    }
    
    func updateCurrentLocationName() {
        guard let currentLocationIndex, let name = locationManager.locationName else { return }
                        
        locations.locations[currentLocationIndex].name = name
    }
    
    func fetchWeatherForCurrentLocation(oldLocation: CLLocation, newLocation: CLLocation) async {
        guard let currentLocationIndex, let currentLocation else { return }
        guard shouldFetchWeather(oldLocation: oldLocation, newLocation: newLocation, minDistance: 10_000, lastFetchTime: currentLocation.lastFetchTime) else { return }
        
        let _ = await fetchWeather(for: currentLocationIndex)
    }
    
    private func fetchWeatherForAdditionalLocation(index: Int) async {
        guard let startIndex = additionalLocationsStartIndex, index >= startIndex, index < locations.locations.count else { return }
        guard shouldFetchWeather(lastFetchTime: locations.locations[index].lastFetchTime) else { return }
        
        guard Date.now.timeIntervalSince(locations.locations[index].lastFetchTime ?? Date.distantPast) > 30 else { return }
        
        let _ = await fetchWeather(for: index)
    }
    
    func fetchWeatherForCalendarEventLocation(oldLocation: CLLocation, newLocation: CLLocation, userSettings: UserSettings? = nil) async {  // trzeba zrobić computed propery w CalendarManager, które bedzie trzymać najbliższe wydarzenie. wtedy może bedzie mozna to wywołać na .onChange
        guard let calendarEventLocationIndex, let calendarEventLocation else { return }
        guard shouldFetchWeather(oldLocation: oldLocation, newLocation: newLocation, minDistance: 1, lastFetchTime: calendarEventLocation.lastFetchTime) else { return }

        let data = await fetchWeather(for: calendarEventLocationIndex)
        
        guard let data, let userSettings else { return }
        
        if activity == nil {
            await startActivity(weatherData: data, userSettings: userSettings)
        } else {
            await updateActivity(weatherData: data, userSettings: userSettings)
        }
    }
  
    private func fetchWeather(for index: Int) async -> WeatherData? {
        guard index >= 0, index < locations.locations.count else { return nil }
        let location = locations.locations[index]
        
        do {
            let (data, time) = try await weatherService.fetchWeatherData(coordinate: location.coordinateObject, lastFetchTime: location.lastFetchTime)
            
            locations.locations[index].weatherData = data
            locations.locations[index].lastFetchTime = time
            
            return data
        } catch {
            handleWeatherError(error)
        }
        
        return nil
    }
    
    private func shouldFetchWeather(oldLocation: CLLocation? = nil, newLocation: CLLocation? = nil, minDistance: CLLocationDistance? = nil, lastFetchTime: Date?, minInterval: TimeInterval = 30) -> Bool {
        if let oldLocation, let newLocation, let minDistance {
            if oldLocation.distance(from: newLocation) > minDistance {
                return true
            }
        }
        
        if Date.now.timeIntervalSince(lastFetchTime ?? .distantPast) > minInterval {
            return true
        }
        
        return false
    }
    
    func refreshWeatherData() async {
        getEventLocation()
        
        if selection == -2 {
            await fetchWeatherForCalendarEventLocation()
            // przenioslem bo jestem debil i sie dziwilem ze nie odswieza po dodaniu wydarzenia w kalendarzu czaisz
        } else if selection == -1 {
            fetchCurrentLocation()
        } else {
            await fetchWeatherForAdditionalLocation(index: selection)
        }
    }
    
    private func handleWeatherError(_ error: Error) {
        switch error {
        case OpenWeatherError.invalidData:
            print("Invalid data")
            return
        case OpenWeatherError.alreadyInUse:
            print("Already in use")
            return
        case OpenWeatherError.fetchNotNecessary:
            print("Not necessary")
            return
        default:
            print("Unknown weather error")
            return
        }
    }
}
