//
//  LocationsTests.swift
//  FourCast WeatherTests
//
//  Created by Jakub Siwiec on 05/01/2026.
//

import CoreLocation
import Foundation
import Testing

@testable import FourCast_Weather

struct LocationsTests {
    
    @Test("empty directory results in empty locations")
    func emptyDirectoryStartsEmpty() {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: "locationsTest1")
        try? FileManager.default.removeItem(at: tempDir)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let manager = makeLocations(tempDir: tempDir)
        #expect(manager.locations.isEmpty)
    }

    
    @Test("setting locations triggers save and reload restores them")
    func saveAndReloadLocations() {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: "locationsTest2")
        try? FileManager.default.removeItem(at: tempDir)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let manager = makeLocations(tempDir: tempDir)

        let sample = [
            Location(name: "Warsaw", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), role: .current),
            Location(name: "Paris", coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10), role: .additional)
        ]
        manager.locations = sample

        let reloaded = makeLocations(tempDir: tempDir)
        #expect(reloaded.locations == sample)
    }
    
    @Test("updating locations overwrites previous data")
    func updatingLocationsOverwrites() {
        let tempDir = FileManager.default.temporaryDirectory.appending(path: "locationsTest3")
        try? FileManager.default.removeItem(at: tempDir)
        try? FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)

        let manager = makeLocations(tempDir: tempDir)

        let first = [
            Location(name: "Warsaw", coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), role: .current)
        ]
        manager.locations = first

        let second = [
            Location(name: "Paris", coordinate: CLLocationCoordinate2D(latitude: 10, longitude: 10), role: .additional)
        ]
        manager.locations = second

        let reloaded = makeLocations(tempDir: tempDir)
        #expect(reloaded.locations == second)
    }
    
    
    
    private func makeLocations(tempDir: URL) -> Locations {
        Locations(directory: tempDir)
    }
}
