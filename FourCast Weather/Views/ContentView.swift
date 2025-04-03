//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var viewModel = ContentViewModel()
    @State private var locationManager = LocationManager.shared
    @State private var calendarManager = CalendarManager.shared
    @State private var additionalLocations = AdditionalLocations.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                BackgroundView()
                TabView(selection: $viewModel.selection) {
                    if !calendarManager.events.isEmpty {
                        Tab("Calendar", systemImage: "calendar", value: -2) {
                            Text(calendarManager.events[0].title)
                        }
                    }
                    
                    Tab("Current", systemImage: "location", value: -1) {
                        ScrollView(showsIndicators: false) {
                            WeatherView(weatherData: viewModel.currentLocationWeatherData, locationName: locationManager.locationName)
                        }
                        .onChange(of: locationManager.location, initial: false) {
                            viewModel.fetchWeatherForCurrentLocation()
                        }
                    }
                    
                    ForEach(additionalLocations.locations.indices, id: \.self) { index in
                        if index < additionalLocations.locations.count {
                            Tab(value: index) {
                                ScrollView(showsIndicators: false) {
                                    WeatherView(weatherData: additionalLocations.locations[index].weatherData, locationName: additionalLocations.locations[index].name)
                                }
                            }
                        }
                    }
                }
                .id(additionalLocations.locations.count)
                .id(viewModel.shouldRefresh)
                .onReceive(NotificationCenter.default.publisher(
                    for: UIScene.willEnterForegroundNotification)) { _ in
                        print("\nCame back to foreground")
                        if viewModel.selection == -1 {
                            print("City: \(locationManager.locationName)")
                            viewModel.fetchCurrentLocation()
                        }
                        if viewModel.selection >= 0 && viewModel.selection < additionalLocations.locations.count {
                            print("City: \(additionalLocations.locations[viewModel.selection].name)")
                            Task {
                                await viewModel.refreshWeatherForAdditionalLocation(index: viewModel.selection)
                            }
                        }
                }
                .onChange(of: viewModel.selection) {
                    if viewModel.selection == -1 {
                        viewModel.fetchCurrentLocation()
                    } else {
                        print("pogoda dla --\(viewModel.selection)-- jest pobierana")
                        Task {
                            await viewModel.refreshWeatherForAdditionalLocation(index: viewModel.selection)
                        }
                    }
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text(viewModel.navbarTitle)
                            .bold()
                            .foregroundStyle(.white)
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        NavigationLink(destination: AllLocationsView(selection: $viewModel.selection, shouldRefresh: $viewModel.shouldRefresh)) {
                            Image(systemName: "square.fill.on.square.fill")
                                .renderingMode(.original)
                        }
                        
                        Spacer()

                        VStack {
//                            if !WeatherService.shared.isLoading {
                                Text(viewModel.bottomToolbarTitle)
                                    .font(.caption2)
                                
                                Text(viewModel.bottomToolbarMessage)
                                    .font(.footnote)
                                    .fontWeight(.semibold)
//                            }
                        }
                        .foregroundStyle(.white)
//                        .animation(.default, value: WeatherService.shared.isLoading)
                        
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
            .navigationTitle(viewModel.navbarTitle)
            .navigationBarTitleDisplayMode(.inline)
//            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color(red: 0.400, green: 0.750, blue: 1), for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            
            .alert(viewModel.errorTitle, isPresented: $viewModel.showingError) {
                Button("OK") {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
    }
}



#Preview {
    ContentView()
}

struct WeatherView: View {
    var weatherData: WeatherData?
    var locationName: String
    
    var body: some View {
        VStack(spacing: 15) {
            CurrentWeatherView(weatherData: weatherData, locationName: locationName)
            HourlyForecastView(weatherData: weatherData)
            DailyForecastView(weatherData: weatherData)
            SunriseSunsetView(weatherData: weatherData)
            MoonriseMoonsetView(weatherData: weatherData)
            Spacer()
                .frame(height: 30)
        }
        .padding()
    }
}

