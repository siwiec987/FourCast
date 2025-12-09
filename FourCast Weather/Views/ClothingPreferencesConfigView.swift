//
//  ClothingPreferencesConfigView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 14/10/2025.
//

import SwiftUI

struct ClothingPreferencesConfigView: View {
    @Environment(\.scenePhase) private var scenePhase
//    @Environment(UserSettings.self) private var userSettings
    
    @State private var viewModel: ClothingPreferencesViewModel
    
    let navigationTitle: String
    let navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode
    
    init(navigationTitle: String, navigationTitleDisplayMode: NavigationBarItem.TitleDisplayMode, userSettings: UserSettings) {
        self.navigationTitle = navigationTitle
        self.navigationTitleDisplayMode = navigationTitleDisplayMode
        self.viewModel = ClothingPreferencesViewModel(userSettings: userSettings)
    }
    
    var body: some View {
        Form {
            Section {
                Picker("W zimę preferuję", selection: $viewModel.winterOuterwear) {
                    Text("Kurtki")
                        .tag(ClothingRecommender.ClothingItem.winterJacket)
                    
                    Text("Płaszcze")
                        .tag(ClothingRecommender.ClothingItem.coat)
                }
            }
            
            Section {
                Toggle("Używam parasola", isOn: $viewModel.likesUmbrellas)
                Toggle("Noszę czapki z daszkiem", isOn: $viewModel.likesCaps)
                Toggle("Lubię okulary przeciwsłoneczne", isOn: $viewModel.likesSunglasses)
            }
            
            Section {
                Toggle("Noszę czapki zimowe", isOn: $viewModel.likesWinterHats)
                Toggle("Noszę rękawiczki", isOn: $viewModel.likesGloves)
                Toggle("Noszę szaliki", isOn: $viewModel.likesScarves)
            }
            
            Section {
                Picker("Temperatury", selection: $viewModel.temperatureOffset) {
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
        .onAppear(perform: viewModel.load)
        .onDisappear(perform: viewModel.save)
        .onChange(of: scenePhase) {
            if scenePhase != .active {
                viewModel.save()
            }
        }
    }
}

#Preview {
    NavigationStack {
        ClothingPreferencesConfigView(
            navigationTitle: "Preferencje",
            navigationTitleDisplayMode: .inline,
            userSettings: UserSettings()
        )
    }
    .preferredColorScheme(.dark)
}

