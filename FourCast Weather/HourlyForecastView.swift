//
//  HourlyForecastView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct HourlyForecastView: View {
    let weatherData: WeatherData?
    
//    @EnvironmentObject var weatherService: WeatherService
//    @EnvironmentObject var locationManager: LocationManager

    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 5) {
                ForEach(weatherData?.hourly ?? [], id: \.dt) {hourlyForecast in
                    VStack {
                        let timeInterval = TimeInterval(hourlyForecast.dt)
                        let date = Date(timeIntervalSince1970: timeInterval)
                        let calendar = Calendar.current
                        let hourComponent = calendar.component(.hour, from: date)
                        let formattedHour = String(format: "%02d", hourComponent)
                        
                        Text("\(Date.getWeekday(from: hourlyForecast.dt))")
                            .font(.subheadline)
                        Text(formattedHour)
                        Text("\(Int(hourlyForecast.temp))°")
                    }
                    .frame(width: 31)
                    .padding()
                }
            }
        }
        .padding()
        .background(.white.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
    }
}
