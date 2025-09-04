//
//  CLLocationCoordinate2D+Extension.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 22/08/2025.
//

import Foundation
import CoreLocation

extension CLLocationCoordinate2D: @retroactive Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude &&
        lhs.longitude == lhs.longitude
    }
}
