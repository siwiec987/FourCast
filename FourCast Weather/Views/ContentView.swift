//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var weatherData: WeatherData?
    @State private var cityName = ". . ."
    @StateObject var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            BackgroundView()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
//                    Text("\(locationManager.latitude ?? 0), \(locationManager.longitude ?? 0)")
                    CurrentWeatherView(weatherData: weatherData, locationName: cityName)
                    HourlyForecastView(weatherData: weatherData)
                    DailyForecastView(weatherData: weatherData)
                }
                .padding()
                .onChange(of: locationManager.location, initial: false) {
                    updateCityName()
                    
                }
//                .onChange(of: locationManager.location) { (_, _) in
//                    Task {
//                        do {
//                            weatherData = try await WeatherService.getWeatherData(
//                                latitude: locationManager.latitude ?? 0,
//                                longitude: locationManager.longitude ?? 0
//                            )
//                        } catch {
//                            print("Błąd pobierania pogody: \(error.localizedDescription)")
//                        }
//                    }
//                }
//                .task {
//                    do {
//                        weatherData = try await WeatherService.getWeatherData(
//                            latitude: locationManager.location?.coordinate.latitude ?? 0, longitude: locationManager.location?.coordinate.longitude ?? 0)
//                    } catch OpenWeatherError.invalidURL {
//                        print("Invalid URL")
//                    } catch OpenWeatherError.invalidResponse {
//                        print("Invalid response")
//                    } catch OpenWeatherError.invalidData {
//                        print("Invalid data")
//                        print(weatherData ?? "pusto")
//                    } catch {
//                        print("Unexpected error")
//                    }
//                }
            }
        }
    }
    
    private func updateCityName() {
        locationManager.getCityName { name in
            cityName = name ?? "Nieznana lokalizacja"
        }
    }
    
    private func fetchWeather() {
        guard let  lat = locationManager.location?.coordinate.latitude, let lon = locationManager.location?.coordinate.longitude else {
            return
        }
        
        //TODO
    }
}

#Preview {
    ContentView()
}


