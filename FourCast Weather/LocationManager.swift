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
    static let shared = LocationManager()
    
    private var locationManager: CLLocationManager?
    
    var location: CLLocation?
    var locationName = ". . ."
    var locationReady = false
    
    private override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
    }
    
    func checkLocationAuthorization() throws {
        guard let locationManager = self.locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location restricted")
            throw LocationManagerError.locationRestricted
        case .denied:
            print("location denied")
            throw LocationManagerError.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            self.locationReady = false
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        do {
            try checkLocationAuthorization()
        } catch {
            print("aaa")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }
        
        self.location = location
        self.getLocationName { name in
            self.locationName = name ?? "Nieznana lokalizacja"
        }
        
        self.locationReady = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Błąd pobierania lokalizacji: \(error.localizedDescription)")
    }

    private func getLocationName(completion: @escaping (String?) -> Void) {
        guard let location = self.location else {
            completion(nil)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let firstLocation = placemarks?.first, error == nil {
                completion(firstLocation.locality)
            } else {
                completion(nil)
            }
        }
    }
    
    func getCoordinate(addressString: String, completion: @escaping(CLLocationCoordinate2D, NSError?) -> Void) {
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
    case locationRestricted
    case locationDenied
}
