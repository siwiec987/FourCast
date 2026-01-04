//
//  LocationSearchService.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import Foundation
import MapKit
import OSLog

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    @ObservationIgnored private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "App", category: "LocationSearch")
    
    var query = "" {
        didSet {
            handleSearchFragment(query)
        }
    }
    
    var results: [LocationResult] = []
    var completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        
        super.init()
        
        completer.delegate = self
        completer.pointOfInterestFilter = .excludingAll
        completer.region = MKCoordinateRegion(.world)
        completer.resultTypes = [.address]
    }
    
    private func handleSearchFragment(_ fragment: String) {
        if !fragment.isEmpty {
            self.completer.queryFragment = fragment
        } else {
            self.results = []
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map { result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        }
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
        logger.error("completer error: \(error.localizedDescription)")
    }
    
    struct LocationResult: Identifiable, Hashable {
        var id = UUID()
        var title: String
        var subtitle:String
    }
}
