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
    private var locationManager: CLLocationManager?
    
    var location: CLLocation?
    var locationName: String?
    var locationReady = false
    var notAuthorized = true
    var authError = false
    
    override init() {
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
            notAuthorized = true
            throw LocationManagerError.locationRestricted
        case .denied:
            notAuthorized = true
            throw LocationManagerError.locationDenied
        case .authorizedAlways, .authorizedWhenInUse:
            notAuthorized = false
//            locationManager.requestLocation() //requestLocation pobiera lokalizację jakieś 5 sekund
            locationManager.startUpdatingLocation() //to śmiga od razu
            self.locationReady = false
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        do {
            try checkLocationAuthorization()
        } catch {
            authError = true
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let locationManager = locationManager {
            locationManager.stopUpdatingLocation()
        }
        
        guard let location = locations.last else {
            return
        }
        
//        let lastLocationName = self.locationName
        
        self.location = location
        self.getLocationName(location: self.location) { name in
            self.locationName = name
        }
        
        self.locationReady = true
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Błąd pobierania lokalizacji: \(error.localizedDescription)")
    }

    func getLocationName(location: CLLocation?, completion: @escaping (String?) -> Void) {
        guard let safeLocation = location else {
            completion(nil)
            return
        }

        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(safeLocation) { (placemarks, error) in
            if let firstLocation = placemarks?.first, error == nil {
                completion(firstLocation.locality)
            } else {
                completion(nil)
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
    case locationRestricted
    case locationDenied
}
