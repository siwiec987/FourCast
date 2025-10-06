//
//  CalendarEventLocation.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 06/10/2025.
//

import Foundation

struct CalendarEventLocation {
    var location: Location
    var startDate: Date
    var travelTime: TimeInterval? // pole "czas ruszać" w szczegółach eventu
}
