//
//  SettingsView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/03/2025.
//

import SwiftUI

struct Problem {
    let name: String
    let description: String
    let imageName: String
}

struct SettingsView: View {
    @Environment(UserSettings.self) private var userSettings
    
    @State private var activityDate: Date = .now
    
    var calendarNotAuthorized: Bool
    var locationNotAuthorized: Bool
    
    var permissionProblems: [AppPermissionProblem] {
        var result: [AppPermissionProblem] = []
        
        if calendarNotAuthorized {
            result.append(.calendar)
        }
        if locationNotAuthorized {
            result.append(.location)
        }
        
        return result
    }
    
    let temperatureUnits: [UnitTemperature] = [.celsius, .fahrenheit, .kelvin]
    let speedUnits: [UnitSpeed] = [.metersPerSecond, .kilometersPerHour, .milesPerHour, .knots]
    let pressureUnits: [UnitPressure] = [.millibars, .inchesOfMercury, .millimetersOfMercury, .hectopascals, .kilopascals]
    let distanceUnits: [UnitLength] = [.miles, .kilometers]
    let activityStartOffsets: [(title: String, offset: TimeInterval)] = [
        ("W chwili wydarzenia", 0),
        ("5 minut przed", -5 * 60),
        ("10 minut przed", -10 * 60),
        ("15 minut przed", -15 * 60),
        ("30 minut przed", -30 * 60),
        ("godzinę przed", -60 * 60),
        ("godzinę i 30 minut przed", -90 * 60),
        ("2 godziny przed", -120 * 60),
        ("3 godziny przed", -180 * 60)
    ]
    
    var body: some View {
        @Bindable var userSettings = userSettings
        Form {
            if !permissionProblems.isEmpty {
                Section("Uprawnienia") {
                    VStack {
                        ForEach(permissionProblems, id: \.name) { problem in
                            PermissionProblemView(problem: problem)
                        }
                    }
                }
            }
            
            Section("Jednostki") {
                Picker("Temperatura", selection: $userSettings.settings.temperatureUnit) {
                    ForEach(temperatureUnits, id: \.self) { unit in
                        Text(unit.name)
                            .tag(unit)
                    }
                }
                
                Picker("Wiatr", selection: $userSettings.settings.windSpeedUnit) {
                    ForEach(speedUnits, id: \.self) { unit in
                        Text(unit.name)
                            .tag(unit)
                    }
                }
                
                Picker("Ciśnienie", selection: $userSettings.settings.pressureUnit) {
                    ForEach(pressureUnits, id: \.self) { unit in
                        Text(unit.name)
                            .tag(unit)
                    }
                }
                
                Picker("Odległość", selection: $userSettings.settings.distanceUnit) {
                    ForEach(distanceUnits, id: \.self) { unit in
                        Text(unit.name)
                            .tag(unit)
                    }
                }
            }
            
            Section("Wydarzenia na żywo") {
                Picker("Czas do wydarzenia z kalendarza", selection: $userSettings.settings.activityStartOffset) {
                    ForEach(activityStartOffsets, id: \.offset) { offset in
                        Text(offset.title)
                            .tag(offset.offset)
                    }
                }
            }
        }
        .navigationTitle("Ustawienia")
    }
    
    init(calendarNotAuthorized: Bool, locationNotAuthorized: Bool) {
        self.calendarNotAuthorized = calendarNotAuthorized
        self.locationNotAuthorized = locationNotAuthorized
    }
}

#Preview {
    SettingsView(calendarNotAuthorized: false, locationNotAuthorized: true)
}


