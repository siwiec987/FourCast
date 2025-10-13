//
//  ClothingRecommendationView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 07/10/2025.
//

import SwiftUI

struct ClothingRecommendationView: View {
    @Environment(UserSettings.self) private var userSettings
    
    @State private var showingInfoView = false
    
    let temperature: Double
    let weatherCondition: WeatherData.WeatherCondition
    let uvi: Double
    
    private var recommendations: [ClothingRecommender.ClothingItem] {
        ClothingRecommender.recommend(temperature: temperature, weatherCondition: weatherCondition, uvi: uvi, preferences: userSettings.settings.clothingPreferences)
    }
    
    var body: some View {
        if !recommendations.isEmpty {
            HStack {
                ForEach(recommendations) { item in
                    iconImage(for: item)
                        .renderingMode(.template)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .foregroundStyle(.white)
                }
            }
            .padding()
            .overlay(alignment: .topTrailing) {
                Button {
                    showingInfoView = true
                } label: {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.white)
                }
            }
            .sheet(isPresented: $showingInfoView) {
                List(ClothingRecommender.ClothingItem.allCases) { item in
                    ClothingItemDetailView(item: item)
                }
                .listStyle(.plain)
            }
        }
    }
    
    func iconImage(for item: ClothingRecommender.ClothingItem) -> Image {
        switch item.iconName {
        case .system(let name): Image(systemName: name)
        case .asset(let name): Image(name)
        }
    }
}



#Preview {
    let temp = Measurement(value: 10, unit: UnitTemperature.celsius).converted(to: .kelvin).value
    let settings = UserSettings()
    settings.settings.clothingPreferences = ClothingPreferences(temperatureOffset: Measurement<UnitTemperature>(value: 0, unit: .celsius), clothingItems: [.tShirt, .sweater, .lightJacket, .winterJacket, .hatWinter, .hatCap, .gloves, .scarf])
    
    return ClothingRecommendationView(temperature: temp, weatherCondition: WeatherData.WeatherCondition(icon: "09d"), uvi: 6)
        .background(.blue)
        .environment(settings)
        .preferredColorScheme(.dark)
}
