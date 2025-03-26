//
//  SettingsView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var userSettings = UserSettings.shared
    
    //    private var temperatureUnits: [UnitTemperature] = [.celsius, .fahrenheit, .kelvin]
    //    private var windSpeedUnits: [UnitSpeed] = [.metersPerSecond, .kilometersPerHour, .milesPerHour]
    private var temperatureUnits = ["°C", "°F", "K"]
    private var windSpeedUnits = ["m/s", "km/h", "mph"]
    
    var body: some View {
        Form {
            Section("Jednostki") {
                Picker("Temperatura", selection: $userSettings.settings.temperatureUnitString) {
                    ForEach(temperatureUnits, id: \.self) { unit in
                        Text(unit)
                    }
                }
                
                Picker("Prędkość wiatru", selection: $userSettings.settings.windSpeedUnitString) {
                    ForEach(windSpeedUnits, id: \.self) {unit in
                        Text(unit)
                    }
                }
                
                Text("Jednostki")
                Text("Jednostki")
                Text("Jednostki")
            }
            Section("Monek") {
                NavigationLink(destination: Text("Monke inside")) {Text("Monke")}
            }
        }
        .navigationTitle("Ustawienia")
    }
}

#Preview {
    SettingsView()
}

struct UserSettingsModel: Codable {
    var temperatureUnitString: String
    var windSpeedUnitString: String
    
    var temperatureUnit: UnitTemperature {
        switch(temperatureUnitString) {
        case "°C":
            return .celsius
        case "°F":
            return .fahrenheit
        default:
            return .kelvin
        }
    }
    
    var windSpeedUnit: UnitSpeed {
        switch(windSpeedUnitString) {
        case "km/h":
            return .kilometersPerHour
        case "mph":
            return .milesPerHour
        default:
            return .metersPerSecond
        }
    }
}

@Observable
class UserSettings {
    static let shared = UserSettings()
    
    private let saveKey = "userSettings"
    
    var settings: UserSettingsModel {
        didSet {
            saveToUserDefaults()
        }
    }
    
    private init() {
        if let data = UserDefaults.standard.data(forKey: saveKey) {
            if let decoded = try? JSONDecoder().decode(UserSettingsModel.self, from: data) {
                settings = decoded
                return
            }
        }
        
        let tempLocale = UnitTemperature.init(forLocale: .current)
        let speedLocale = UnitSpeed.init(forLocale: .current)
        
        let defaultTemperature = tempLocale == .celsius ? "°C" : tempLocale == .fahrenheit ? "°F" : "K"
        let defaultSpeed = speedLocale == .milesPerHour ? "mph" : "m/s"

        settings = UserSettingsModel(temperatureUnitString: defaultTemperature, windSpeedUnitString: defaultSpeed)
    }
    
    private func saveToUserDefaults() {
        if let encoded = try? JSONEncoder().encode(settings) {
            UserDefaults.standard.set(encoded, forKey: saveKey)
        }
    }
}
