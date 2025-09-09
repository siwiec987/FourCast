//
//  WeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 11/04/2025.
//

import SwiftUI

struct WeatherView: View {
    @Environment(UserSettings.self) private var userSettings
    
    let name: String
    let weatherData: WeatherData?
    
    private var visibility: String {
        guard let weatherData, let visibility = weatherData.current.visibility else { return "- -"}
        
        return UnitFormatter.getFormattedDistance(Double(visibility), to: userSettings.settings.distanceUnit)
    }
    
    private var pressure: String {
        guard let weatherData else { return "- -" }
        
        return UnitFormatter.getFormattedPressure(Double(weatherData.current.pressure), to: userSettings.settings.pressureUnit)
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                if let weatherData {
                    CurrentWeatherView(name: name, temp: weatherData.current.temp, feelsLike: weatherData.current.feelsLike)
                    HourlyForecastView(hourlyWeatherData: weatherData.hourly, timezoneOffset: weatherData.timezoneOffset)
                    DailyForecastView(dailyWeatherData: weatherData.daily, timezoneOffset: weatherData.timezoneOffset)
                    
                    HStack(spacing: 15) {
                        SmallComponentView(name: "Wschód słońca", iconName: "sunrise", info: Date.getFormattedHour(from: weatherData.current.sunrise, with: weatherData.timezoneOffset))
                        SmallComponentView(name: "Zachód słońca", iconName: "sunset", info: Date.getFormattedHour(from: weatherData.current.sunset, with: weatherData.timezoneOffset))
                    }
                    
                    if let moonData = weatherData.daily.first {
                        MoonriseMoonsetView(moonrise: moonData.moonrise, moonset: moonData.moonset, moonPhase: moonData.moonPhase, timezoneOffset: weatherData.timezoneOffset)                        
                    }
                    
                    WindInfoView(windDegree: weatherData.current.windDeg, windSpeed: weatherData.current.windSpeed, windGust: weatherData.current.windGust)
                    
                    HStack(spacing: 15) {
                        SmallComponentView(name: "Ciśnienie", iconName: "barometer", info: pressure)
                        SmallComponentView(name: "Wilgotność", iconName: "humidity", info: String(weatherData.current.humidity) + " %")
                    }
                    
                    HStack(spacing: 15) {
                        SmallComponentView(name: "Index UV", iconName: "sun.max.fill", info: String(weatherData.current.uvi))
                        SmallComponentView(name: "Widoczność", iconName: "eye.fill", info: visibility)
                    }
                    
                    Spacer()
                        .frame(height: 30)
                }
            }
            .padding()
        }
    }
}

#Preview {
    WeatherView(name: "Bieruck", weatherData: SampleWeatherData().data)
        .background(.blue)
}
