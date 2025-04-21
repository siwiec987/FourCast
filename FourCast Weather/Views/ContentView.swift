//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

struct ContentView: View {
    @State private var viewModel = ContentViewModel.shared
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.selection) {
                if !viewModel.calendarManager.events.isEmpty {
                    Tab("Calendar", systemImage: "calendar", value: -2) {
                        CalendarEventView(weatherData: viewModel.calendarEventLocation?.weatherData, data: viewModel.calendarManager.events[0])
                    }
                }
                
                Tab("Current", systemImage: "location", value: -1) {
                    WeatherView(weatherData: viewModel.currentLocationWeatherData)
                        .onChange(of: viewModel.locationManager.location, initial: false) {
                            Task {
                                await viewModel.fetchWeatherForCurrentLocation()
                            }
                        }
                }
                
                ForEach(Array(viewModel.additionalLocations.locations.enumerated()), id: \.element.id) { index, location in
                    Tab(value: index) {
                        WeatherView(weatherData: location.weatherData)
                    }
                }
            }
            .background(BackgroundView())
            .onReceive(NotificationCenter.default.publisher(
                for: UIScene.willEnterForegroundNotification)) { _ in
                    print("\nCame back to foreground, selection = \(viewModel.selection)")
                    viewModel.getEventLocation()
                    viewModel.calendarManager.checkCalendarAuthorization()
                    Task {
                        await viewModel.fetchCurrentLocationOrWeather()
                    }
            }
            .onChange(of: viewModel.selection) {
                viewModel.getEventLocation()
                viewModel.calendarManager.checkCalendarAuthorization()
                Task {
                    await viewModel.fetchCurrentLocationOrWeather()
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: AllLocationsView(selection: $viewModel.selection)) {
                        Image(systemName: "square.fill.on.square.fill")
                            .renderingMode(.original)
                    }
                    
                    Spacer()

                    VStack {
                            Text(viewModel.bottomToolbarTitle)
                                .font(.caption2)
                            
                            Text(viewModel.bottomToolbarMessage)
                                .font(.footnote)
                                .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                    
                    Spacer()
                    
                    NavigationLink(destination: SettingsView(calendarNotAuthorized: viewModel.calendarManager.notAuthorized, locationNotAuthorized: viewModel.locationManager.notAuthorized)) {
                        if viewModel.calendarManager.notAuthorized || viewModel.locationManager.notAuthorized {
                            Image(systemName: "gear.badge")
                                .renderingMode(.original)
                        } else {
                            Image(systemName: "gear")
                                .foregroundStyle(.white)
                        }
                    }
                    .fontWeight(.black)
                }
            }
            .toolbarBackground(Color.accentColor, for: .bottomBar)
            .toolbarBackgroundVisibility(.visible, for: .bottomBar)
            .tint(.white)
            .navigationTitle(viewModel.navbarTitle)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color(red: 0.400, green: 0.750, blue: 1), for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
            .alert(viewModel.errorTitle, isPresented: $viewModel.showingError) {
                Button("Ustawienia") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url)
                    }
                }
                Button("Anuluj", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage)
            }
        }
        .environment(viewModel.additionalLocations)
    }
}



#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
