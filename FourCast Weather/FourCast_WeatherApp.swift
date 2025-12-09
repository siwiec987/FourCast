//
//  FourCast_WeatherApp.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

@main
struct FourCast_WeatherApp: App {
    @AppStorage("firstLaunch") private var firstLaunch = true
//    @State private var firstLaunch = true
    
    private let userSettings = UserSettings()
    private let liveActivityManager = LiveActivityManager()
    
    var body: some Scene {
        WindowGroup {
            WeatherTabView(userSettings: userSettings, liveActivityManager: liveActivityManager)
                .sheet(isPresented: $firstLaunch) {
                    ClothingPreferencesConfig
                }
                .preferredColorScheme(.dark)
        }
        .environment(userSettings)
        .backgroundTask(.appRefresh(liveActivityManager.bgTaskIdentifier)) {
            await liveActivityManager.endActivity(dismissalPolicy: .immediate)
        }
    }
    
    
    var ClothingPreferencesConfig: some View {
        NavigationStack {
            ClothingPreferencesConfigView(
                navigationTitle: "Cześć!",
                navigationTitleDisplayMode: .large,
                userSettings: userSettings
            )
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Gotowe") {
                        firstLaunch = false
                    }
                }
            }
        }
    }
}
