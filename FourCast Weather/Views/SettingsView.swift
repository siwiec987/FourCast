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
                Picker("Temperatura", selection: $userSettings.settings.temperatureUnitString) {
                    Text(UnitTemperature.celsius.symbol)
                        .tag("celsius")
                    
                    Text(UnitTemperature.fahrenheit.symbol)
                        .tag("fahrenheit")
                    
                    Text(UnitTemperature.kelvin.symbol)
                        .tag("kelvin")
                }
                
                Picker("Prędkość wiatru", selection: $userSettings.settings.windSpeedUnitString) {
                    Text(UnitSpeed.kilometersPerHour.symbol)
                        .tag("km/h")
                    
                    Text(UnitSpeed.metersPerSecond.symbol)
                        .tag("m/s")
                    
                    Text(UnitSpeed.milesPerHour.symbol)
                        .tag("mph")
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
    
    init(calendarNotAuthorized: Bool, locationNotAuthorized: Bool) {
        self.calendarNotAuthorized = calendarNotAuthorized
        self.locationNotAuthorized = locationNotAuthorized
    }
}

#Preview {
    SettingsView(calendarNotAuthorized: false, locationNotAuthorized: true)
}


