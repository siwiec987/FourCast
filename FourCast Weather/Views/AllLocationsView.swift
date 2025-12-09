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
                SearchLocationView(selection: $selection, locationSearchService: $locationSearchService, locations: locations)
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


