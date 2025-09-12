//
//  ContentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 12/02/2025.
//

import SwiftUI

struct WeatherTabView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var viewModel: WeatherTabViewModel
    @State private var tabViewRebuild = UUID() // bez tego, po zmianie selection w AllLocationsView, czasami wyświetla dane dla poprzedniej lokalizacji. Modyfikowane w AllLocationsView, bo przesuwanie między kartami działa dobrze, a jeśli zmieniało się w tym pliku, to psuło animację przejścia między kartami.
    // UPDATE: jednak bez tego też się zaczęło z jakiegoś powodu odświeżać poprawnie
    // UPDATE 2: jednak przestało odświeżać poprawnie, zostawię to
    
    @State private var navigationPath = NavigationPath()
    
    init(userSettings: UserSettings, liveActivityManager: LiveActivityManager) {
        self.viewModel = WeatherTabViewModel(userSettings: userSettings, liveActivityManager: liveActivityManager)
    }
    
    var settingsImageName: String {
        if !viewModel.calendarManager.isAuthorized ||
            !viewModel.locationManager.isAuthorized ||
            !viewModel.liveActivityManager.isAuthorized {
            return "gear.badge"
        } else {
            return "gear"
        }
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            let backgroundView = BackgroundView(
                timezoneOffset: viewModel.weatherDataForSelectedTab?.timezoneOffset,
                weatherIcon: viewModel.weatherDataForSelectedTab?.current.weather.first?.icon,
                sunrise: viewModel.weatherDataForSelectedTab?.current.sunrise,
                sunset: viewModel.weatherDataForSelectedTab?.current.sunset,
                windSpeed: viewModel.weatherDataForSelectedTab?.current.windSpeed
            )
            
            TabView(selection: $viewModel.selection) {
                if let calendarEventLocation = viewModel.calendarEventLocation {
                    Tab("calendar", systemImage: "calendar", value: -2) {
                        WeatherView(name: calendarEventLocation.location.name, weatherData: calendarEventLocation.location.weatherData)
                    }
                }
                
                ForEach(Array(viewModel.locations.locations.enumerated()), id: \.element.id) { index, location in
                    if location.role == .current {
                        Tab("current", systemImage: "location", value: index) {
                            WeatherView(name: location.name, weatherData: location.weatherData)
                        }
                    } else {
                        Tab(value: index) {
                            WeatherView(name: location.name, weatherData: location.weatherData)
                        }
                    }
                }
            }
            .id(tabViewRebuild)
            .background(
                backgroundView
                    .animation(.default, value: viewModel.selection)
            )
            .environment(\.weatherBackgroundColor, backgroundView.bottomColor)
            .onChange(of: scenePhase) {
                if scenePhase == .active {
                    print("scenePhase == .active!!!")
                    Task {
                        await viewModel.refreshData()
                        
                        if navigationPath.isEmpty && viewModel.locations.locations.isEmpty && viewModel.calendarEventLocation == nil {
                            navigationPath.append(Destination.allLocations)
                        }
                    }
                }
            }
            .onChange(of: viewModel.selection) {
                Task {
                    await viewModel.refreshAdditionalLocationData()
                }
            }
            .onChange(of: viewModel.userSettings.settings.activityStartOffset) {
                Task {
                    await viewModel.startOrUpdateLiveActivity()
                }
            }
            .onChange(of: viewModel.userSettings.settings.temperatureUnit) {
                Task {
                    await viewModel.startOrUpdateLiveActivity()
                }
            }
            .tabViewStyle(.page)
            .indexViewStyle(.page(backgroundDisplayMode: .always))
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    NavigationLink(value: Destination.allLocations) {
                        if viewModel.calendarManager.isAuthorized && viewModel.locationManager.isAuthorized && viewModel.liveActivityManager.isAuthorized {
                            Image(systemName: "square.fill.on.square.fill")
                                .tint(.white)
                        } else {
                            Image("custom.square.fill.on.square.fill.badge")
                                .renderingMode(.original)
                        }
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
                    
                }
            }
            .navigationDestination(for: Destination.self) { destination in
                switch destination {
                case .allLocations:
                    AllLocationsView(
                        selection: $viewModel.selection,
                        tabViewRebuild: $tabViewRebuild,
                        calendarEventLocation: viewModel.calendarEventLocation?.location,
                        calendarAuthorized: viewModel.calendarManager.isAuthorized,
                        locationAuthorized: viewModel.locationManager.isAuthorized,
                        liveActivitiesAuthorized: viewModel.liveActivityManager.isAuthorized
                    )
                }
            }
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
        .environment(viewModel.locations)
        .environment(viewModel.weatherService)
    }
}

enum Destination: Hashable {
    case allLocations
}

#Preview {
    WeatherTabView(userSettings: UserSettings(), liveActivityManager: LiveActivityManager())
        .preferredColorScheme(.dark)
}
