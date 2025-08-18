//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @Environment(UserSettings.self) private var userSettings
    @State private var viewModel = ContentViewModel()
    @State private var tabViewRebuild = UUID() // bez tego, po zmianie selection w AllLocationsView, czasami wyświetla dane dla poprzedniej lokalizacji. Modyfikowane w AllLocationsView, bo przesuwanie między kartami działa dobrze, a jeśli zmieniało się w tym pliku, to psuło animację przejścia między kartami
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.selection) {
                if let calendarEventLocation = viewModel.calendarEventLocation {
                    Tab("Calendar", systemImage: "calendar", value: -2) {
//                        HStack {
//                            Button("Live activity") {
//                                viewModel.startActivity(userSettings: userSettings)
//                            }
//                            .padding()
//                            .background(.clear.mix(with: .black, by: 0.25))
//                            .clipShape(RoundedRectangle(cornerRadius: 15))
//                            .disabled(viewModel.hasEventStarted)
//                            
//                            Button("Stop") {
//                                Task {
//                                    await viewModel.stopActivity()
//                                }
//                            }
//                            .padding()
//                            .background(.clear.mix(with: .black, by: 0.25))
//                            .clipShape(RoundedRectangle(cornerRadius: 15))
//                        }

//                        CalendarEventView(weatherData: calendarEventLocation.weatherData, data: viewModel.calendarManager.events[0])
                        WeatherView(weatherData: calendarEventLocation.weatherData)
                    }
                }
                
                Tab("Current", systemImage: "location", value: -1) {
                    WeatherView(weatherData: viewModel.currentLocation?.weatherData)
                        .onChange(of: viewModel.locationManager.location, initial: false) { oldVal, newVal in
                            viewModel.updateCurrentLocationCoordinate()
                            viewModel.updateCurrentLocationName()
                            Task {
                                await viewModel.fetchWeatherForCurrentLocation()
                                await viewModel.fetchWeatherForCalendarEventLocation(userSettings: userSettings)
                            }
                        }
                        .onChange(of: viewModel.locationManager.locationName) {
                            viewModel.updateCurrentLocationName()
                        }
                }
                
                ForEach(Array(viewModel.locations.locations.enumerated()), id: \.element.id) { index, location in
                    if let additionalLocationsStartIndex = viewModel.additionalLocationsStartIndex, index >= additionalLocationsStartIndex {
                        Tab(value: index) {
                            WeatherView(weatherData: location.weatherData)
                        }
                    }
                }
            }
            .id(tabViewRebuild)
            .background(
                BackgroundView(
                    timezoneOffset: viewModel.weatherDataForSelectedTab?.timezoneOffset,
                    weatherIcon: viewModel.weatherDataForSelectedTab?.current.weather.first?.icon,
                    sunrise: viewModel.weatherDataForSelectedTab?.current.sunrise,
                    sunset: viewModel.weatherDataForSelectedTab?.current.sunset,
                    windSpeed: viewModel.weatherDataForSelectedTab?.current.windSpeed
                )
                .animation(.default, value: viewModel.selection)
            )
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    Task {
                        await viewModel.refreshWeatherData()
                    }
                }
            }
            .onChange(of: viewModel.selection) {
                Task {
                    await viewModel.refreshWeatherData()
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(destination: AllLocationsView(selection: $viewModel.selection, tabViewRebuild: $tabViewRebuild)) {
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
            .tint(.white)
            .navigationTitle(viewModel.navbarTitle)
            .navigationBarTitleDisplayMode(.inline)
            .alert(viewModel.errorTitle, isPresented: $viewModel.locationManager.authError) {
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
        .environment(viewModel.locations)
        .environment(viewModel.weatherService)
    }
}



#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
