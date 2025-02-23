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
        VStack(spacing: 20) {
            Text("\(Int(weatherData?.current.temp ?? 0)) ℃")
                .bold()
                .font(.title)
                .padding(20)
            Text("Odczuwalna: \(Int(weatherData?.current.feelsLike ?? 0)) ℃")
            Text("Piekary Śląskie")
                .bold()
            
            Spacer()
        }
        .padding()
        .task {
            do {
                weatherData = try await getWeatherData()
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
    
    func getWeatherData() async throws -> WeatherData {
        let latitude = 50.3757787
        let longitude = 18.937873187224838
        let apiKey = "792cfab2b422b4dbd5795ced996a90b0"
        let endpoint = "https://api.openweathermap.org/data/3.0/onecall?lat=\(latitude)&lon=\(longitude)&exclude=minutely&units=metric&appid=\(apiKey)"
        
        guard let url = URL(string: endpoint) else {
            throw OpenWeatherError.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw OpenWeatherError.invalidResponse
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            return try decoder.decode(WeatherData.self, from: data)
        } catch {
            throw OpenWeatherError.invalidData
        }
        
    }
}

enum OpenWeatherError: Error {
    case invalidURL
    case invalidResponse
    case invalidData
}

#Preview {
    ContentView()
}
