//
//  AddLocationView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import SwiftUI

struct SearchLocationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(Locations.self) private var locations
    
    @Binding var selection: Int
    @Binding var locationSearchService: LocationSearchService
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(locationSearchService.results) { result in
                    Button {
                        LocationManager.getCoordinate(addressString: result.title) { coordinate, error in
                            if let index = locations.locations.firstIndex(where: { $0.coordinate == coordinate }) {
                                locationSearchService.query = ""
                                selection = index
                                print("SearchLocationView: location already exists!")
                            } else {
                                Task {
                                    do {
                                        let (response, time) = try await WeatherService.fetchWeatherData(coordinate: coordinate)
                                        let newLocation = Location(name: result.title, coordinate: coordinate, role: .additional, weatherData: response, lastFetchTime: time)
                                        locations.locations.append(newLocation)
                                        selection = locations.locations.count - 1
                                        print("New location: selection == \(selection)")
                                        
                                    } catch OpenWeatherError.invalidData {
                                        print("Invalid data")
                                    } catch {
                                        print("coś innego")
                                    }
                                }
                            }
                            
                            dismiss()
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.subtitle)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .foregroundStyle(.primary)
                    
                .padding(.vertical, 5)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var selection = 1
    @Previewable @State var locationSearchService = LocationSearchService()
    SearchLocationView(selection: $selection, locationSearchService: $locationSearchService)
        .environment(Locations())
}
