//
//  Date+Extensions.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation

extension Date {
    static func getWeekday(from timestamp: Int, format: String = "EEEE", locale: Locale = Locale(identifier: "pl_PL")) -> String {
        let timeInterval = TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        dateFormatter.locale = locale
        return dateFormatter.string(from: date)
    }
}
