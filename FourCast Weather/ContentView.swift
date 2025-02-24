//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var weatherData: WeatherData?
    
    var body: some View {
        ZStack {
            LinearGradient(colors: [
                Color(red: 0.541, green: 0.867, blue: 1),
                Color(red: 0.145, green: 0.475, blue: 1)
            ], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 15) {
                    CurrentWeatherView(weatherData: weatherData)
                    HourlyForecastView(weatherData: weatherData)
                    DailyForecastView(weatherData: weatherData)
                }
                .padding()
                .task {
                    do {
                        weatherData = try await WeatherService.getWeatherData()
                    } catch OpenWeatherError.invalidURL {
                        print("Invalid URL")
                    } catch OpenWeatherError.invalidResponse {
                        print("Invalid response")
                    } catch OpenWeatherError.invalidData {
                        print("Invalid data")
                        print(weatherData ?? "pusto")
                    } catch {
                        print("Unexpected error")
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}
