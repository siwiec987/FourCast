//
//  MockCLLocationManager.swift
//  FourCast WeatherTests
//
//  Created by Jakub Siwiec on 04/01/2026.
//

import CoreLocation
import Foundation

class MockCLLocationManager: CLLocationManager {
    var mockAuthorizationStatus: CLAuthorizationStatus = .notDetermined
    var mockAuthorizationStatusThen: CLAuthorizationStatus = .authorizedWhenInUse
    
    var didRequestWhenInUse = false
    var didStartUpdating = false
    var didStopUpdating = false
    
    var locations = [CLLocation(latitude: 51, longitude: 23)]
    var shouldFailWithError: Error? = nil
    
    override var authorizationStatus: CLAuthorizationStatus {
        mockAuthorizationStatus
    }
    
    override func requestWhenInUseAuthorization() {
        didRequestWhenInUse = true
        mockAuthorizationStatus = mockAuthorizationStatusThen
        
        delegate?.locationManagerDidChangeAuthorization?(self)
    }
    
    override func startUpdatingLocation() {
        didStartUpdating = true
        
        if let error = shouldFailWithError {
            delegate?.locationManager?(self, didFailWithError: error)
        } else {
            delegate?.locationManager?(self, didUpdateLocations: locations)
        }
    }
    
    override func stopUpdatingLocation() {
        didStopUpdating = true
    }
}

final class HangingCLLocationManager: MockCLLocationManager {
    override func startUpdatingLocation() {
        didStartUpdating = true
    }
}
