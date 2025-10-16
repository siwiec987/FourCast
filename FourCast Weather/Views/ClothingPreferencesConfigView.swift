//
//  ClothingPreferencesConfigView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 14/10/2025.
//

import SwiftUI

struct ClothingPreferencesConfigView: View {
    @Environment(UserSettings.self) private var userSettings
    
    @State private var likesUmbrellas = true
    @State private var likesCaps = true
    @State private var likesSunglasses = true
    
    @State private var likesWinterHats = true
    @State private var likesGloves = true
    @State private var likesScarves = true
    
    @State private var winterOuterwear: ClothingRecommender.ClothingItem = .winterJacket
    
    @State private var temperatureOffset = 0.0
    
    let navigationTitle: String
    let navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode
    
    init(navigationTitle: String, navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode) {
        self.navigationTitle = navigationTitle
        self.navigationTitleDisplayMode = navigationTitleDisplayMode
    }
    
    var body: some View {
        Form {
            Section {
                Picker("W zimę preferuję", selection: $winterOuterwear) {
                    Text("Kurtki")
                        .tag(ClothingRecommender.ClothingItem.winterJacket)
                    
                    Text("Płaszcze")
                        .tag(ClothingRecommender.ClothingItem.coat)
                }
            }
            
            Section {
                Toggle("Używam parasola", isOn: $likesUmbrellas)
                Toggle("Noszę czapki z daszkiem", isOn: $likesCaps)
                Toggle("Lubię okulary przeciwsłoneczne", isOn: $likesSunglasses)
            }
            
            Section {
                Toggle("Noszę czapki zimowe", isOn: $likesWinterHats)
                Toggle("Noszę rękawiczki", isOn: $likesGloves)
                Toggle("Noszę szaliki", isOn: $likesScarves)
            }
            
            Section {
                Picker("Temperatury", selection: $temperatureOffset) {
                    Text("Lubię zimno").tag(-5.0)
                    Text("Neutralnie").tag(0.0)
                    Text("Lubię ciepło").tag(5.0)
                }
                .pickerStyle(.segmented)
            }
            .listRowInsets(.init())
            .listRowBackground(Color.clear)
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(navigationTitleDisplayMode)
        .onAppear(perform: load)
        .onDisappear(perform: save)
    }
    
    private func save() {
        var preferences = userSettings.settings.clothingPreferences
        
        preferences.likesUmbrellas(likesUmbrellas)
        preferences.likesCaps(likesCaps)
        preferences.likesSunglasses(likesSunglasses)
        preferences.likesWinterHats(likesWinterHats)
        preferences.likesGloves(likesGloves)
        preferences.likesScarves(likesScarves)
        preferences.winterOuterwearChoice(winterOuterwear)
        
        preferences.temperatureOffset = Measurement(value: temperatureOffset, unit: .celsius)
        
        userSettings.settings.clothingPreferences = preferences
        
        print("Preferences saved!")
    }
    
    private func load() {
        let preferences = userSettings.settings.clothingPreferences
        
        likesUmbrellas = preferences.clothingItems.contains(.umbrella)
        likesCaps = preferences.clothingItems.contains(.hatCap)
        likesSunglasses = preferences.clothingItems.contains(.sunglasses)
        likesWinterHats = preferences.clothingItems.contains(.hatWinter)
        likesGloves = preferences.clothingItems.contains(.gloves)
        likesScarves = preferences.clothingItems.contains(.scarf)
        winterOuterwear = preferences.clothingItems.contains(.winterJacket) ? .winterJacket : .coat
        
        temperatureOffset = preferences.temperatureOffset.converted(to: .celsius).value
    }
}

#Preview {
    NavigationStack {
        ClothingPreferencesConfigView(navigationTitle: "Preferencje", navigationTitleDisplayMode: .inline)
    }
    .preferredColorScheme(.dark)
    .environment(UserSettings())
}

