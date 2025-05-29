//
//  CurrentWeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct CurrentWeatherView: View {
    @Environment(UserSettings.self) private var userSettings
    
    let weatherData: WeatherData?
    
    private var temperature: Int {
        if let temp = weatherData?.current.temp {
            return WeatherService.getConvertedTemperature(from: temp, userSettings: userSettings)
        }
        
         return 0
    }
    
    private var feelsLike: Int {
        if let temp = weatherData?.current.feelsLike {
            return WeatherService.getConvertedTemperature(from: temp, userSettings: userSettings)
        }
        
         return 0
    }
    
    var body: some View {
        VStack(spacing: 5) {
            Text("\(temperature)°")
                .font(.system(size: 80, weight: .light))
            
            Text("Odczuwalna: \(feelsLike)°")
        }
        .foregroundStyle(.white)
        .padding(.top, -20)
        .padding(.bottom, 20)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        CurrentWeatherView(weatherData: SampleWeatherData().data)
    }
}
