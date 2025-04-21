//
//  NewLocation.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import SwiftUI

struct AllLocationsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(AdditionalLocations.self) private var additionalLocations
    
    @Binding var selection: Int
    
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
                    ForEach(Array(additionalLocations.locations.enumerated()), id: \.element.id) { index, location in
                        LocationView(name: location.name, weatherData: location.weatherData)
                            .onTapGesture {
                                selection = index
                                dismiss()
                                print(index)
                            }
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    additionalLocations.locations.remove(at: index)
                                    selection = -1
                                    print(index)
                                }
                            }
                    }
                }
                .padding(.horizontal, 8)
            }
        }
        .searchable(text: $locationSearchService.query, isPresented: $showingSearchResults, placement: .navigationBarDrawer(displayMode: .always), prompt: "Szukaj miasta")
    }
}

#Preview {
    @Previewable @State var selection = 1
    AllLocationsView(selection: $selection)
        .environment(AdditionalLocations())
}

struct LocationView: View {
    @State var name: String
    @State var weatherData: WeatherData?
    
    private var temperature: Int {
        if let temp = weatherData?.current.temp {
            return WeatherService.getConvertedTemperature(from: temp)
        }
        
        return 0
    }
    
    var body: some View {
        ZStack {
            Color.blue
            
            Text("\(temperature)°")
                .font(.largeTitle)
                .foregroundStyle(.white)
                .shadow(color: .black, radius: 10)
            
            VStack {
                Spacer()
                
                Text(name)
                    .font(.footnote)
                    .fontWeight(.semibold)
                    .scaledToFit()
                    .minimumScaleFactor(0.6)
                    .foregroundStyle(.white)
                    .padding(8)
            }
        }
        .overlay(alignment: .topLeading) {
            Image(systemName: WeatherService.getWeatherIcon(weatherData?.current.weather[0].icon ?? "ellipsis"))
                .renderingMode(.original)
                .padding(8)
        }
        .frame(width: 100, height: 100)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}
