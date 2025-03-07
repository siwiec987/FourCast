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
        NavigationStack {
            ZStack {
                BackgroundView()
                TabView {
                    ForEach(0..<5) {_ in
                        Tab {
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
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button {
                            
                        } label: {
                            Image(systemName: "plus.square.fill.on.square.fill")
                                .renderingMode(.original)
                        }
                        
                        Spacer()

                        Text("No internet connection")
                            .font(.footnote)
                            .bold()
                            .foregroundStyle(.red)
                        
                        Spacer()
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "gearshape.fill")
                                .renderingMode(.original)
                        }
                    }
                }
                .toolbarBackground(Material.thin, for: .bottomBar)
                .toolbarBackgroundVisibility(.visible, for: .bottomBar)
//                .background(BackgroundView())
                .tint(.white)
            }
        }
//        .ignoresSafeArea()
//            .indexViewStyle(.page(backgroundDisplayMode: .always))
//        }
    }
}



#Preview {
    ContentView()
}
