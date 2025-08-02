//
//  DailyForecast.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct DailyForecastView: View {
    @Environment(UserSettings.self) private var userSettings
    let dailyWeatherData: [DailyWeather]
    let timezoneOffset: Int
    
    var body: some View {
        VStack {
            ForEach(dailyWeatherData, id: \.dt) {dailyForecast in
                HStack {
                    Text("\(Date.getWeekday(from: dailyForecast.dt, with: timezoneOffset))")
                        .frame(width: 100)
                    
                    Spacer()
                    
                    Image(systemName: WeatherService.getWeatherIcon(dailyForecast.weather[0].icon))
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    
                    Spacer()
                    
                    Text("\(WeatherService.getConvertedTemperature(from: dailyForecast.temp.min, userSettings: userSettings))°")
                    
                    Text(". . .")
                    
                    Text("\(WeatherService.getConvertedTemperature(from: dailyForecast.temp.max, userSettings: userSettings))°")
                }
            }
            .foregroundStyle(.white)
            .padding(5)
        }
        .padding()
        .background(.clear.mix(with: .black, by: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    if let data = SampleWeatherData().data {
        DailyForecastView(dailyWeatherData: data.daily, timezoneOffset: data.timezoneOffset)
            .background(.blue)
    }
}
