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
//    private var events: [EKEvent] = []
    var notAuthorized = true
    
//    var firstEvent: EKEvent? {
//        events.first { $0.startDate > .now }
//    }
    
    init() {
//        handleAuthorizationStatus()
//        subscribeToNotifications()
    }
    
    func getEventIfAuthorized() -> EKEvent? {
        handleAuthorizationStatus()
    }
    
    private func handleAuthorizationStatus() -> EKEvent? {
        var event: EKEvent? = nil
        
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            store.requestFullAccessToEvents() { success, error in
                if success {
                    self.notAuthorized = false
                    event = self.getEvent()
                } else {
                    self.notAuthorized = true
                }
            }
        case .restricted, .denied, .writeOnly:
            notAuthorized = true
        case .fullAccess:
            notAuthorized = false
            event = getEvent()
        @unknown default:
            fatalError("FatalError: Coś się porządnie popsuło")
        }
        
        return event
    }
    
//    private func subscribeToNotifications() {
//        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: nil)
//    }
//    
//    @objc
//    private func storeChanged(_ notification: Notification) {
//        handleAuthorizationStatus()
//    }
    
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
