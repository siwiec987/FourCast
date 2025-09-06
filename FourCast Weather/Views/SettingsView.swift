//
//  SettingsView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @Environment(UserSettings.self) private var userSettings
    
    let calendarAuthorized: Bool
    let locationAuthorized: Bool
    let liveActivitiesAuthorized: Bool
    
    var permissionProblems: [AppPermissionProblem] {
        var result: [AppPermissionProblem] = []
        
        if !locationAuthorized {
            result.append(.location)
        }
        if !calendarAuthorized {
            result.append(.calendar)
        }
        
        if calendarAuthorized && !liveActivitiesAuthorized {
            result.append(.liveActivity)
        }
        
        return result
    }
    
    let temperatureUnits: [UnitTemperature] = [.celsius, .fahrenheit, .kelvin]
    let speedUnits: [UnitSpeed] = [.metersPerSecond, .kilometersPerHour, .milesPerHour, .knots]
    let pressureUnits: [UnitPressure] = [.millibars, .inchesOfMercury, .millimetersOfMercury, .hectopascals, .kilopascals]
    let distanceUnits: [UnitLength] = [.miles, .kilometers]
    
    var body: some View {
        @Bindable var userSettings = userSettings
        Form {
            if !permissionProblems.isEmpty {
                Section("Uprawnienia") {
                    VStack {
                        ForEach(permissionProblems, id: \.self) { problem in
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
            
            if liveActivitiesAuthorized && calendarAuthorized {
                Section {
                    Picker("Czas do wydarzenia z kalendarza", selection: $userSettings.settings.activityStartOffset) {
                        ForEach(ActivityStartOffsetOption.allCases, id: \.self) { offsetOption in
                            Text(offsetOption.displayName)
                                .tag(offsetOption.offset)
                        }
                    }
                } header: {
                    Text("Wydarzenia na żywo")
                } footer: {
                    Text("Czas pozostały do najbliższego wydarzenia w kalendarzu. Jeśli w tym czasie użyjesz aplikacji, aplikacja uruchomi wydarzenie na żywo")
                }
            }
            
            Section("Rekomendacje") {
                NavigationLink(destination: Text("Tu będą opcje rekomendacji")) {
                    Text("Dostosuj rekomendacje")
                }
            }
        }
        .navigationTitle("Ustawienia")
    }
    
    enum ActivityStartOffsetOption: String, CaseIterable, Codable {
        static let `default`: ActivityStartOffsetOption = .thirtyMinutesBefore
        
        case fiveMinutesBefore = "5 minut przed"
        case tenMinutesBefore = "10 minut przed"
        case fifteenMinutesBefore = "15 minut przed"
        case thirtyMinutesBefore = "30 minut przed"
        case oneHourBefore = "1 godzina przed"
        case twoHoursBefore = "2 godziny przed"
        case fourHoursBefore = "4 godziny przed"
        case timeToLeave = "Czas ruszać"
        
        var displayName: String {
            self.rawValue
        }
        
        var offset: TimeInterval {
            switch self {
            case .fiveMinutesBefore: 5 * 60
            case .tenMinutesBefore: 10 * 60
            case .fifteenMinutesBefore: 15 * 60
            case .thirtyMinutesBefore: 30 * 60
            case .oneHourBefore: 60 * 60
            case .twoHoursBefore: 120 * 60
            case .fourHoursBefore: 240 * 60
            case .timeToLeave: .infinity
            }
        }
    }
}

#Preview {
    SettingsView(calendarAuthorized: true, locationAuthorized: false, liveActivitiesAuthorized: false)
        .preferredColorScheme(.dark)
        .environment(UserSettings())
}


