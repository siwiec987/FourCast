//
//  NewLocation.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import SwiftUI

struct AllLocationsView: View {
    @Binding var selection: Int
    @State private var showingSheet = false
    
    var body: some View {
        NavigationStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
                .toolbar {
                    Button {
                        showingSheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
        }
        .sheet(isPresented: $showingSheet) {
            SearchLocationView(isPresented: $showingSheet, selection: $selection)
//            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
    }
}

#Preview {
    @Previewable @State var selection = 1
    AllLocationsView(selection: $selection)
}
