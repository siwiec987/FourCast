//
//  AddLocationView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 09/03/2025.
//

import SwiftUI

struct SearchLocationView: View {
    @Environment(\.dismiss) var dismiss
    
    @Binding var selection: Int
    @Binding var locationSearchService: LocationSearchService
    
    private var viewModel: SearchLocationViewModel
    
    init(selection: Binding<Int>, locationSearchService: Binding<LocationSearchService>, locations: Locations) {
        _selection = selection
        _locationSearchService = locationSearchService
        self.viewModel = SearchLocationViewModel(locations: locations)
    }
    
    var body: some View {
        LazyVStack(alignment: .leading) {
            ForEach(locationSearchService.results) { result in
                    Button {
                        Task {
                            if let index = await viewModel.handleSelection(result) {
                                selection = index
                            }
                            
                            locationSearchService.query = ""
                            dismiss()
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(result.title)
                                .font(.headline)
                            Text(result.subtitle)
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .foregroundStyle(.primary)
                    .padding(.vertical, 5)
            }
        }
        .padding(.horizontal)
    }
}

#Preview {
    @Previewable @State var locationSearchService = LocationSearchService()
    locationSearchService.query = "po"
    return SearchLocationView(selection: .constant(1), locationSearchService: $locationSearchService, locations: Locations())
}
