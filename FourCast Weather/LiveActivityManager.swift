//
//  LiveActivityManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 27/08/2025.
//

import ActivityKit
import BackgroundTasks
import Foundation

@MainActor @Observable
class LiveActivityManager {
    @ObservationIgnored private let authorizationInfo = ActivityAuthorizationInfo()
    @ObservationIgnored private(set) var activity: Activity<CalendarEventWidgetAttributes>? = nil
    @ObservationIgnored let bgTaskIdentifier = "LiveActivityManager.scheduleActivityEndRequest"
    
    var isAuthorized = false
    
    init() {
        isAuthorized = authorizationInfo.areActivitiesEnabled
    }
    
    func startOrUpdateActivity(calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings) async {
        if activity == nil {
            startActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
        } else {
            await updateActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
        }
    }
    
    // TODO: trzeba dodać w ustawieniach możliwość wyboru ile czasu przed startem wydarzenia live activity się powinno odpalać i zrobić jakąś sprawdzajkę czy już odpalać czy nie
    private func startActivity(calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings) {
        print("startActivity called!")
        guard activity == nil else { return print("startActivity done: already started") }
        guard checkAuthorization() else { return print("startActivity done: activities not enabled") }
        guard let calendarEventLocation else { return print("startActivity done: no calendarEventLocation") }
        guard let content = createActivityContent(calendarEventLocation: calendarEventLocation, userSettings: userSettings) else { return print("startActivity done: createActivityContent returned nil") }

        let attributes = CalendarEventWidgetAttributes()
        do {
            activity = try Activity<CalendarEventWidgetAttributes>.request(attributes: attributes, content: content, pushType: nil)
            print("startActivity done: activity started successfully")
            scheduleActivityEnd(calendarEventLocation.startDate)
        } catch {
            print("startActivity done: failed to assign an activity: \(error.localizedDescription)")
        }
    }

    private func updateActivity(calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings) async {
        print("updateActivity called!")
        guard let activity else { return print("updateActivity done: no activity") }
        guard checkAuthorization() else {
            await endActivity(dismissalPolicy: .immediate)
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: bgTaskIdentifier)
            return print("updateActivity done: activities not enabled")
        }
        guard let calendarEventLocation else {
            await endActivity(dismissalPolicy: .immediate)
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: bgTaskIdentifier)
            return print("updateActivity done: no calendarEventLocation")
        }
        
        guard let content = createActivityContent(calendarEventLocation: calendarEventLocation, userSettings: userSettings) else { return print("updateActivity done: createActivityContent returned nil") }
        guard shouldUpdateActivity(newState: content.state) else { return print("updateActivity done: no changes detected") }
        
        await activity.update(content)
        if activity.content.state.eventDate != content.state.eventDate {
            scheduleActivityEnd(calendarEventLocation.startDate)
        }
        print("Activity updated successfully!")
    }
    
    private func shouldUpdateActivity(newState: CalendarEventWidgetAttributes.ContentState) -> Bool {
        guard let activity else {
            print("shouldUpdateActivity done: no activity")
            return false
        }
        
        let currentState = activity.content.state
        
        return currentState != newState
    }
    
    func endActivity(dismissalPolicy: ActivityUIDismissalPolicy/*, calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings*/) async {
        print("endActivity called!")
        guard let activity else { return print("endActivity done: no activity") }
//        guard let content = createActivityContent(calendarEventLocation: calendarEventLocation, userSettings: userSettings) else { return print("stopActivity done: createActivityContent returned nil") }
        
        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: activity.content.state.eventDate,
                name: activity.content.state.name,
                temperature: activity.content.state.temperature,
                iconName: activity.content.state.iconName,
                timezoneOffset: activity.content.state.timezoneOffset,
                weatherIcon: activity.content.state.weatherIcon,
                sunrise: activity.content.state.sunrise,
                sunset: activity.content.state.sunset
            ),
            staleDate: nil
        )
        
        await activity.end(content, dismissalPolicy: dismissalPolicy)
        self.activity = nil
        print("endActivity done")
    }
    
    private func createActivityContent(calendarEventLocation: CalendarEventLocation, userSettings: UserSettings) -> ActivityContent<CalendarEventWidgetAttributes.ContentState>? {
        print("createActivityContent called!")
        guard let weatherData = calendarEventLocation.location.weatherData else {
            print("createContentState done: no weatherData")
            return nil
        }

        var eventStartDateWeatherData: HourlyWeather?
        for hour in weatherData.hourly {
            let timeInterval = TimeInterval(hour.dt)
            let weatherDate = Date(timeIntervalSince1970: timeInterval)

            if Calendar.current.isDate(weatherDate, equalTo: calendarEventLocation.startDate, toGranularity: .hour) {
                eventStartDateWeatherData = hour
            }
        }

        guard let eventStartDateWeatherData else {
            print("createContentState done: no weatherData for event start date")
            return nil
        }

        let weatherIcon = eventStartDateWeatherData.weather.first?.icon
        let temp = WeatherService.getConvertedTemperature(from: eventStartDateWeatherData.temp, userSettings: userSettings)
        let icon = WeatherService.getWeatherIcon(weatherIcon)

        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: calendarEventLocation.startDate,
                name: calendarEventLocation.location.name,
                temperature: temp,
                iconName: icon,
                timezoneOffset: weatherData.timezoneOffset,
                weatherIcon: weatherIcon,
                sunrise: weatherData.current.sunrise,
                sunset: weatherData.current.sunset
            ),
            staleDate: nil
        )
        
        return content
    }
    
    private func scheduleActivityEnd(_ date: Date) {
        print("scheduleActivityEnd called!")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: bgTaskIdentifier)
        
        let request = BGAppRefreshTaskRequest(identifier: bgTaskIdentifier)
        request.earliestBeginDate = date
        
        do {
            try BGTaskScheduler.shared.submit(request)
            print("scheduleActivityEnd done: task submitted")
        } catch {
            print("scheduleActivityEnd done: error: \(error)")
        }
    }
    
    private func checkAuthorization() -> Bool {
        isAuthorized = authorizationInfo.areActivitiesEnabled
        return isAuthorized
    }
}
