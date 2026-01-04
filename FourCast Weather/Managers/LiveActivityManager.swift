//
//  LiveActivityManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 27/08/2025.
//

import ActivityKit
import BackgroundTasks
import Foundation
import OSLog

@MainActor @Observable
class LiveActivityManager {
    @ObservationIgnored private let authorizationInfo = ActivityAuthorizationInfo()
    @ObservationIgnored private var activity: Activity<CalendarEventWidgetAttributes>? = nil
    @ObservationIgnored let bgTaskIdentifier = "LiveActivityManager.scheduleActivityEndRequest"
    
    @ObservationIgnored private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "LiveActivity")
    
    var isAuthorized: Bool {
        authorizationInfo.areActivitiesEnabled
    }
    
    init() {
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
        logger.debug("startActivity called")
        guard activity == nil else { return logger.debug("startActivity done: already started") }
        guard isAuthorized else { return logger.debug("startActivity done: activities not enabled") }
        guard let calendarEventLocation else { return logger.debug("startActivity done: no calendarEventLocation") }
        
        let offset = effectiveStartOffset(offset: userSettings.settings.activityStartOffset, travelTime: calendarEventLocation.travelTime)
        guard shouldBeActive(eventStart: calendarEventLocation.startDate, offset: offset) else { return logger.debug("startActivity done: too early") }
        
        guard let content = createActivityContent(calendarEventLocation: calendarEventLocation, userSettings: userSettings) else { return logger.debug("startActivity done: createActivityContent returned nil") }

        let attributes = CalendarEventWidgetAttributes()
        do {
            activity = try Activity<CalendarEventWidgetAttributes>.request(attributes: attributes, content: content, pushType: nil)
            logger.debug("startActivity done: activity started successfully")
            scheduleActivityEnd(calendarEventLocation.startDate)
        } catch {
            logger.error("startActivity failed: \(error.localizedDescription)")
        }
    }

    private func updateActivity(calendarEventLocation: CalendarEventLocation?, userSettings: UserSettings) async {
        logger.debug("updateActivity called!")
        guard let currentActivity = activity else { return logger.debug("updateActivity done: no activity") }
        guard isAuthorized else {
            await endActivity(dismissalPolicy: .immediate)
            return logger.debug("updateActivity done: activities not enabled")
        }
        guard let calendarEventLocation else {
            await endActivity(dismissalPolicy: .immediate)
            return logger.debug("updateActivity done: no calendarEventLocation")
        }
        
        let offset = effectiveStartOffset(offset: userSettings.settings.activityStartOffset, travelTime: calendarEventLocation.travelTime)
        guard shouldBeActive(eventStart: calendarEventLocation.startDate, offset: offset) else {
            await endActivity(dismissalPolicy: .immediate)
            return logger.debug("updateActivity done: too early")
        }
        
        guard let content = createActivityContent(calendarEventLocation: calendarEventLocation, userSettings: userSettings) else { return logger.debug("updateActivity done: createActivityContent returned nil") }
        guard shouldUpdateActivity(newState: content.state) else { return logger.debug("updateActivity done: no changes detected") }
        
        let oldEventDate = currentActivity.content.state.eventDate
        await currentActivity.update(content)
        if oldEventDate != content.state.eventDate {
            scheduleActivityEnd(content.state.eventDate)
        }
        logger.debug("Activity updated successfully")
    }
    
    private func shouldUpdateActivity(newState: CalendarEventWidgetAttributes.ContentState) -> Bool {
        guard let activity else {
            logger.debug("shouldUpdateActivity done: no activity")
            return false
        }
        
        let currentState = activity.content.state
        return currentState != newState
    }
    
    func endActivity(dismissalPolicy: ActivityUIDismissalPolicy) async {
        logger.debug("endActivity called")
        guard let activity else { return logger.debug("endActivity done: no activity") }
        
        let current = activity.content.state
        let content = ActivityContent(state: current, staleDate: nil)
        
        await activity.end(content, dismissalPolicy: dismissalPolicy)
        self.activity = nil
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: bgTaskIdentifier)
        logger.debug("endActivity done")
    }
    
    private func createActivityContent(calendarEventLocation: CalendarEventLocation, userSettings: UserSettings) -> ActivityContent<CalendarEventWidgetAttributes.ContentState>? {
        logger.debug("createActivityContent called")
        guard let weatherData = calendarEventLocation.location.weatherData else {
            logger.debug("createContent done: no weatherData")
            return nil
        }

        let eventHour = weatherData.hourly.first { hour in
            let date = Date(timeIntervalSince1970: TimeInterval(hour.dt))
            return Calendar.current.isDate(date, equalTo: calendarEventLocation.startDate, toGranularity: .hour)
        }
        
        guard let eventHour, let weatherCondition = eventHour.weather.first else {
            logger.debug("createActivityContent: no hourly data for event hour")
            return nil
        }

        let temp = UnitFormatter.getFormattedTemperature(eventHour.temp, to: userSettings.settings.temperatureUnit)
        let recommendation = ClothingRecommender.recommend(temperature: eventHour.feelsLike, weatherCondition: weatherCondition, uvi: eventHour.uvi, preferences: userSettings.settings.clothingPreferences)

        let eventDay = weatherData.daily.first { day in
            let date = Date(timeIntervalSince1970: TimeInterval(day.dt))
            return Calendar.current.isDate(date, inSameDayAs: calendarEventLocation.startDate)
        }
        
        let content = ActivityContent(
            state: CalendarEventWidgetAttributes.ContentState(
                eventDate: calendarEventLocation.startDate,
                name: calendarEventLocation.location.name,
                temperature: temp,
                weatherCondition: weatherCondition.condition,
                clothingRecommendation: recommendation,
                timezoneOffset: weatherData.timezoneOffset,
                sunrise: eventDay?.sunrise,
                sunset: eventDay?.sunset
            ),
            staleDate: nil
        )
        
        return content
    }
    
    private func scheduleActivityEnd(_ date: Date) {
        logger.debug("scheduleActivityEnd called")
        BGTaskScheduler.shared.cancel(taskRequestWithIdentifier: bgTaskIdentifier)
        
        let request = BGAppRefreshTaskRequest(identifier: bgTaskIdentifier)
        request.earliestBeginDate = date
        
        do {
            try BGTaskScheduler.shared.submit(request)
            logger.debug("scheduleActivityEnd done: task submitted")
        } catch {
            logger.error("scheduleActivityEnd failed: \(error.localizedDescription)")
        }
    }
    
    private func effectiveStartOffset(offset: TimeInterval?, travelTime: TimeInterval?, defaultOffset: TimeInterval = 30*60) -> TimeInterval {
        offset ?? travelTime ?? defaultOffset
    }
    
    private func shouldBeActive(eventStart: Date, offset: TimeInterval) -> Bool {
        Date.now >= eventStart.addingTimeInterval(-offset)
    }
}

