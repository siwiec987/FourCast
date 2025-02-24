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
        VStack(spacing: 5) {
            Text("Piekary Śląskie")
                .bold()
            Text("\(Int(weatherData?.current.temp ?? 0)) ℃")
                .font(.largeTitle)
                .padding(10)
            Text("Odczuwalna: \(Int(weatherData?.current.feelsLike ?? 0)) ℃")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 5) {
                    ForEach(weatherData?.hourly ?? [], id: \.dt) {hourlyForecast in
                        VStack {
                            let timeInterval = TimeInterval(hourlyForecast.dt)
                            let date = Date(timeIntervalSince1970: timeInterval)
                            let calendar = Calendar.current
                            let hourComponent = calendar.component(.hour, from: date)
                            let formattedHour = String(format: "%02d", hourComponent)
                            Text(formattedHour)
                            Text("\(Int(hourlyForecast.temp)) ℃")
                        }
                        .frame(width: 48)
                        .padding()
                        .background(Material.ultraThin)
                        .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    }
                }
            }
            .padding()
            .background(.red)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            
            VStack(spacing: 5) {
                ForEach(weatherData?.daily ?? [], id: \.dt) {dailyForecast in
                    HStack {
                        Text("\(getWeekday(from: dailyForecast.dt))")
                        Spacer()
                        Text("\(Int(dailyForecast.temp.min)) ℃")
                        Text(". . .")
                        Text("\(Int(dailyForecast.temp.max)) ℃")
                    }
                    .padding()
                }
                .background(Material.ultraThin)
                .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
            }
            .padding()
            .background(.red)
            .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
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
    
    func getWeekday(from timestamp: Int) -> String {
        let timeInterval = TimeInterval(timestamp)
        let date = Date(timeIntervalSince1970: timeInterval)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EE"
        dateFormatter.locale = Locale(identifier: "pl_PL")
        return dateFormatter.string(from: date)
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
