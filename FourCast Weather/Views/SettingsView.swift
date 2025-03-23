//
//  SettingsView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 18/03/2025.
//

import SwiftUI

struct SettingsView: View {
    @State private var tempUnit = UnitTemperature.init(forLocale: .current)
    @State private var windSpeedUnit = UnitSpeed.init(forLocale: .current)
    
    private var tempUnits: [UnitTemperature] = [.celsius, .fahrenheit, .kelvin]
    private var windSpeedUnits: [UnitSpeed] = [.metersPerSecond, .kilometersPerHour, .milesPerHour]
    
    var body: some View {
        Form {
            Section("Jednostki") {
                Picker("Temperatura", selection: $tempUnit) {
                    ForEach(tempUnits, id: \.self) { unit in
                        Text(unit.symbol)
                    }
                }
                
                Picker("Prędkość wiatru", selection: $windSpeedUnit) {
                    ForEach(windSpeedUnits, id: \.self) {unit in
                        Text(unit.symbol)
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
