//
//  DailyForecast.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct DailyForecastView: View {
    let weatherData: WeatherData?
    
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
                    
                    Text("\(Int(dailyForecast.temp.min))°")
                    
                    Text(". . .")
                    
                    Text("\(Int(dailyForecast.temp.max))°")
                }
            }
            .foregroundStyle(.white)
//            .padding(.init(top: 20, leading: 20, bottom: 10, trailing: 20))
            .padding(5)
        }
        .padding()
        .background(.white.opacity(0.25))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .listStyle(PlainListStyle())
    }
}

#Preview {
    ZStack {
        BackgroundView()
        DailyForecastView(weatherData: SampleWeatherData().data)
    }
}
