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
    @ObservationIgnored private var activity: Activity<CalendarEventWidgetAttributes>? = nil
    @ObservationIgnored let bgTaskIdentifier = "LiveActivityManager.scheduleActivityEndRequest"
    
    private(set) var isAuthorized = false
    
    init() {
        isAuthorized = authorizationInfo.areActivitiesEnabled
        
        for activity in Activity<CalendarEventWidgetAttributes>.activities {
            if activity.activityState == .active {
                self.activity = activity
            }
        }
    }
    
    func startOrUpdateActivity(calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings) async {
        if activity == nil {
            startActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
        } else {
            await updateActivity(calendarEventLocation: calendarEventLocation, userSettings: userSettings)
        }
    }
    
    private func startActivity(calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings) {
        print("startActivity called!")
        guard activity == nil else { return print("startActivity done: already started") }
        guard checkAuthorization() else { return print("startActivity done: activities not enabled") }
        guard let calendarEventLocation else { return print("startActivity done: no calendarEventLocation") }
        
        let activityStartOffset = userSettings.settings.activityStartOffset == .infinity ? calendarEventLocation.travelTime : userSettings.settings.activityStartOffset
        let activityStartDate = calendarEventLocation.startDate.addingTimeInterval(-(activityStartOffset ?? 0))
        guard Date.now >= activityStartDate else { return print("startActivity done: too early") }
        
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
        
        let activityStartOffset = userSettings.settings.activityStartOffset == .infinity ? calendarEventLocation.travelTime : userSettings.settings.activityStartOffset
        let activityStartDate = calendarEventLocation.startDate.addingTimeInterval(-(activityStartOffset ?? 0))
        guard Date.now >= activityStartDate else {
            await endActivity(dismissalPolicy: .immediate)
            BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: bgTaskIdentifier)
            return print("startActivity done: too early")
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
    
    func endActivity(dismissalPolicy: ActivityUIDismissalPolicy) async {
        print("endActivity called!")
        guard let activity else { return print("endActivity done: no activity") }
        
        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: activity.content.state.eventDate,
                name: activity.content.state.name,
                temperature: activity.content.state.temperature,
                weatherCondition: activity.content.state.weatherCondition,
                timezoneOffset: activity.content.state.timezoneOffset,
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

        var eventStartDateWeatherData: WeatherData.HourlyWeather?
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
        
        guard let weatherCondition = eventStartDateWeatherData.weather.first?.condition else {
            print("createContentState done: no weather condition")
            return nil
        }

//        let weatherIcon = eventStartDateWeatherData.weather.first?.icon
        let temp = UnitFormatter.getFormattedTemperature(eventStartDateWeatherData.temp, to: userSettings.settings.temperatureUnit)
//        let icon = WeatherIconMapper.systemIcon(for: weatherIcon)

        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: calendarEventLocation.startDate,
                name: calendarEventLocation.location.name,
                temperature: temp,
                weatherCondition: weatherCondition,
                timezoneOffset: weatherData.timezoneOffset,
                sunrise: weatherData.daily.first?.sunrise,
                sunset: weatherData.daily.first?.sunset
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
