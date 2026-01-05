//
//  LocationManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation
import CoreLocation
import OSLog

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored private var locationManager: CLLocationManager
    @ObservationIgnored private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>? = nil
    @ObservationIgnored private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "Location")
    
    private(set) var isAuthorized = false
    
    init(manager: CLLocationManager = CLLocationManager()) {
        self.locationManager = manager
        
        super.init()
        self.locationManager.delegate = self
    }
    
    @MainActor func getCurrentLocationIfAuthorized() async throws -> CLLocationCoordinate2D {
        guard locationContinuation == nil else { throw LocationManagerError.alreadyInUse }
        
        return try await withCheckedThrowingContinuation { continuation in
            locationContinuation = continuation
            
            handleAuthorizationStatus()
        }
    }
    
    private func handleAuthorizationStatus() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            isAuthorized = false
            finishWithError(LocationManagerError.permissionDenied)
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
//                locationManager.requestLocation() //requestLocation pobiera lokalizację jakieś 5 sekund
            locationManager.startUpdatingLocation() //to śmiga od razu
        @unknown default:
            finishWithError(LocationManagerError.permissionDenied)
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard locationContinuation != nil else { return }
        
        handleAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        guard let location = locations.last else {
            finishWithError(LocationManagerError.noLocationFound)
            return
        }
        
        finishWithSuccess(location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        finishWithError(error)
        logger.error("locationManager error: \(error.localizedDescription)")
    }
    
    private func finishWithError(_ error: Error) {
        guard let continuation = locationContinuation else { return }
        continuation.resume(throwing: error)
        
        locationContinuation = nil
    }
    
    private func finishWithSuccess(_ coordinate: CLLocationCoordinate2D) {
        guard let continuation = locationContinuation else { return }
        continuation.resume(returning: coordinate)
        
        locationContinuation = nil
    }

    static func getLocationName(for location: CLLocation?) async -> String? {
        await withCheckedContinuation { continuation in
            getLocationName(location: location) { name in
                continuation.resume(returning: name)
            }
        }
    }
    
    static func getLocationName(location: CLLocation?, completion: @Sendable @escaping (String?) -> Void) {
        guard let location else {
            completion(nil)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let first = placemarks?.first, error == nil {
                completion(first.locality)
            } else {
                completion(nil)
            }
        }
    }
    
    static func getCoordinate(address: String) async throws -> CLLocationCoordinate2D {
        try await withCheckedThrowingContinuation { continuation in
            getCoordinate(addressString: address) { coordinate, error in
                if error != nil {
                    continuation.resume(throwing: LocationManagerError.noLocationFound)
                } else {
                    continuation.resume(returning: coordinate)
                }
            }
        }
    }
    
    static func getCoordinate(addressString: String, completion: @Sendable @escaping (CLLocationCoordinate2D, NSError?) -> Void) {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let placemark = placemarks?.first, error == nil {
                let location = placemark.location!
                
                completion(location.coordinate, nil)
                return
            }
            
            completion(kCLLocationCoordinate2DInvalid, error as NSError?)
        }
    }
    
}

enum LocationManagerError: Error {
    case permissionDenied
    case noLocationFound
    case alreadyInUse
}
