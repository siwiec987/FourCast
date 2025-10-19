//
//  CalendarManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 01/04/2025.
//

import Foundation
import EventKit

@Observable
class CalendarManager {
    @ObservationIgnored private let store = EKEventStore()
    private(set) var isAuthorized = false
    
    init() {}
    
    func getEventIfAuthorized() -> EKEvent? {
        handleAuthorizationStatus()
    }
    
    private func handleAuthorizationStatus() -> EKEvent? {
        var event: EKEvent? = nil
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            store.requestFullAccessToEvents() { success, error in
                if success {
                    self.isAuthorized = true
                    event = self.getEvent()
                } else {
                    self.isAuthorized = false
                }
            }
        case .restricted, .denied, .writeOnly:
            isAuthorized = false
        case .fullAccess:
            isAuthorized = true
            event = getEvent()
        @unknown default:
            isAuthorized = false
        }
        
        return event
    }
    
    private func getEvent() -> EKEvent? {
        let now = Date.now
        let predicate = store.predicateForEvents(withStart: now, end: now.addingTimeInterval(86_400), calendars: nil)
        let events = store.events(matching: predicate)
        let filteredEvents = events.filter {
            !$0.isAllDay &&
            $0.structuredLocation != nil &&
            $0.startDate > now
        }
        let sortedEvents = filteredEvents.sorted {
            $0.compareStartDate(with: $1) == .orderedAscending
        }
        
        return sortedEvents.first
    }
}
