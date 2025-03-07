//
//  HourlyForecastView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct HourlyForecastView: View {
    let weatherData: WeatherData?

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 0) {
                ForEach(getWeekdays(forecasts: weatherData?.hourly ?? []), id: \.self) {day in
                    VStack(alignment: .leading) {
                        Text(day)
                            .font(.subheadline)
                            .padding([.top, .bottom], 10)
                        HStack {
                            ForEach(weatherData?.hourly.filter {
                                Date.getWeekday(from: $0.dt) == day
                            } ?? [], id: \.dt) {hourlyForecast in
                                VStack {
                                    let timeInterval = TimeInterval(hourlyForecast.dt)
                                    let date = Date(timeIntervalSince1970: timeInterval)
                                    let calendar = Calendar.current
                                    let hourComponent = calendar.component(.hour, from: date)
                                    let formattedHour = String(format: "%02d", hourComponent)

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
                        }
                    }
                    .padding([.leading, .bottom, .trailing])
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                }
            }
        }
        .contentMargins(0)
        .background(.white.opacity(0.25))
        .foregroundStyle(.white)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    func getWeekdays(forecasts: [HourlyWeather]) -> [String] {
        var result: [String] = []
        
        for forecast in forecasts {
            let day = Date.getWeekday(from: forecast.dt)
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
