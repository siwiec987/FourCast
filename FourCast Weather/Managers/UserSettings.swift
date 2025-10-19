//
//  UserSettings.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/04/2025.
//

import Foundation

@Observable
class UserSettings {
    private let saveKey = "userSettings"
    
    var settings: UserSettingsModel {
        didSet {
            saveToUserDefaults()
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(UserSettingsModel.self, from: data) {
                settings = decoded
                return
            }
        }
        
        settings = UserSettingsModel()
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
