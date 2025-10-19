//
//  LocationManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation
import CoreLocation

@Observable
class LocationManager: NSObject, CLLocationManagerDelegate {
    @ObservationIgnored private let locationManager = CLLocationManager()
    @ObservationIgnored private var locationContinuation: CheckedContinuation<CLLocationCoordinate2D, Error>? = nil
    
    private(set) var isAuthorized = false
    
    override init() {
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
            locationContinuation?.resume(throwing: LocationManagerError.permissionDenied)
            locationContinuation = nil
        case .authorizedAlways, .authorizedWhenInUse:
            isAuthorized = true
//                locationManager.requestLocation() //requestLocation pobiera lokalizację jakieś 5 sekund
            locationManager.startUpdatingLocation() //to śmiga od razu
        @unknown default:
            locationContinuation?.resume(throwing: LocationManagerError.permissionDenied)
            locationContinuation = nil
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard locationContinuation != nil else { return }
        
        handleAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        
        guard let location = locations.last else {
            locationContinuation?.resume(throwing: LocationManagerError.noLocationFound)
            locationContinuation = nil
            return
        }
        
        locationContinuation?.resume(returning: location.coordinate)
        locationContinuation = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationContinuation?.resume(throwing: error)
        locationContinuation = nil
        print("Błąd pobierania lokalizacji: \(error.localizedDescription)")
    }

    static func getLocationName(for location: CLLocation?) async -> String? {
        await withCheckedContinuation { continuation in
            getLocationName(location: location) { name in
                continuation.resume(returning: name)
            }
        }
    }
    
    static func getLocationName(location: CLLocation?, completion: @escaping (String?) -> Void) {
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
    
    static func getCoordinate(addressString: String, completion: @escaping(CLLocationCoordinate2D, NSError?) -> Void) {
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
