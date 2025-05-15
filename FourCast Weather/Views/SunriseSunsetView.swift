//
//  SunriseSunsetView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 28/03/2025.
//

import SwiftUI

struct SunriseSunsetView: View {
    let weatherData: WeatherData?

    var body: some View {
        HStack(spacing: 15) {
            SunriseSunsetItem(role: "sunrise", time: weatherData?.current.sunrise, timezoneOffset: weatherData?.timezoneOffset)
            SunriseSunsetItem(role: "sunset", time: weatherData?.current.sunset, timezoneOffset: weatherData?.timezoneOffset)
        }
    }
}

private struct SunriseSunsetItem: View {
    var role: String
    var time: Int?
    var timezoneOffset: Int?
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: role)
                    .renderingMode(.original)
                    .resizable()
                    .scaledToFit()
                
                Text((role == "sunrise" ? "Wschód" : "Zachód") + " słońca")
            }
            
            Text(Date.getFormattedHour(from: time ?? 0, with: timezoneOffset ?? 0))
                .bold()
            
        }
        .padding()
        .foregroundStyle(.white)
        .background(.tertiary.opacity(0.5))
        .clipShape(.rect(cornerRadius: 15))
    }
}

#Preview {
    SunriseSunsetView(weatherData: SampleWeatherData().data)
}
