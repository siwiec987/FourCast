//
//  SmallComponentView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 01/08/2025.
//

import SwiftUI

struct SmallComponentView: View {
    let name: String
    let iconName: String
    let info: String
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: iconName)
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                
                Spacer()
                
                Text(name)
            }
            
            Text(info)
                .bold()
            
        }
        .weatherComponent()
    }
}

#Preview {
    HStack(spacing: 15) {
        SmallComponentView(name: "Wilgotność powietrza", iconName: "humidity", info: "32 %")
        SmallComponentView(name: "Wilgotność powietrza", iconName: "humidity", info: "14 %")
    }
}
