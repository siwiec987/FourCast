//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

// TODO: Czasami przy zmianie lokalizacji w allLocationsView jest dziwny bug, niby się zmienia, ale wyświetla dane poprzedniej lokalizacji i nie wiadomo o co chodzi ziomek napraw to oki??

import SwiftUI

struct ContentView: View {
    @Environment(UserSettings.self) private var userSettings
    @State private var viewModel = ContentViewModel()
    
    var body: some View {
        NavigationStack {
            TabView(selection: $viewModel.selection) {
                if let calendarEventLocation = viewModel.calendarEventLocation {
                    Tab("Calendar", systemImage: "calendar", value: -2) {
                        HStack {
                            Button("Live activity") {
                                viewModel.startActivity(userSettings: userSettings)
                            }
                            .padding()
                            .background(.clear.mix(with: .black, by: 0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                            .disabled(viewModel.hasEventStarted)
                            
                            Button("Stop") {
                                Task {
                                    await viewModel.stopActivity()
                                }
                            }
                            .padding()
                            .background(.clear.mix(with: .black, by: 0.25))
                            .clipShape(RoundedRectangle(cornerRadius: 15))
                        }

                        CalendarEventView(weatherData: calendarEventLocation.weatherData, data: viewModel.calendarManager.events[0])
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
            .onReceive(NotificationCenter.default.publisher(
                for: UIScene.willEnterForegroundNotification)) { _ in
                    print("\nCame back to foreground, selection = \(viewModel.selection)")
                    //jak coś nie będzie działać jak powinno to może przez to, bo żem se zakomentował, bo 25.04 stwierdziłem, że to nie ma sensu. W sumie to tu nawet może mieć sens
                    viewModel.getEventLocation()
                    viewModel.calendarManager.checkCalendarAuthorization()
                    Task {
                        await viewModel.fetchCurrentLocationOrWeather()
                    }
            }
            .onChange(of: viewModel.selection) {
                //jak coś nie będzie działać jak powinno to może przez to, bo żem se zakomentował, bo 25.04 stwierdziłem, że to nie ma sensu. Początek:
//                viewModel.getEventLocation()
//                viewModel.calendarManager.checkCalendarAuthorization()
                // Koniec
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
//            .toolbarBackground(Color.accentColor, for: .bottomBar)
//            .toolbarBackground(Material.regular, for: .bottomBar)
//            .toolbarBackgroundVisibility(.visible, for: .bottomBar)
            .tint(.white)
            .navigationTitle(viewModel.navbarTitle)
            .navigationBarTitleDisplayMode(.inline)
//            .toolbarBackground(Color(red: 0.400, green: 0.750, blue: 1), for: .navigationBar)
//            .toolbarBackground(Material.regular, for: .navigationBar)
//            .toolbarBackgroundVisibility(.visible, for: .navigationBar)
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
        .environment(viewModel.additionalLocations)
        .environment(viewModel.weatherService)
    }
}



#Preview {
    ContentView()
        .preferredColorScheme(.dark)
}
