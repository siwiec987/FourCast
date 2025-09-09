//
//  NewLocation.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import CoreLocation
import SwiftUI

struct AllLocationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Locations.self) private var locations
//    @Environment(UserSettings.self) private var userSettings
    
    @State private var locationSearchService = LocationSearchService()
    @State private var showingSearchResults = false
    
    @Binding var selection: Int
    @Binding var tabViewRebuild: UUID
    
    let calendarEventLocation: Location?
    
    let calendarAuthorized: Bool
    let locationAuthorized: Bool
    let liveActivitiesAuthorized: Bool
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    private var toolbarButton: some View {
        NavigationLink(destination:
                        SettingsView(
                            calendarAuthorized: calendarAuthorized,
                            locationAuthorized: locationAuthorized,
                            liveActivitiesAuthorized: liveActivitiesAuthorized
                        )
        ) {
            if calendarAuthorized && locationAuthorized && liveActivitiesAuthorized {
                Image(systemName: "gear")
                    .foregroundStyle(.white)
            } else {
                Image(systemName: "gear.badge")
                    .renderingMode(.original)
            }
        }
        .tint(.white)
        .fontWeight(.bold)
    }
    
    var body: some View {
        ScrollView {
            if showingSearchResults {
                SearchLocationView(selection: $selection, locationSearchService: $locationSearchService)
            } else {
                LazyVGrid(columns: columns) {
                    if let calendarEventLocation {
                        locationButton(for: -2, locaiton: calendarEventLocation)
                    }
                    ForEach(Array(locations.locations.enumerated()), id: \.element.id) { index, location in
                        locationButton(for: index, locaiton: location)
                            .contextMenu {
                                if location.role == .additional {
                                    Button("Usuń", systemImage: "trash", role: .destructive) {
                                        selection = 0
                                        locations.locations.remove(at: index)
                                    }
                                }
                            }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .onChange(of: selection) {
            tabViewRebuild = UUID()
        }
        .navigationTitle("Pogoda")
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden()
        .searchable(text: $locationSearchService.query, isPresented: $showingSearchResults, placement: .navigationBarDrawer(displayMode: .always), prompt: "Szukaj miasta")
        .toolbar {
            toolbarButton
        }
    }
    
    private func locationButton(for index: Int, locaiton: Location) -> some View {
        Button {
            selection = index
            dismiss()
        } label: {
            LocationView(location: locaiton)
        }

    }
}

#Preview {
    @Previewable @State var selection = 1
    @Previewable @State var tabViewRebuild = UUID()
    let location = Location(name: "CALENDAR", coordinate: CLLocationCoordinate2D(latitude: 50, longitude: 20), role: .calendarEvent)
    NavigationStack {
        AllLocationsView(selection: $selection, tabViewRebuild: $tabViewRebuild, calendarEventLocation: location, calendarAuthorized: true, locationAuthorized: false, liveActivitiesAuthorized: false)
    }
        .environment(Locations())
}

struct LocationView: View {
    @Environment(UserSettings.self) private var userSettings
    let location: Location
    
    private var temperature: String {
        guard let temp = location.weatherData?.current.temp else { return "- -"}
        
        return UnitFormatter.getFormattedTemperature(temp, to: userSettings.settings.temperatureUnit)
    }
    
    var body: some View {
        ZStack {
            BackgroundView(
                timezoneOffset: location.weatherData?.timezoneOffset,
                weatherIcon: location.weatherData?.current.weather.first?.icon,
                sunrise: location.weatherData?.current.sunrise,
                sunset: location.weatherData?.current.sunset,
                windSpeed: location.weatherData?.current.windSpeed,
                effects: [.gradient, .stars, .clouds],
                miniature: true
            )
            
            Text(temperature)
                .font(.largeTitle)
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 10)
            
            VStack {
                Spacer()
                
                Group {
                    switch(location.role) {
                    case .calendarEvent:
                        Label(location.name, systemImage: "calendar")
                    case .current:
                        Label(location.name, systemImage: "location.fill")
                    default:
                        Text(location.name)
                    }
                }
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(3)
                    .background(.thinMaterial.opacity(0.3))
                    .clipShape(.capsule)
                    .padding(4)
            }
        }
        .overlay(alignment: .topLeading) {
            Image(systemName: WeatherIconMapper.systemIcon(for: location.weatherData?.current.weather[0].icon))
                .renderingMode(.original)
                .padding(8)
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
