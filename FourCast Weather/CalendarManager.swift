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
    var events: [EKEvent] = []
    var notAuthorized = true
    private let store = EKEventStore()
    
    init() {
        checkCalendarAuthorization()
        subscribeToNotifications()
    }
    
    func checkCalendarAuthorization() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            store.requestFullAccessToEvents() {success, error in
                if success {
                    self.notAuthorized = false
                    self.fetchEvents()
                    print("Calendar authorized")
                } else {
                    self.notAuthorized = true
                    print("Calendar not authorized")
                }
            }
        case .restricted, .denied, .writeOnly:
            notAuthorized = true
        case .fullAccess:
            notAuthorized = false
            fetchEvents()
        @unknown default:
            fatalError("FatalError: Coś się porządnie popsuło")
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: nil)
    }
    
    @objc
    private func storeChanged(_ notification: Notification) {
        fetchEvents()
    }
    
    private func fetchEvents() {
        let now = Date()
        if let interval = Calendar.current.dateInterval(of: .day, for: now) {
            let predicate = store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: nil)
            let events = store.events(matching: predicate)
            let filteredEvents = events.filter {
                $0.structuredLocation != nil
                && $0.endDate > now
            }
            let sortedEvents = filteredEvents.sorted {
                $0.compareStartDate(with: $1) == .orderedAscending
            }
            
            self.events = sortedEvents
        }
    }
}
