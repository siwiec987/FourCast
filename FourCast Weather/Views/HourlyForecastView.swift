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
                    dayForecastView(for: day)
                }
            }
        }
        .contentMargins(0)
        .background(.white.opacity(0.25))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func dayForecastView(for day: String) -> some View {
        VStack(alignment: .leading) {
            Text(day)
                .font(.subheadline)
                .padding([.top, .bottom], 10)
            
            HStack {
                let hourlyForecasts = getHourlyForecasts(for: day)
                
                ForEach(hourlyForecasts, id: \.dt) { hourlyForecast in
                    hourlyForecastItem(for: hourlyForecast)
                }
            }
        }
        .padding([.leading, .bottom, .trailing])
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func hourlyForecastItem(for hourlyForecast: HourlyWeather) -> some View {
        VStack {
            let formattedHour = getFormattedHour(from: hourlyForecast.dt)
            
            Text(formattedHour)
                .font(.subheadline)
            
            Image(systemName: WeatherService.getWeatherIcon(hourlyForecast.weather[0].icon))
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 30, height: 30)
            
            Text("\(Int(hourlyForecast.temp))°")
                .bold()
        }
    }
    
    private func getFormattedHour(from timestamp: Int) -> String {
        let timeInterval = TimeInterval(timestamp)
        let utcDate = Date(timeIntervalSince1970: timeInterval)
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: weatherData?.timezoneOffset ?? 0)
        formatter.dateFormat = "HH"
        
        return formatter.string(from: utcDate)
    }
    
    private func getHourlyForecasts(for day: String) -> [HourlyWeather] {
        return weatherData?.hourly.filter {
            Date.getWeekday(from: $0.dt, with: weatherData?.timezoneOffset ?? 0) == day
        } ?? []
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

#Preview {
    ZStack {
        BackgroundView()
        HourlyForecastView(weatherData: SampleWeatherData().data)
    }
}
