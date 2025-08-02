//
//  WindInfoView.swift
//  FourCast Weather
//
//  Created by Jakub Siwiec on 08/05/2025.
//

import SwiftUI

struct WindInfoView: View {
    @Environment(UserSettings.self) private var userSettings
    let windDeg: Int
    let currentWindSpeed: Double
    let dailyWindSpeed: Double?
    let windGust: Double?
    
    
    private var windDegree: String {
        var direction = "N"
        
        if windDeg < 360 { direction = "NW" }
        if windDeg < 315 { direction = "W" }
        if windDeg < 270 { direction = "SW" }
        if windDeg < 225 { direction = "S" }
        if windDeg < 180 { direction = "SE" }
        if windDeg < 135 { direction = "E" }
        if windDeg < 90 { direction = "NE" }
        if windDeg < 45 { direction = "N" }
        
        return "\(windDeg)° \(direction)"
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 10) {
                DetailView(title: "Prędkość", content: "\(WeatherService.getConvertedWindSpeed(from: currentWindSpeed, userSettings: userSettings)) \(userSettings.settings.windSpeedUnit.symbol)")
                
                DetailView(title: "Porywy", content: "\(WeatherService.getConvertedWindSpeed(from: windGust ?? dailyWindSpeed ?? 0.0, userSettings: userSettings)) \(userSettings.settings.windSpeedUnit.symbol)")
                
                DetailView(title: "Kierunek", content: windDegree)
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
                    .rotationEffect(Angle(degrees: Double(windDeg)))
                    .fontWeight(.thin)
                    .padding()
            }
            .frame(width: 100, height: 100)
            .font(.footnote)
            .padding(.leading)
        }
        .padding()
        .background(.clear.mix(with: .black, by: 0.1))
        .clipShape(RoundedRectangle(cornerRadius: 15))
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
        WindInfoView(windDeg: data.current.windDeg, currentWindSpeed: data.current.windSpeed, dailyWindSpeed: data.daily.first?.windSpeed, windGust: data.current.windGust)        
    }
}
