//
//  BackgroundView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/05/2025.
//

import SwiftUI

struct BackgroundView: View {
    var weatherData: WeatherData?
    
    static let weatherGradients: [String: [Color]] = [
        "clearSkyDay": [Color(red: 0.40, green: 0.80, blue: 1.00), Color(red: 0.70, green: 0.90, blue: 1.00)],
        "clearSkyNight": [Color(red: 0.18, green: 0.22, blue: 0.36), Color(red: 0.08, green: 0.11, blue: 0.25)],
        
        "fewCloudsDay": [Color(red: 0.55, green: 0.75, blue: 0.95), Color(red: 0.85, green: 0.90, blue: 0.95)],
        "fewCloudsNight": [Color(red: 0.16, green: 0.20, blue: 0.30), Color(red: 0.12, green: 0.14, blue: 0.22)],
        
        "scatteredCloudsDay": [Color(red: 0.60, green: 0.70, blue: 0.85), Color(red: 0.80, green: 0.85, blue: 0.90)],
        "scatteredCloudsNight": [Color(red: 0.14, green: 0.18, blue: 0.26), Color(red: 0.10, green: 0.12, blue: 0.20)],
        
        "brokenCloudsDay": [Color(red: 0.50, green: 0.60, blue: 0.75), Color(red: 0.70, green: 0.75, blue: 0.80)],
        "brokenCloudsNight": [Color(red: 0.12, green: 0.15, blue: 0.22), Color(red: 0.08, green: 0.10, blue: 0.16)],
        
        "showerRainDay": [Color(red: 0.35, green: 0.50, blue: 0.65), Color(red: 0.60, green: 0.65, blue: 0.70)],
        "showerRainNight": [Color(red: 0.10, green: 0.12, blue: 0.18), Color(red: 0.06, green: 0.08, blue: 0.12)],
        
        "rainDay": [Color(red: 0.40, green: 0.55, blue: 0.70), Color(red: 0.65, green: 0.70, blue: 0.75)],
        "rainNight": [Color(red: 0.09, green: 0.11, blue: 0.16), Color(red: 0.05, green: 0.06, blue: 0.10)],
        
        "thunderStormDay": [Color(red: 0.30, green: 0.35, blue: 0.45), Color(red: 0.50, green: 0.55, blue: 0.60)],
        "thunderStormNight": [Color(red: 0.06, green: 0.08, blue: 0.12), Color(red: 0.02, green: 0.03, blue: 0.06)],
        
        "snowDay": [Color(red: 0.85, green: 0.90, blue: 0.95), Color(red: 0.95, green: 0.97, blue: 1.00)],
        "snowNight": [Color(red: 0.25, green: 0.30, blue: 0.40), Color(red: 0.15, green: 0.20, blue: 0.28)],
        
        "mistDay": [Color(red: 0.75, green: 0.75, blue: 0.80), Color(red: 0.85, green: 0.85, blue: 0.88)],
        "mistNight": [Color(red: 0.20, green: 0.22, blue: 0.26), Color(red: 0.12, green: 0.13, blue: 0.16)]
    ]

    
    private var currentBackground: [Color] {
        let defaultColors: [Color] = [.gray, .gray.mix(with: .black, by: 0.3)]
        guard let weatherData, let icon = weatherData.current.weather.first?.icon else {
            return BackgroundView.weatherGradients["clearSkyDay"] ?? defaultColors
        }
        
        var gradientKey: String
        
        switch(icon.dropLast()) {
        case "01":
            gradientKey = "clearSky"
        case "02":
            gradientKey = "fewClouds"
        case "03":
            gradientKey = "scatteredClouds"
        case "04":
            gradientKey = "brokenClouds"
        case "09":
            gradientKey = "showerRain"
        case "10":
            gradientKey = "rain"
        case "11":
            gradientKey = "thunderStorm"
        case "13":
            gradientKey = "snow"
        case "50":
            gradientKey = "mist"
        default:
            gradientKey = "clearSky"
        }
        
        gradientKey += icon.hasSuffix("d") ? "Day" : "Night"
        return BackgroundView.weatherGradients[gradientKey] ?? defaultColors
    }
    
    var body: some View {
        LinearGradient(colors: currentBackground, startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView(weatherData: SampleWeatherData().data!)
}
