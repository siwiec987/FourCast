//
//  AddLocationView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import SwiftUI

struct SearchLocationView: View {
    @Environment(\.dismiss) var dismiss
    @Environment(AdditionalLocations.self) private var additionalLocations
    @Environment(WeatherService.self) private var weatherService
    
    @Binding var selection: Int
    @Binding var locationSearchService: LocationSearchService
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(locationSearchService.results) {result in
                VStack(alignment: .leading) {
                    Button(result.title) {
                        LocationManager.getCoordinate(addressString: result.title) {(coordinate, error) in
                            print(coordinate)
                            
                            if additionalLocations.locations.contains(where: {$0.coordinate.latitude == coordinate.latitude && $0.coordinate.longitude == coordinate.longitude}) {
                                print("Równe")
                            } else {
                                Task {
                                    do {
                                        let (response, time) = try await weatherService.fetchWeatherData(coordinate: coordinate, lastFetchTime: nil)
                                        let newLocation = AdditionalLocationData(name: result.title, coordinate: Coordinate(coordinate), weatherData: response, lastFetchTime: time)
                                        additionalLocations.locations.append(newLocation)
                                        selection = additionalLocations.locations.count - 1
                                        
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
                            
                            dismiss()
                        }
                    }
                    .foregroundStyle(.primary)
                    
                    Text(result.subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
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
        .environment(AdditionalLocations())
}
