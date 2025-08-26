//
//  FourCast_WeatherApp.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

@main
struct FourCast_WeatherApp: App {
    @State private var userSettings = UserSettings()
    
    var body: some Scene {
        WindowGroup {
            ContentView(userSettings: userSettings)
                .preferredColorScheme(.dark)
        }
        .environment(userSettings)
    }
}
