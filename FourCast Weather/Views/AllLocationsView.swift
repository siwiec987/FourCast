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
    @Binding var shouldRefresh: Bool
    
//    @State private var additionalLocations = AdditionalLocations.shared
    @State private var showingSheet = false
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        if additionalLocations.locations.isEmpty {
            ContentUnavailableView("Brak lokalizacji", systemImage: "", description: Text("Dodaj lokalizację używając '+'"))
        } else {
            ScrollView {
                LazyVGrid(columns: columns) {
//                    ForEach(additionalLocations.locations.indices, id: \.self) { index in
//                        if index < additionalLocations.locations.count {
//                            LocationView(name: additionalLocations.locations[index].name, weatherData: additionalLocations.locations[index].weatherData)
////                                .transition(.move(edge: .trailing))
//                                .onTapGesture {
//                                    selection = index
//                                    shouldRefresh.toggle()
//                                    dismiss()
//                                    print(index)
//                                }
//                                .contextMenu {
//                                    Button("Delete", systemImage: "trash", role: .destructive) {
//                                        additionalLocations.locations.remove(at: index)
//                                        selection = additionalLocations.locations.count - 1
//                                        shouldRefresh.toggle()
//                                        print(index)
//                                    }
//                                }
//                        }
//                    }
                    
                    ForEach(Array(additionalLocations.locations.enumerated()), id: \.element.id) { index, location in
                        LocationView(name: location.name, weatherData: location.weatherData)
//                                .transition(.move(edge: .trailing))
                            .onTapGesture {
                                selection = index
                                shouldRefresh.toggle()
                                dismiss()
                                print(index)
                            }
                            .contextMenu {
                                Button("Delete", systemImage: "trash", role: .destructive) {
                                    additionalLocations.locations.remove(at: index)
//                                    selection = additionalLocations.locations.count - 1
                                    selection = -1
                                    shouldRefresh.toggle()
                                    print(index)
                                }
                            }
                    }
                    
                }
//                .id(selection)
                .padding()
            }
        }
            
        Spacer()
            
        .toolbar {
            Button {
                showingSheet = true
            } label: {
                Image(systemName: "plus")
            }
        }
        .sheet(isPresented: $showingSheet) {
            SearchLocationView(selection: $selection)
            .presentationDragIndicator(.hidden)
        }
    }
}

#Preview {
    @Previewable @State var selection = 1
    @Previewable @State var shouldRefresh = false
    AllLocationsView(selection: $selection, shouldRefresh: $shouldRefresh)
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
