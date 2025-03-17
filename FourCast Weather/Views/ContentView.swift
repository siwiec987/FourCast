//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var weatherService = WeatherService.shared
    @State private var locationManager = LocationManager.shared
    @State private var currentLocationWeatherData: WeatherData?
    @State private var currentLocationLastFetchTime: Date?
    
    @State private var additionalLocations = AdditionalLocations.shared
    
    @State private var selection = -1
    
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            ZStack {
                BackgroundView()
                TabView(selection: $selection) {
                    Tab("Current", systemImage: "location", value: -1) {
                        ScrollView(showsIndicators: false) {
                            VStack(spacing: 15) {
                                CurrentWeatherView(weatherData: currentLocationWeatherData, locationName: locationManager.locationName)
                                HourlyForecastView(weatherData: currentLocationWeatherData)
                                DailyForecastView(weatherData: currentLocationWeatherData)
                            }
                            .padding()
                            .onChange(of: locationManager.location, initial: false) {
                                if let location = locationManager.location, locationManager.locationReady {
                                    Task {
                                        do {
                                            (currentLocationWeatherData, currentLocationLastFetchTime) = try await weatherService.fetchWeatherData(coordinate: location.coordinate, lastFetchTime: currentLocationLastFetchTime)
                                            
                                        } catch OpenWeatherError.invalidData {
                                            print("Invalid data")
                                        } catch OpenWeatherError.alreadyInUse {
                                            print("Aready fetching")
                                        } catch OpenWeatherError.fetchNotNecessary {
                                            print("Not necessary")
                                        } catch {
                                            print("coś innego")
                                        }
                                    }
                                }
                            }
                        }
                        .refreshable {
                            locationManager.checkLocationAuthorization()
                        }
                    }
                    
                    ForEach(additionalLocations.locations.indices, id: \.self) { index in
                        if index < additionalLocations.locations.count {
                            Tab(value: index) {
                                ScrollView(showsIndicators: false) {
                                    VStack(spacing: 15) {
                                        CurrentWeatherView(weatherData: additionalLocations.locations[index].weatherData, locationName: additionalLocations.locations[index].name)
                                        HourlyForecastView(weatherData: additionalLocations.locations[index].weatherData)
                                        DailyForecastView(weatherData: additionalLocations.locations[index].weatherData)
                                    }
                                    .padding()
                                }
                                .refreshable {
                                    do {
                                        (additionalLocations.locations[index].weatherData, additionalLocations.locations[index].lastFetchTime) = try await weatherService.fetchWeatherData(coordinate: additionalLocations.locations[index].coordinate, lastFetchTime: additionalLocations.locations[index].lastFetchTime)
                                        
                                    } catch OpenWeatherError.invalidData {
                                        print("Invalid data")
                                    } catch OpenWeatherError.alreadyInUse {
                                        print("Aready fetching")
                                    } catch OpenWeatherError.fetchNotNecessary {
                                        print("Not necessary")
                                    } catch {
                                        print("coś innego")
                                    }
                                }
                            }
                        }
                    }
                }
                .id(additionalLocations.locations.count)
                .id(selection)
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
//                        NavigationLink(destination: AllLocationsView(selection: $selection, navigationPath: $navigationPath)) {
                        NavigationLink(destination: AllLocationsView(selection: $selection)) {
                            Image(systemName: "square.fill.on.square.fill")
                                .renderingMode(.original)
                        }
                        
                        Spacer()

                        Text("No internet connection")
                            .font(.footnote)
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
                .tint(.white)
            }
        }
//        .sheet(isPresented: $showingSheet) {
//            SearchLocationView(isPresented: $showingSheet, selection: $selection)
//                .presentationDetents([.medium, .large])
//                .presentationDragIndicator(.visible)
//        }
    }
}



#Preview {
    ContentView()
}
