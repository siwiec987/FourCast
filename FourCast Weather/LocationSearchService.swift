//
//  LocationSearchService.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import Foundation
import MapKit

@Observable
class LocationSearchService: NSObject, MKLocalSearchCompleterDelegate {
    var query = "" {
        didSet {
            handleSearchFragment(query)
        }
    }
    
    var results: [LocationResult] = []
    var status: SearchStatus = .idle
    var completer: MKLocalSearchCompleter
    
    override init() {
        completer = MKLocalSearchCompleter()
        
        super.init()
        
        completer.delegate = self
        completer.pointOfInterestFilter = .excludingAll
        completer.region = MKCoordinateRegion(.world)
        completer.resultTypes = [/*.query,*/ .address]
    }
    
    private func handleSearchFragment(_ fragment: String) {
        self.status = .searching
        
        if !fragment.isEmpty {
            self.completer.queryFragment = fragment
        } else {
            self.status = .idle
            self.results = []
        }
    }
    
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        self.results = completer.results.map {result in
            LocationResult(title: result.title, subtitle: result.subtitle)
        }
        
        self.status = .result
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
//        self.status = .error(error.localizedDescription)
        print("Błąd uzupełniania: \(error.localizedDescription)")
    }
}

struct LocationResult: Identifiable, Hashable {
    var id = UUID()
    var title: String
    var subtitle:String
}

enum SearchStatus: Equatable {
    case idle
    case searching
    case error(String)
    case result
}
