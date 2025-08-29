//
//  FourCast_WeatherApp.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

@main
struct FourCast_WeatherApp: App {
    private let userSettings = UserSettings()
    private let liveActivityManager = LiveActivityManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView(userSettings: userSettings, liveActivityManager: liveActivityManager)
                .preferredColorScheme(.dark)
        }
        .environment(userSettings)
        .backgroundTask(.appRefresh(liveActivityManager.bgTaskIdentifier)) {
            print("entered backgroundTask")
            await liveActivityManager.endActivity(dismissalPolicy: .immediate)
        }
    }
}
