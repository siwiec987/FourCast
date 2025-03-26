//
//  CurrentWeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct CurrentWeatherView: View {
    @State private var userSettings = UserSettings.shared
    let weatherData: WeatherData?
    var locationName: String
    
    private var temperature: Int {
        if let temp = weatherData?.current.temp {
            return Int(Measurement(value: temp, unit: UnitTemperature.kelvin).converted(to: userSettings.settings.temperatureUnit).value)
        }
        
         return 0
    }
    
    private var feelsLike: Int {
        if let temp = weatherData?.current.feelsLike {
            return Int(Measurement(value: temp, unit: UnitTemperature.kelvin).converted(to: userSettings.settings.temperatureUnit).value)
        }
        
         return 0
    }
    
    var body: some View {
        VStack(spacing: 5) {
//            Text(locationName)
//                .bold()
            
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
        CurrentWeatherView(weatherData: SampleWeatherData().data, locationName: "aaaa")
    }
}
