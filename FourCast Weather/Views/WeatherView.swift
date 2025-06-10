//
//  WeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 11/04/2025.
//

import SwiftUI

struct WeatherView: View {
    var weatherData: WeatherData?
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 15) {
                CurrentWeatherView(weatherData: weatherData)
                HourlyForecastView(weatherData: weatherData)
                DailyForecastView(weatherData: weatherData)
                SunriseSunsetView(weatherData: weatherData)
                MoonriseMoonsetView(weatherData: weatherData)
                WindInfoView(weatherData: weatherData)
                Spacer()
                    .frame(height: 30)
            }
            .padding()
        }
    }
}

#Preview {
    WeatherView(weatherData: SampleWeatherData().data)
        .background(.blue)
}
