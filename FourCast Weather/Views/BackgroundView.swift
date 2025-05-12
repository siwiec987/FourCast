//
//  BackgroundView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/05/2025.
//

import SwiftUI

struct BackgroundView: View {
    var weatherData: WeatherData?
    
    let sunnyMorning = [Color(red: 0.99, green: 0.84, blue: 0.65), Color(red: 0.53, green: 0.80, blue: 0.98)]
    let partlyCloudyDay = [Color(red: 0.72, green: 0.85, blue: 0.95), Color(red: 0.86, green: 0.86, blue: 0.90)]
    let rainyDay = [Color(red: 0.55, green: 0.65, blue: 0.75), Color(red: 0.35, green: 0.45, blue: 0.55)]
    let foggyMorning = [Color(red: 0.85, green: 0.85, blue: 0.85), Color(red: 0.65, green: 0.65, blue: 0.65)]
    let clearSunset = [Color(red: 1.0, green: 0.67, blue: 0.35), Color(red: 0.55, green: 0.27, blue: 0.68)]
    let clearNight = [Color(red: 0.18, green: 0.22, blue: 0.36), Color(red: 0.08, green: 0.11, blue: 0.25)]
    let stormyNight = [Color(red: 0.25, green: 0.25, blue: 0.35), Color(red: 0.10, green: 0.10, blue: 0.15)]
    
    private var currentBackground: [Color] {
        guard let weatherData else { return sunnyMorning }
        
        let now = Date.now
        let sunrise = Date(timeIntervalSince1970: TimeInterval(weatherData.current.sunrise))
        let sunset = Date(timeIntervalSince1970: TimeInterval(weatherData.current.sunset))
        
        if now >= sunrise {
            switch(weatherData.current.weather.first!.icon.dropLast()) {
            case "01":
                return sunnyMorning
            case "02":
                return partlyCloudyDay
            case "03", "04":
                return rainyDay
            case "09":
                return rainyDay
            case "10":
                return rainyDay
            case "11":
                return rainyDay
            case "13":
                return partlyCloudyDay
            case "50":
                return foggyMorning
            default:
                return sunnyMorning
            }
        } else if now < sunrise || now >= sunset {
            switch(weatherData.current.weather.first!.icon.dropLast()) {
            case "01":
                return clearNight
            case "02":
                return clearNight
            case "03", "04":
                return clearNight
            case "09":
                return stormyNight
            case "10":
                return stormyNight
            case "11":
                return stormyNight
            case "13":
                return clearNight
            case "50":
                return clearNight
            default:
                return clearNight
            }
        }
        
        return stormyNight
    }
    
    var body: some View {
        LinearGradient(colors: currentBackground, startPoint: .top, endPoint: .bottom)
        .ignoresSafeArea()
    }
}

#Preview {
    BackgroundView(weatherData: SampleWeatherData().data!)
}
