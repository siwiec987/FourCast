//
//  CalendarManagerTests.swift
//  FourCast WeatherTests
//
//  Created by Jakub Siwiec on 04/01/2026.
//

import EventKit
import Foundation
import Testing

@testable import FourCast_Weather

@MainActor
struct CalendarManagerTests {

    @Test("authorization sets isAuthorized correctly", arguments: [
        EKAuthorizationStatus.notDetermined,
        EKAuthorizationStatus.restricted,
        EKAuthorizationStatus.denied,
        EKAuthorizationStatus.fullAccess,
        EKAuthorizationStatus.writeOnly
    ]) func authorizationStatus(status: EKAuthorizationStatus) async {
        MockEKEventStore.authorizationStatusToReturn = status
        
        let store = MockEKEventStore()
        store.requestAccessResult = .success(false) // simulates denial if notDetermined
        
        let manager = CalendarManager(store: store)
        _ = await manager.getEventIfAuthorized()
    
        let expected = status == .fullAccess
        
        #expect(manager.isAuthorized == expected)
    }
    
    @Test("notDetermined granted and denied", arguments: [
        Result<Bool, Error>.success(true),
        Result<Bool, Error>.success(false)
    ]) func notDetermined(accessResult: Result<Bool, Error>) async {
        MockEKEventStore.authorizationStatusToReturn = .notDetermined
        
        let store = MockEKEventStore()
        store.requestAccessResult = accessResult
        
        let manager = CalendarManager(store: store)
        _ = await manager.getEventIfAuthorized()
        
        let expected = try! accessResult.get()
        #expect(manager.isAuthorized == expected)
    }
    
    @Test func notDeterminedFails() async {
        MockEKEventStore.authorizationStatusToReturn = .notDetermined

        let store = MockEKEventStore()
        store.requestAccessResult = .failure(NSError(domain: "Test", code: 1))

        let manager = CalendarManager(store: store)
        let result = await manager.getEventIfAuthorized()

        #expect(manager.isAuthorized == false)
        #expect(result == nil)
    }
    
    @Test func fullAccessNoEvents() async {
        MockEKEventStore.authorizationStatusToReturn = .fullAccess

        let store = MockEKEventStore()
        store.eventsToReturn = []

        let manager = CalendarManager(store: store)
        let result = await manager.getEventIfAuthorized()

        #expect(manager.isAuthorized == true)
        #expect(result == nil)
    }
    
    @Test func filtersInvalidEvents() async {
        MockEKEventStore.authorizationStatusToReturn = .fullAccess
        let store = MockEKEventStore()

        let now = Date()

        let allDay = EKEvent(eventStore: store)
        allDay.startDate = now.addingTimeInterval(3600)
        allDay.isAllDay = true

        let noLocation = EKEvent(eventStore: store)
        noLocation.startDate = now.addingTimeInterval(7200)
        noLocation.isAllDay = false

        let past = EKEvent(eventStore: store)
        past.startDate = now.addingTimeInterval(-3600)
        past.isAllDay = false
        past.structuredLocation = EKStructuredLocation(title: "Past")

        store.eventsToReturn = [allDay, noLocation, past]

        let manager = CalendarManager(store: store)
        let result = await manager.getEventIfAuthorized()

        #expect(result == nil)
    }

    @Test func nearestValidEvent() async {
        MockEKEventStore.authorizationStatusToReturn = .fullAccess
        
        let store = MockEKEventStore()
        let now = Date()
        
        let sooner = EKEvent(eventStore: store)
        sooner.startDate = now.addingTimeInterval(3600)
        sooner.isAllDay = false
        sooner.structuredLocation = EKStructuredLocation(title: "Sooner")

        let later = EKEvent(eventStore: store)
        later.startDate = now.addingTimeInterval(7200)
        later.isAllDay = false
        later.structuredLocation = EKStructuredLocation(title: "Later")

        store.eventsToReturn = [later, sooner]
        
        let manager = CalendarManager(store: store)
        let result = await manager.getEventIfAuthorized()
        
        #expect(result == sooner)
    }
    
    @Test func validAndInvalidEvents() async {
        MockEKEventStore.authorizationStatusToReturn = .fullAccess
        let store = MockEKEventStore()

        let now = Date()

        let invalid = EKEvent(eventStore: store)
        invalid.startDate = now.addingTimeInterval(3600)
        invalid.isAllDay = true

        let valid = EKEvent(eventStore: store)
        valid.startDate = now.addingTimeInterval(7200)
        valid.isAllDay = false
        valid.structuredLocation = EKStructuredLocation(title: "Valid")

        store.eventsToReturn = [invalid, valid]

        let manager = CalendarManager(store: store)
        let result = await manager.getEventIfAuthorized()

        #expect(result === valid)
    }

}
