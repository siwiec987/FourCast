//
//  CalendarManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 01/04/2025.
//

import Foundation
import EventKit

@MainActor @Observable
class CalendarManager {
    @ObservationIgnored private let store = EKEventStore()
    private(set) var isAuthorized = false
    
    init() {}
    
    func getEventIfAuthorized() async -> EKEvent? {
        await handleAuthorizationStatus()
    }
    
    private func handleAuthorizationStatus() async -> EKEvent? {
        switch EKEventStore.authorizationStatus(for: .event) {
        case .notDetermined:
            do {
                let result = try await store.requestFullAccessToEvents()
                self.isAuthorized = result
                return result ? getEvent() : nil
            } catch {
                self.isAuthorized = false
                return nil
            }
            
        case .restricted, .denied, .writeOnly:
            isAuthorized = false
            return nil
        case .fullAccess:
            isAuthorized = true
            return getEvent()
        @unknown default:
            isAuthorized = false
            return nil
        }
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
