//
//  CurrentWeatherView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 24/02/2025.
//

import SwiftUI

struct CurrentWeatherView: View {
    let weatherData: WeatherData?
    var locationName: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(locationName)
                .bold()
            
            Text("\(Int(weatherData?.current.temp ?? 0))°")
                .font(.system(size: 80, weight: .light))
            
            Image(systemName: "cloud.sun.fill")
                .renderingMode(.original)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 180, height: 150)
                .padding(0)
            
            Text("Odczuwalna: \(Int(weatherData?.current.feelsLike ?? 0))°")
                .padding(.bottom, 30)
        }
        .foregroundStyle(.white)
    }
}
