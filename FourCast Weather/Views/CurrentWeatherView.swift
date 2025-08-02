//
//  CurrentWeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct CurrentWeatherView: View {
    @Environment(UserSettings.self) private var userSettings
    
    let temp: Double
    let feelsLike: Double
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(WeatherService.getConvertedTemperature(from: temp, userSettings: userSettings))°")
                .font(.system(size: 100, weight: .light))
            
            Text("Odczuwalna: \(WeatherService.getConvertedTemperature(from: feelsLike, userSettings: userSettings))°")
        }
        .foregroundStyle(.white)
        .padding(.top, -20)
        .padding(.bottom, 20)
    }
}

#Preview {
    if let data = SampleWeatherData().data {
        CurrentWeatherView(temp: data.current.temp, feelsLike: data.current.feelsLike)
            .background(.blue)
    }
}
