//
//  LocationView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 19/10/2025.
//


import CoreLocation
import SwiftUI

struct LocationView: View {
    @Environment(UserSettings.self) private var userSettings
    let location: Location
    
    private var temperature: String {
        guard let temp = location.weatherData?.current.temp else { return "- -"}
        
        return UnitFormatter.getFormattedTemperature(temp, to: userSettings.settings.temperatureUnit)
    }
    
    var body: some View {
        ZStack {
            BackgroundView(
                timezoneOffset: location.weatherData?.timezoneOffset,
                weatherCondition: location.weatherData?.current.weather.first?.condition,
                sunrise: location.weatherData?.daily.first?.sunrise,
                sunset: location.weatherData?.daily.first?.sunset,
                windSpeed: location.weatherData?.current.windSpeed,
                effects: [.gradient, .stars, .clouds],
                miniature: true
            )
            
            Text(temperature)
                .font(.largeTitle)
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 10)
            
            VStack {
                Spacer()
                
                Group {
                    switch(location.role) {
                    case .calendarEvent:
                        Label(location.name, systemImage: "calendar")
                    case .current:
                        Label(location.name, systemImage: "location.fill")
                    default:
                        Text(location.name)
                    }
                }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(3)
                    .background(.thinMaterial.opacity(0.3))
                    .clipShape(.capsule)
                    .padding(4)
            }
        }
        .overlay(alignment: .topLeading) {
            if let iconName = location.weatherData?.current.weather[0].condition.iconName {
                Image(systemName: iconName)
                    .renderingMode(.original)
                    .padding(8)
            }
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

#Preview {
    LocationView(
        location: Location(
            name: "Warszawa",
            coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            role: .additional,
            weatherData: SampleWeatherData().data,
            lastFetchTime: nil)
    )
    .environment(UserSettings())
}
