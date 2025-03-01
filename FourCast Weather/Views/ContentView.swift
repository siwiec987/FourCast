//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var weatherService = WeatherService.shared
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    CurrentWeatherView(weatherData: weatherService.weatherData, locationName: locationManager.locationName)
                    HourlyForecastView(weatherData: weatherService.weatherData)
                    DailyForecastView(weatherData: weatherService.weatherData)
                }
                .padding()
                .onChange(of: locationManager.location, initial: false) {
                    if let location = locationManager.location, locationManager.locationReady {
                        Task {
                            do {
                                try await weatherService.fetchWeatherData(location: location)
                                
                            } catch OpenWeatherError.invalidData {
                                print("Invalid data")
                            } catch {
                                print("cos innego wydupcylo")
                            }
                        }
                    }
                }
            }
            .refreshable {
                locationManager.checkLocationAuthorization()
            }
        }
    }
}

#Preview {
    ContentView()
}
