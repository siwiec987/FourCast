//
//  Date+Extensions.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation

extension Date {
    static func getWeekday(from timestamp: Int, with timezoneOffset: Int = 0, format: String = "EEEE", locale: Locale = Locale(identifier: "pl_PL")) -> String {
        let timeInterval = TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        return dateFormatter.string(from: date)
    }
    
    static func getFormattedHour(from timestamp: Int, with timezoneOffset: Int = 0, format: String = "HH:mm") -> String {
        let timeInterval = TimeInterval(timestamp)
        let utcDate = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: timezoneOffset)
        formatter.dateFormat = format
        
        return formatter.string(from: utcDate)
    }
}
