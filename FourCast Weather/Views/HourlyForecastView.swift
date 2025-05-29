//
//  HourlyForecastView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI
import Foundation

struct HourlyForecastView: View {
    let weatherData: WeatherData?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                let weekdays = getWeekdays(forecasts: weatherData?.hourly ?? [])
                
                ForEach(weekdays, id: \.self) { day in
                    DayForecastView(day: day, hourlyForecast: weatherData?.hourly, timezoneOffset: weatherData?.timezoneOffset)
                }
            }
        }
        .foregroundStyle(.white)
        .contentMargins(0)
        .background(.tertiary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    func getWeekdays(forecasts: [HourlyWeather]) -> [String] {
        var result: [String] = []
        
        for forecast in forecasts {
            let day = Date.getWeekday(from: forecast.dt, with: weatherData?.timezoneOffset ?? 0)
            if !result.contains(day) {
                result.append(day)
            }
        }
        
        return result
    }
}

struct DayForecastView: View {
    var day: String
    var hourlyForecast: [HourlyWeather]?
    var timezoneOffset: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(day)
                .font(.subheadline)
                .padding([.top, .bottom], 10)
            
            HStack {
                let hourlyForecasts = getHourlyForecasts(for: day)
                
                ForEach(hourlyForecasts, id: \.dt) { hourlyForecast in
                    HourlyForecastItem(hourlyForecast: hourlyForecast, timezoneOffset: timezoneOffset)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func getHourlyForecasts(for day: String) -> [HourlyWeather] {
        return (hourlyForecast ?? []).filter {
            Date.getWeekday(from: $0.dt, with: timezoneOffset ?? 0) == day
        }
    }
}

struct HourlyForecastItem: View {
    @Environment(UserSettings.self) private var userSettings
    let hourlyForecast: HourlyWeather
    let timezoneOffset: Int?
    
    private var temperature: Int {
        let temp = hourlyForecast.temp
        return WeatherService.getConvertedTemperature(from: temp, userSettings: userSettings)
    }
    var body: some View {
        VStack {
            let formattedHour = Date.getFormattedHour(from: hourlyForecast.dt, with: timezoneOffset ?? 0, format: "HH")
            
            Text(formattedHour)
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Image(systemName: WeatherService.getWeatherIcon(hourlyForecast.weather[0].icon))
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text("\(temperature)°")
                .bold()
        }
    }
}

#Preview {
    ZStack {
        BackgroundView()
        HourlyForecastView(weatherData: SampleWeatherData().data)
    }
}
