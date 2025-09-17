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
        Grid(verticalSpacing: 10) {
            ForEach(dailyWeatherData, id: \.dt) { dailyForecast in
                GridRow {
                    Text("\(Date.getWeekday(from: dailyForecast.dt, with: timezoneOffset))")
                        .gridColumnAlignment(.leading)
                    
                    HStack {
                        Spacer()
                        
                        Image(systemName: WeatherIconMapper.systemIcon(for: dailyForecast.weather[0].icon))
                            .renderingMode(.original)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30, height: 30)

                        Spacer()
                    }
                    .gridColumnAlignment(.center)
                    
                    HStack {
                        Text(UnitFormatter.getFormattedTemperature(dailyForecast.temp.min, to: userSettings.settings.temperatureUnit))
                            .foregroundStyle(.secondary)
//                        Text(". . .")
                        Spacer()
                        Text(UnitFormatter.getFormattedTemperature(dailyForecast.temp.max, to: userSettings.settings.temperatureUnit))
                    }
                    .bold()
//                    .fixedSize(horizontal: true, vertical: false)
                    .gridColumnAlignment(.trailing)
                }
            }
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
