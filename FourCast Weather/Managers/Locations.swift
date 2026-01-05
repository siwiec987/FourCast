//
//  Locations.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/03/2025.
//

import Foundation

@Observable
class Locations {
    private let fileURL: URL
    
    var locations: [Location] = [] {
        didSet {
            saveToJSON()
        }
    }
    
    init(directory: URL = .documentsDirectory) {
        self.fileURL = directory.appending(path: "locations")
        loadFromJSON()
    }
    
    private func saveToJSON() {
        if let encoded = try? JSONEncoder().encode(locations) {
            try? encoded.write(to: fileURL, options: [.atomic, .completeFileProtection])
        }
    }
    
    private func loadFromJSON() {
        if let data = try? Data(contentsOf: fileURL) {
            if let decoded = try? JSONDecoder().decode([Location].self, from: data) {
                locations = decoded
            }
        }
    }
}
