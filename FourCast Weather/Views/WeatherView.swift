//
//  WeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 11/04/2025.
//

import SwiftUI

struct WeatherView: View {
    var weatherData: WeatherData?
    
    var visibilityUnwrapped: String {
        guard let weatherData, let visibility = weatherData.current.visibility else { return "- -"}
        
        return Measurement<UnitLength>(value: Double(visibility), unit: .meters).formatted(.measurement(width: .abbreviated, usage: .visibility))
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                if let weatherData {
                    CurrentWeatherView(temp: weatherData.current.temp, feelsLike: weatherData.current.feelsLike)
                    HourlyForecastView(hourlyWeatherData: weatherData.hourly, timezoneOffset: weatherData.timezoneOffset)
                    DailyForecastView(dailyWeatherData: weatherData.daily, timezoneOffset: weatherData.timezoneOffset)
                    
                    HStack(spacing: 15) {
                        SmallComponentView(name: "Wschód słońca", iconName: "sunrise", info: Date.getFormattedHour(from: weatherData.current.sunrise, with: weatherData.timezoneOffset))
                        SmallComponentView(name: "Zachód słońca", iconName: "sunset", info: Date.getFormattedHour(from: weatherData.current.sunset, with: weatherData.timezoneOffset))
                    }
                    
                    if let moonData = weatherData.daily.first {
                        MoonriseMoonsetView(moonrise: moonData.moonrise, moonset: moonData.moonset, moonPhase: moonData.moonPhase, timezoneOffset: weatherData.timezoneOffset)                        
                    }
                    
                    WindInfoView(windDeg: weatherData.current.windDeg, currentWindSpeed: weatherData.current.windSpeed, dailyWindSpeed: weatherData.daily.first?.windSpeed, windGust: weatherData.current.windGust)
                    
                    HStack(spacing: 15) {
                        SmallComponentView(name: "Ciśnienie", iconName: "barometer", info: Measurement(value: Double(weatherData.current.pressure), unit: UnitPressure.hectopascals).formatted(.measurement(width: .abbreviated, usage: .asProvided)))
                        SmallComponentView(name: "Wilgotność", iconName: "humidity", info: String(weatherData.current.humidity) + " %")
                    }
                    
                    HStack(spacing: 15) {
                        SmallComponentView(name: "Index UV", iconName: "sun.max.fill", info: String(weatherData.current.uvi))
//                        SmallComponentView(name: "Widoczność", iconName: "eye.fill", info: Measurement<UnitLength>(value: Double(weatherData.current.visibility), unit: .meters).formatted(.measurement(width: .abbreviated, usage: .visibility)))
                        SmallComponentView(name: "Widoczność", iconName: "eye.fill", info: visibilityUnwrapped)
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
    WeatherView(weatherData: SampleWeatherData().data)
        .background(.blue)
}
