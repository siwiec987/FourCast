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
    @State private var userSettings = UserSettings.shared
    
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
    
    private var temperatureUnits = ["°C", "°F", "K"]
    private var windSpeedUnits = ["m/s", "km/h", "mph"]
    
    
    var body: some View {
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
    
    init(calendarNotAuthorized: Bool, locationNotAuthorized: Bool) {
        self.calendarNotAuthorized = calendarNotAuthorized
        self.locationNotAuthorized = locationNotAuthorized
    }
}

#Preview {
    SettingsView(calendarNotAuthorized: false, locationNotAuthorized: true)
}


