//
//  DailyForecast.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct DailyForecastView: View {
    let weatherData: WeatherData?
    
//    @EnvironmentObject var weatherService: WeatherService
//    @EnvironmentObject var locationManager: LocationManager

    
    var body: some View {
        VStack(spacing: 5) {
            ForEach(weatherData?.daily ?? [], id: \.dt) {dailyForecast in
                HStack {
                    Text("\(Date.getWeekday(from: dailyForecast.dt))")
                    Spacer()
                    Text("\(Int(dailyForecast.temp.min))°")
                    Text(". . .")
                    Text("\(Int(dailyForecast.temp.max))°")
                }
                .foregroundStyle(.white)
                .padding()
                
            }
        }
        .padding()
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}
