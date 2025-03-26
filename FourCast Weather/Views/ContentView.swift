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
    @State private var additionalLocations = AdditionalLocations.shared
    
    @State private var currentLocationWeatherData: WeatherData?
    @State private var currentLocationLastFetchTime: Date?

    @State private var selection = -1
    @State private var shouldRefresh = false
    
    @State private var bottomToolbarText = ""
    
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    
    private var navbarTitle: String {
        if selection == -1 {
            return locationManager.locationName
        }
        if selection < additionalLocations.locations.count {
            return additionalLocations.locations[selection].name
        }
        
        return ""
    }
    
    var body: some View {
        NavigationStack {
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
                            do {
                                try locationManager.checkLocationAuthorization()
                            } catch {
                                errorTitle = "Daj lokalizację pls"
                                errorMessage = "Ustawienia > Aplikacje > FourCast Weather > Miejsce"
                                showingError = true
                            }
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
                                        (additionalLocations.locations[index].weatherData, additionalLocations.locations[index].lastFetchTime) = try await weatherService.fetchWeatherData(coordinate: additionalLocations.locations[index].coordinateObject, lastFetchTime: additionalLocations.locations[index].lastFetchTime)
                                        
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
//                .toolbarColorScheme(.dark, for: .navigationBar)
                .id(additionalLocations.locations.count)
                .id(shouldRefresh)
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(navbarTitle)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        NavigationLink(destination: AllLocationsView(selection: $selection, shouldRefresh: $shouldRefresh)) {
                            Image(systemName: "square.fill.on.square.fill")
                                .renderingMode(.original)
                        }
                        
                        Spacer()

                        Text(bottomToolbarText)
                            .font(.footnote)
                            .foregroundStyle(.white)
                        
                        Spacer()
                        
                        NavigationLink(destination: SettingsView()) {
                            Image(systemName: "gearshape.fill")
                                .renderingMode(.original)
                        }
                    }
                }
                .toolbarBackground(Color.accentColor, for: .bottomBar)
                .toolbarBackgroundVisibility(.visible, for: .bottomBar)
                .tint(.white)
            }
//            .ignoresSafeArea()
            .navigationTitle(navbarTitle)
            .navigationBarTitleDisplayMode(.inline)
//            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.541, green: 0.867, blue: 1).gradient, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            
            .alert(errorTitle, isPresented: $showingError) {
                Button("OK") {}
            } message: {
                Text(errorMessage)
            }
        }
    }
}



#Preview {
    ContentView()
}
