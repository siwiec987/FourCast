//
//  LocationManager.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    private var locationManager: CLLocationManager?
    
    @Published var location: CLLocation?
    @Published var locationName = ". . ."
    @Published var locationReady = false
    
    override init() {
        super.init()
        self.locationManager = CLLocationManager()
        self.locationManager!.delegate = self
    }
    
    func checkLocationAuthorization() {
        guard let locationManager = self.locationManager else {
            return
        }
        
        switch locationManager.authorizationStatus {
            
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted:
            print("location restricted")
        case .denied:
            print("location denied")
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.requestLocation()
            self.locationReady = false
        @unknown default:
            break
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkLocationAuthorization()
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
    
    
}
