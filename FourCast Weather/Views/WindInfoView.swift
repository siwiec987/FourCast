//
//  WindInfoView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 08/05/2025.
//

import SwiftUI

struct WindInfoView: View {
    @Environment(UserSettings.self) private var userSettings
    let windDegree: Int
    let windSpeed: Double
    let windGust: Double?
    
    private var speed: String {
        UnitFormatter.getFormattedWindSpeed(windSpeed, to: userSettings.settings.windSpeedUnit)
    }
    
    private var gust: String {
        guard let windGust else { return "- -" }
        
        return UnitFormatter.getFormattedWindSpeed(windGust, to: userSettings.settings.windSpeedUnit)
    }
    
    private var degree: String {
        var direction = "N"
        
        if windDegree < 360 { direction = "NW" }
        if windDegree < 315 { direction = "W" }
        if windDegree < 270 { direction = "SW" }
        if windDegree < 225 { direction = "S" }
        if windDegree < 180 { direction = "SE" }
        if windDegree < 135 { direction = "E" }
        if windDegree < 90 { direction = "NE" }
        if windDegree < 45 { direction = "N" }
        
        return "\(windDegree)° \(direction)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                DetailView(title: "Prędkość", content: speed)
                DetailView(title: "Porywy", content: gust)
                DetailView(title: "Kierunek", content: degree)
            }
            
            Spacer()
        
            ZStack {
                let overlayPadding: CGFloat = 5
                
                Circle()
                    .stroke(.secondary, lineWidth: 2)
                    .overlay(alignment: .top) {
                        Text("N")
                            .padding(overlayPadding)
                    }
                    .overlay(alignment: .trailing) {
                        Text("E")
                            .padding(overlayPadding)
                    }
                    .overlay(alignment: .bottom) {
                        Text("S")
                            .padding(overlayPadding)
                    }
                    .overlay(alignment: .leading) {
                        Text("W")
                            .padding(overlayPadding)
                    }
                
                Image(systemName: "arrowshape.down")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                    .rotationEffect(Angle(degrees: Double(windDegree)))
                    .fontWeight(.thin)
                    .padding()
            }
            .frame(width: 100, height: 100)
            .font(.footnote)
            .padding(.leading)
        }
        .weatherComponent()
    }
    
    struct DetailView: View {
        var title: String
        var content: String
        
        var body: some View {
            HStack {
                Text(title)
                
                Spacer()
                
                Text(content)
                    .bold()
            }
        }
    }
}

#Preview {
    if let data = SampleWeatherData().data {
        WindInfoView(windDegree: data.current.windDeg, windSpeed: data.current.windSpeed, windGust: data.current.windGust)        
    }
}
