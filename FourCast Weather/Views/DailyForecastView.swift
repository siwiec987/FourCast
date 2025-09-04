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
                        .frame(width: 150, alignment: .leading)
                    
//                    Spacer()
                    
                    Image(systemName: WeatherIconMapper.systemIcon(for: dailyForecast.weather[0].icon))
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    
                    Spacer()
                    
                    Text(UnitFormatter.getFormattedTemperature(dailyForecast.temp.min, to: userSettings.settings.temperatureUnit))
                        .bold()
                    Text(". . .")
                        .bold()
                    Text(UnitFormatter.getFormattedTemperature(dailyForecast.temp.max, to: userSettings.settings.temperatureUnit))
                        .bold()
                }
            }
            .padding(5)
        }
        .weatherComponent()
    }
}

#Preview {
    if let data = SampleWeatherData().data {
        DailyForecastView(dailyWeatherData: data.daily, timezoneOffset: data.timezoneOffset)
            .padding()
            .background(.secondary)
            .environment(UserSettings())
    }
}
