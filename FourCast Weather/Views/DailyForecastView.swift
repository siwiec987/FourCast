//
//  DailyForecast.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct DailyForecastView: View {
    let weatherData: WeatherData?
    
    @State private var userSettings = UserSettings.shared
    
    var body: some View {
        VStack {
            ForEach(weatherData?.daily ?? [], id: \.dt) {dailyForecast in
                HStack {
                    Text("\(Date.getWeekday(from: dailyForecast.dt, with: weatherData?.timezoneOffset ?? 0))")
                        .frame(width: 100)
                    
                    Spacer()
                    
                    Image(systemName: WeatherService.getWeatherIcon(dailyForecast.weather[0].icon))
                        .renderingMode(.original)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 30, height: 30)
                    
                    Spacer()
                    
                    Text("\(getConvertedTemperature(dailyForecast.temp.min))°")
                    
                    Text(". . .")
                    
                    Text("\(getConvertedTemperature(dailyForecast.temp.max))°")
                }
            }
            .foregroundStyle(.white)
            .padding(5)
        }
        .padding()
        .background(.tertiary.opacity(0.5))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
    
    private func getConvertedTemperature(_ temp: Double) -> Int {
         return Int(Measurement(value: temp, unit: UnitTemperature.kelvin).converted(to: userSettings.settings.temperatureUnit).value)
    }
}

#Preview {
    ZStack {
        BackgroundView()
        DailyForecastView(weatherData: SampleWeatherData().data)
    }
}
