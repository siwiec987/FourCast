//
//  LocationManagerTests.swift
//  FourCast WeatherTests
//
//  Created by Jakub Siwiec on 04/01/2026.
//

import CoreLocation
import Foundation
import Testing

@testable import FourCast_Weather

@MainActor
struct LocationManagerTests {
    
    @Test("notDetermined -> authorized / denied sets isAuthorized correctly", arguments: [
        CLAuthorizationStatus.restricted,
        CLAuthorizationStatus.denied,
        CLAuthorizationStatus.authorizedAlways,
        CLAuthorizationStatus.authorizedWhenInUse
    ]) func requestAuthorizationIfNotDetermined(status: CLAuthorizationStatus) async throws {
        let mockManager = MockCLLocationManager()
        mockManager.mockAuthorizationStatus = .notDetermined
        mockManager.mockAuthorizationStatusThen = status
        
        let manager = LocationManager(manager: mockManager)
        _ = try? await manager.getCurrentLocationIfAuthorized()
        
        let expected = status == .authorizedAlways || status == .authorizedWhenInUse
        #expect(mockManager.didRequestWhenInUse)
        #expect(manager.isAuthorized == expected)
    }
    
    @Test("denied and restricted immediately throw permissionDenied", arguments: [
        CLAuthorizationStatus.denied,
        CLAuthorizationStatus.restricted
    ])
        func deniedThrows(status: CLAuthorizationStatus) async {
            let mock = MockCLLocationManager()
            mock.mockAuthorizationStatus = status

            let manager = LocationManager(manager: mock)

            await #expect(throws: LocationManagerError.permissionDenied) {
                try await manager.getCurrentLocationIfAuthorized()
            }

            #expect(manager.isAuthorized == false)
        }
    
    @Test("authorized immediately starts updating location")
        func authorizedStartsUpdating() async throws {
            let mockManager = MockCLLocationManager()
            mockManager.mockAuthorizationStatus = .authorizedWhenInUse

            let manager = LocationManager(manager: mockManager)
            let coordinate = try await manager.getCurrentLocationIfAuthorized()

            #expect(mockManager.didStartUpdating)
            #expect(mockManager.didStopUpdating)
            #expect(manager.isAuthorized)
            #expect(coordinate.latitude == mockManager.locations.first?.coordinate.latitude)
        }
    
    @Test("location manager failure resumes continuation with error")
        func didFailWithErrorThrows() async {
            let mockManager = MockCLLocationManager()
            mockManager.mockAuthorizationStatus = .authorizedWhenInUse
            mockManager.shouldFailWithError = NSError(domain: "Test", code: 1)
            let manager = LocationManager(manager: mockManager)
            
            await #expect(throws: Error.self) {
                try await manager.getCurrentLocationIfAuthorized()
            }
        }
    
    @Test("didUpdateLocations with empty array throws noLocationFound")
        func emptyLocationsThrows() async {
            let mockManager = MockCLLocationManager()
            mockManager.mockAuthorizationStatus = .authorizedWhenInUse
            mockManager.locations = []
            let manager = LocationManager(manager: mockManager)

            await #expect(throws: LocationManagerError.noLocationFound.self) {
                try await manager.getCurrentLocationIfAuthorized()
            }
        }
    
    @Test("calling getCurrentLocation twice throws alreadyInUse")
    func alreadyInUseThrows() async {
        let mockManager = HangingCLLocationManager()
        mockManager.mockAuthorizationStatus = .authorizedWhenInUse
        
        let manager = LocationManager(manager: mockManager)
        
        let task = Task {
            try await manager.getCurrentLocationIfAuthorized()
        }
        await Task.yield()
        
        await #expect(throws: LocationManagerError.alreadyInUse.self) {
            try await manager.getCurrentLocationIfAuthorized()
        }
        
        task.cancel()
    }

}
