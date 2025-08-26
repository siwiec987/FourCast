//
//  NewLocation.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import SwiftUI

struct AllLocationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(Locations.self) private var locations
    
    @Binding var selection: Int
//    @Binding var tabViewRebuild: UUID
    
    @State private var locationSearchService = LocationSearchService()
    @State private var showingSearchResults = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            if showingSearchResults {
                SearchLocationView(selection: $selection, locationSearchService: $locationSearchService)
            } else {
                LazyVGrid(columns: columns) {
                    ForEach(Array(locations.locations.enumerated()), id: \.element.id) { index, location in
                        LocationView(location: location)
                            .onTapGesture {
                                switch location.role {
                                case .calendarEvent:
                                    selection = -2
                                default:
                                    selection = index
                                }
                                print(selection)
                                dismiss()
                            }
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
//        .onChange(of: selection) {
//            tabViewRebuild = UUID()
//        }
        .searchable(text: $locationSearchService.query, isPresented: $showingSearchResults, placement: .navigationBarDrawer(displayMode: .always), prompt: "Szukaj miasta")
    }
}

#Preview {
    @Previewable @State var selection = 1
    @Previewable @State var tabViewRebuild = UUID()
    AllLocationsView(selection: $selection/*, tabViewRebuild: $tabViewRebuild*/)
        .environment(Locations())
}

struct LocationView: View {
    @Environment(UserSettings.self) private var userSettings
    let location: Location
    
    private var temperature: Int {
        if let temp = location.weatherData?.current.temp {
            return WeatherService.getConvertedTemperature(from: temp, userSettings: userSettings)
        }
        
        return 0
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
            
            Text("\(temperature)°")
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
            Image(systemName: WeatherService.getWeatherIcon(location.weatherData?.current.weather[0].icon))
                .renderingMode(.original)
                .padding(8)
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
