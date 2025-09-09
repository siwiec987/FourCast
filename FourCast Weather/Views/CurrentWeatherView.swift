//
//  CurrentWeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct CurrentWeatherView: View {
    @Environment(UserSettings.self) private var userSettings
    
    let name: String
    let temp: Double
    let feelsLike: Double
    
    var body: some View {
        VStack(spacing: 5) {
            VStack(spacing: -10) {
                Text(name)
                    .font(.title)
                
                Text(UnitFormatter.getFormattedTemperature(temp, to: userSettings.settings.temperatureUnit))
                    .font(.system(size: 100, weight: .light))
            }
            
            Text("Odczuwalna: \(UnitFormatter.getFormattedTemperature(feelsLike, to: userSettings.settings.temperatureUnit))")
        }
        .foregroundStyle(.white)
        .shadow(radius: 5)
        .padding(10)
    }
}

#Preview {
    if let data = SampleWeatherData().data {
        CurrentWeatherView(name: "Bieruck", temp: data.current.temp, feelsLike: data.current.feelsLike)
//            .background(.blue)
            .environment(UserSettings())
    }
}
