//
//  ClothingInfoView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 13/10/2025.
//


import SwiftUI

struct ClothingItemDetailView: View {
    @Environment(UserSettings.self) private var userSettings
    
    let item: ClothingRecommender.ClothingItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                iconImage(for: item)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundStyle(.primary)
                
                Text(item.description)
            }
            
            if let range = item.temperatureRange {
                if range.lowerBound.value == -100 {
                    Text("Poniżej \(formatted(range.upperBound))")
                } else if range.upperBound.value == 100 {
                    Text("Powyżej \(formatted(range.lowerBound))")
                } else {
                    HStack {
                        Text(formatted(range.lowerBound))
                            .foregroundStyle(.secondary)
                        
                        Text(formatted(range.upperBound))
                            .foregroundStyle(.primary)
                    }
                }
            }
        }
    }
    
    func formatted(_ temperature: Measurement<UnitTemperature>) -> String {
        let tempOffset = temperature + userSettings.settings.clothingPreferences.temperatureOffset
        let temp = tempOffset.converted(to: userSettings.settings.temperatureUnit)
        let tempFormatted = Measurement(value: temp.value.rounded(), unit: temp.unit)
            .formatted(.measurement(width: .abbreviated, usage: .asProvided, hidesScaleName: true))
        
        return tempFormatted
    }
    
    func iconImage(for item: ClothingRecommender.ClothingItem) -> Image {
        switch item.iconName {
        case .system(let name): Image(systemName: name)
        case .asset(let name): Image(name)
        }
    }
}

#Preview {
    Color.white
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            List(ClothingRecommender.ClothingItem.allCases) { item in
                ClothingItemDetailView(item: item)
            }
            .listStyle(.plain)
        }
        .preferredColorScheme(.dark)
        .environment(UserSettings())
}
