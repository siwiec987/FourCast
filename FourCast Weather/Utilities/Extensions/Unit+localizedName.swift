//
//  UnitTemperature+Extension.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 02/09/2025.
//

import Foundation

extension Unit {
    var localizedName: String {
        let formatter = MeasurementFormatter()
        formatter.unitStyle = .long
        formatter.unitOptions = .providedUnit

        let measurement = Measurement(value: 2, unit: self)
        let formatted = formatter.string(from: measurement).replacingOccurrences(of: "2", with: "").trimmingCharacters(in: .whitespaces)
        
        return formatted + " (\(self.symbol))"
    }
}
