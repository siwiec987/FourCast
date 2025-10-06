//
//  Locations.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/03/2025.
//

import Foundation

@Observable
class Locations {
    private let filePath = "locations"
    
    var locations: [Location] = [] {
        didSet {
            saveToJSON()
        }
    }
    
    private var additionalLocations: [Location] {
        locations.filter { $0.role == .additional }
    }
    
    init() {
        loadFromJSON()
    }
    
    private func saveToJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let encoded = try? JSONEncoder().encode(locations) {
            try? encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
        }
    }
    
    private func loadFromJSON() {
        let fileURL = URL.documentsDirectory.appending(path: filePath)
        
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([Location].self, from: data) {
//                locations.append(contentsOf: decoded)
                locations = decoded
            }
        }
    }
}
