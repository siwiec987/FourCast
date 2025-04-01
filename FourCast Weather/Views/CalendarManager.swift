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
    static let shared = CalendarManager()
    
    var events: [EKEvent] = []
   
    private let store = EKEventStore()
    
    private init() {
        checkCalendarAuthorization()
        subscribeToNotifications()
    }
    
    func checkCalendarAuthorization() {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            store.requestFullAccessToEvents() {success, error in
                self.fetchEvents()
                print("Działam szefie")
            }
        case .restricted:
            print("Calendar Restricted")
        case .denied, .writeOnly:
            print("Calendar Denied or Write Only")
        case .fullAccess:
            fetchEvents()
        @unknown default:
            fatalError("FatalError: Coś się porządnie popsuło")
        }
    }
    
    private func subscribeToNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(storeChanged(_:)), name: .EKEventStoreChanged, object: nil)
    }
    
    @objc private func storeChanged(_ notification: Notification) {
        fetchEvents()
    }
    
    private func fetchEvents() {
        if let interval = Calendar.current.dateInterval(of: .day, for: Date()) {
            let predicate = store.predicateForEvents(withStart: interval.start, end: interval.end, calendars: nil)
            let events = store.events(matching: predicate)
            let filteredEvents = events.filter {
                $0.structuredLocation != nil
            }
            let sortedEvents = filteredEvents.sorted {
                $0.compareStartDate(with: $1) == .orderedAscending
            }
            
            self.events = sortedEvents
        }
    }
}
