//
//  MockEKEventStore.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 04/01/2026.
//

import EventKit

final class MockEKEventStore: EKEventStore {
    static var authorizationStatusToReturn: EKAuthorizationStatus = .notDetermined
    var requestAccessResult: Result<Bool, Error> = .success(true)
    var eventsToReturn: [EKEvent] = []

    override class func authorizationStatus(for entityType: EKEntityType) -> EKAuthorizationStatus {
        authorizationStatusToReturn
    }

    override func requestFullAccessToEvents() async throws -> Bool {
        try requestAccessResult.get()
    }

    override func predicateForEvents(
        withStart startDate: Date,
        end endDate: Date,
        calendars: [EKCalendar]?
    ) -> NSPredicate {
        NSPredicate(value: true)
    }

    override func events(matching predicate: NSPredicate) -> [EKEvent] {
        eventsToReturn
    }
}
